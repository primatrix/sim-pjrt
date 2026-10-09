"""Pipeline hazards, overlap and incomplete-input regression tests."""
import unittest
import random

from sim_pjrt.llo.pipeline import Bundle, Operation, Reservation, simulate, chrome_trace, CreditWait, CreditUpdate


class PipelineTest(unittest.TestCase):
    def run_model(self, bundles, **kwargs):
        return simulate(bundles, frequency_hz=1e9, gaps=kwargs.pop('gaps', []),
                        model_provenance='synthetic test', **kwargs)

    def test_mxu_throughput_is_not_result_latency(self):
        report = self.run_model([
            Bundle('a', (Operation('m0', 'matmul', 211, (Reservation('mxu0', 8),)),)),
            Bundle('b', (Operation('m1', 'matmul', 211, (Reservation('mxu1', 8),)),)),
            Bundle('c', (Operation('m2', 'matmul', 211, (Reservation('mxu0', 8),)),)),
            Bundle('d', (Operation('pop', 'pop', 1, depends_on=('m0',)),)),
        ])
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 8, 211])
        self.assertEqual(report['modeled_cycles'], 219)

    def test_dma_wait_overlaps_independent_compute(self):
        report = self.run_model([
            Bundle('a', (Operation('dma', 'load', 100, (Reservation('hbm', 80),)),)),
            Bundle('b', (Operation('compute', 'matmul', 60, (Reservation('mxu0', 8),)),)),
            Bundle('c', (Operation('consume', 'consume', 3, depends_on=('dma', 'compute')),)),
        ])
        self.assertEqual(report['modeled_cycles'], 103)
        self.assertEqual(report['events'][-1]['blockers'], ['dependency:dma'])

    def test_future_reservation_allows_earlier_hole(self):
        report = self.run_model([
            Bundle('a', (Operation('a', 'late', 21, (Reservation('r', 10, 10),)),)),
            Bundle('b', (Operation('b', 'early', 2, (Reservation('r', 2),)),)),
            Bundle('c', (Operation('c', 'conflict', 12, (Reservation('r', 12),)),)),
        ])
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 20])

    def test_multiple_resource_constraints_are_rechecked(self):
        report = self.run_model([
            Bundle('a', (Operation('a', 'a', 20, (Reservation('x', 5), Reservation('y', 5, 8))),)),
            Bundle('b', (Operation('b', 'b', 10, (Reservation('x', 3), Reservation('y', 5))),)),
        ])
        self.assertEqual(report['events'][1]['start_cycle'], 13)

    def test_coissue_conflict_is_not_silently_serialized(self):
        with self.assertRaisesRegex(ValueError, 'co-issued'):
            self.run_model([Bundle('a', (Operation('a', 'a', 8, (Reservation('x', 8),)),
                                         Operation('b', 'b', 8, (Reservation('x', 8),))))])

    def test_missing_dependency_and_duplicate_id(self):
        with self.assertRaisesRegex(ValueError, 'missing prior producer'):
            self.run_model([Bundle('a', (Operation('a', 'pop', 1, depends_on=('missing',)),))])
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            self.run_model([Bundle('a', (Operation('a', 'a', 1),)),
                            Bundle('b', (Operation('a', 'a', 1),))])

    def test_initial_dependency_and_partial_export(self):
        r = self.run_model([Bundle('a', (Operation('a', 'a', 1, depends_on=('input',)),))],
                           initial_ready={'input': 7}, gaps=['unknown IMEM'])
        self.assertEqual(r['modeled_cycles'], 8)
        self.assertIsNone(r['estimated_seconds'])
        events = [e for e in chrome_trace(r)['traceEvents'] if e['ph'] == 'X']
        self.assertTrue(all(e['args']['provenance'] == 'modeled' for e in events))

    def test_invalid_costs_and_empty_path(self):
        for latency in [True, float('nan'), float('inf'), -1]:
            with self.assertRaises(ValueError):
                self.run_model([Bundle('a', (Operation('a', 'a', latency),))])
        with self.assertRaises(ValueError):
            self.run_model([])

    def test_offset_reservations_against_exhaustive_integer_scheduler(self):
        rng = random.Random(42)
        for _ in range(40):
            bundles, calendar, expected = [], {'x': [], 'y': []}, []
            cursor = 0
            for i in range(15):
                holds = tuple(Reservation(r, rng.randint(1, 5), rng.randint(0, 12))
                              for r in ('x', 'y'))
                bundles.append(Bundle(str(i), (Operation(str(i), 'op', 1, holds),)))
                start = cursor
                while any(start + h.offset < b and start + h.offset + h.duration > a
                          for h in holds for a, b in calendar[h.resource]):
                    start += 1
                for h in holds:
                    calendar[h.resource].append((start + h.offset, start + h.offset + h.duration))
                expected.append(start)
                cursor = start + 1
            self.assertEqual([e['start_cycle'] for e in self.run_model(bundles)['events']], expected)

    def test_queued_dma_partial_credits_and_signed_consumption(self):
        report = self.run_model([
            Bundle('a', (Operation('d0', 'dma', 10, service_resource='hbm',
                                   credit_updates=(CreditUpdate('f', 4, True),)),)),
            Bundle('b', (Operation('d1', 'dma', 10, service_resource='hbm',
                                   credit_updates=(CreditUpdate('f', 4, True),)),)),
            Bundle('c', (Operation('w0', 'wait', 1, credit_waits=(CreditWait('f', 4),)),)),
            Bundle('d', (Operation('sub', 'vsyncadd', 1, credit_updates=(CreditUpdate('f', -4),)),)),
            Bundle('e', (Operation('w1', 'wait', 1, credit_waits=(CreditWait('f', 4),)),)),
        ])
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 2, 10, 11])
        self.assertEqual([e['issue_end_cycle'] for e in report['events']], [1, 2, 10, 11, 20])
        self.assertIn((3, 10), [(e['start_cycle'], e['end_cycle']) for e in report['timeline'] if e['track'] == 'Bundle stalls'])
        self.assertEqual(report['final_credits'], {'f': 4})
        self.assertEqual(report['status'], 'modeled')

    def test_wrong_flag_and_insufficient_credit_remain_unresolved(self):
        for flag, required in [('other', 1), ('f', 5)]:
            report = self.run_model([
                Bundle('a', (Operation('dma', 'dma', 100, service_resource='hbm',
                                       credit_updates=(CreditUpdate('f', 4, True),)),)),
                Bundle('b', (Operation('wait', 'wait', 1, credit_waits=(CreditWait(flag, required),)),)),
                Bundle('c', (Operation('compute', 'compute', 1),)),
            ])
            self.assertEqual(report['events'][2]['start_cycle'], 2)
            self.assertTrue(any('partial completion credits' in g for g in report['gaps']))
            self.assertIsNone(report['estimated_seconds'])

    def test_coissued_credit_reads_do_not_see_same_bundle_writes(self):
        operations = (Operation('add', 'add', 1, credit_updates=(CreditUpdate('f', 1),)),
                      Operation('wait', 'wait', 1, credit_waits=(CreditWait('f', 1),)))
        for ops in (operations, operations[::-1]):
            report = self.run_model([Bundle('a', ops)])
            self.assertTrue(any('partial completion credits' in g for g in report['gaps']))
            self.assertEqual(report['final_credits'], {'f': 1})
        underflow = self.run_model([Bundle('a', (Operation('sub', 'sub', 1,
            credit_updates=(CreditUpdate('f', -1),)),))])
        self.assertTrue(any('underflow' in g for g in underflow['gaps']))


if __name__ == '__main__':
    unittest.main()
