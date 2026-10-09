"""Version identity, cost-ID namespaces and asymmetric hardware constraints."""
import copy
import json
from pathlib import Path
import random
import unittest

from sim_pjrt.llo.compiler_costs import CompilerCosts
from sim_pjrt.llo.pipeline import Bundle, Operation, ResourceHold, simulate

TABLE = Path(__file__).resolve().parents[2] / 'configs/gf_costs_libtpu_0_0_48.json'


class CompilerCostsTest(unittest.TestCase):
    def setUp(self):
        self.data = json.loads(TABLE.read_text())
        self.costs = CompilerCosts(self.data, binary_sha256=self.data['binary_sha256'])

    def simulate(self, bundles):
        return simulate(bundles, frequency_hz=1e9, gaps=['test: not hardware calibration'],
                        model_provenance=self.costs.provenance)

    def test_extract_shape_and_distinct_ids(self):
        self.assertEqual(len(self.costs.rows), 465)
        self.assertEqual(self.costs.resource_count, 32)
        self.assertEqual(sum(len(r['resource_values']) for r in self.data['rows']), 303)
        # These are constructor constants, not inferred from a raw opcode enum.
        self.assertEqual(self.costs.rows[295], (211, {4: 20, 5: 8, 6: 13, 7: 7}))
        self.assertEqual(self.costs.rows[337][1][17], 4)
        self.assertEqual(self.costs.rows[263][0], 10)

    def test_binary_mismatch_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'identity'):
            CompilerCosts(self.data, binary_sha256='0' * 64)

    def test_no_implicit_footprint_or_mnemonic_mapping(self):
        args = dict(issue_footprint=[5], resource_namespace='tc0', classification_source='test mapping')
        with self.assertRaisesRegex(ValueError, 'performance-table'):
            self.costs.operation('a', 'vmatmul', **args)
        with self.assertRaisesRegex(ValueError, 'explicit issue footprint'):
            self.costs.operation('a', 295, **dict(args, issue_footprint=None))
        with self.assertRaisesRegex(ValueError, 'provenance'):
            self.costs.operation('a', 295, **dict(args, classification_source=''))
        with self.assertRaisesRegex(ValueError, 'invalid issue footprint'):
            self.costs.operation('a', 295, **dict(args, issue_footprint=[32]))

    def test_consumer_checks_only_its_footprint(self):
        args = dict(issue_footprint=[5], resource_namespace='tc0.mxu0',
                    classification_source='explicit test fixture, not an ISA adapter')
        a = self.costs.operation('a', 295, **args)
        b = self.costs.operation('b', 295, **args)
        report = self.simulate([Bundle('a', (a,)), Bundle('b', (b,))])
        # Row 295 also holds r4 for 20 cycles. Consumer r5 only waits 8.
        self.assertEqual(report['events'][1]['start_cycle'], 8)
        self.assertEqual(report['modeled_cycles'], 219)
        self.assertIsNone(report['estimated_seconds'])

    def test_disjoint_resources_and_true_dependency(self):
        a = Operation('a', 'a', 50, resource_holds=(ResourceHold('x', 20),))
        b = Operation('b', 'b', 1, issue_checks=('y',))
        c = Operation('c', 'c', 1, depends_on=('a',), issue_checks=('x',))
        r = self.simulate([Bundle('0', (a,)), Bundle('1', (b,)), Bundle('2', (c,))])
        self.assertEqual([e['start_cycle'] for e in r['events']], [0, 1, 50])

    def test_structural_hazard_is_max_not_sum(self):
        a = Operation('a', 'a', 1, resource_holds=(ResourceHold('x', 8), ResourceHold('y', 13)))
        b = Operation('b', 'b', 1, issue_checks=('x', 'y'))
        r = self.simulate([Bundle('0', (a,)), Bundle('1', (b,))])
        self.assertEqual(r['events'][1]['start_cycle'], 13)

    def test_earlier_long_hold_survives_later_short_hold(self):
        a = Operation('a', 'a', 1, resource_holds=(ResourceHold('x', 20),))
        b = Operation('b', 'b', 1, resource_holds=(ResourceHold('x', 1),))
        c = Operation('c', 'c', 1, issue_checks=('x',))
        r = self.simulate([Bundle('0', (a,)), Bundle('1', (b,)), Bundle('2', (c,))])
        self.assertEqual(r['events'][2]['start_cycle'], 20)

    def test_coissue_structural_conflict_is_rejected(self):
        a = Operation('a', 'a', 1, resource_holds=(ResourceHold('x', 2),))
        b = Operation('b', 'b', 1, issue_checks=('x',))
        with self.assertRaisesRegex(ValueError, 'co-issued structural'):
            self.simulate([Bundle('0', (a, b))])

    def test_invalid_table_fields(self):
        for field, value in [('latency_cycles', True), ('latency_cycles', 0xffffffff),
                             ('resource_values', {'32': 1})]:
            data = copy.deepcopy(self.data)
            data['rows'][0][field] = value
            with self.assertRaises(ValueError):
                CompilerCosts(data, binary_sha256=data['binary_sha256'])

    def test_scoreboard_matches_pairwise_history_reference(self):
        rng = random.Random(11)
        for _ in range(30):
            history, bundles, expected, cursor = [], [], [], 0
            for i in range(20):
                values = {r: rng.randint(0, 20) for r in ('a', 'b', 'c')}
                checks = tuple(r for r in values if rng.choice([True, False]))
                start = max([cursor] + [t + holds[r] for t, holds in history for r in checks])
                history.append((start, values))
                expected.append(start)
                bundles.append(Bundle(str(i), (Operation(str(i), 'op', 1,
                    resource_holds=tuple(ResourceHold(r, v) for r, v in values.items()),
                    issue_checks=checks),)))
                cursor = start + 1
            self.assertEqual([e['start_cycle'] for e in self.simulate(bundles)['events']], expected)


if __name__ == '__main__':
    unittest.main()
