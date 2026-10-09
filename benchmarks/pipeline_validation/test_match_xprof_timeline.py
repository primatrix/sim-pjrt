import random
import unittest
from match_xprof_timeline import static_match, chronology_conflicts


class ContextMappingTest(unittest.TestCase):
    def test_inserted_and_missing_bundles_do_not_shift_correspondence(self):
        rng=random.Random(41)
        left=[tuple(str(rng.randrange(8)) for _ in range(3)) for _ in range(150)]
        right=left[:45]+[('instrumentation',)]+left[45:95]+left[98:]
        pairs,_,_=static_match(left,right)
        self.assertGreater(len(pairs),120)
        for i,j in pairs.items():
            self.assertEqual(left[i],right[j])
            self.assertEqual(j,i if i<45 else i+1 if i<95 else i-2)
        self.assertFalse(set(range(95,98)) & pairs.keys())
        self.assertEqual(len(pairs),len(set(pairs.values())))
        self.assertEqual(sorted(pairs.values()),[j for _,j in sorted(pairs.items())])

    def test_repeated_context_is_not_claimed_as_unique(self):
        pairs,_,_=static_match([('vld','vst')]*100,[('vld','vst')]*100)
        self.assertEqual(pairs,{})

    def test_equal_occurrence_counts_do_not_hide_order_conflicts(self):
        rows=[((i,'vld'),dict(model_address=str(i),model_us=i,hardware_us=t))
              for i,t in enumerate([0,2,1,3])]
        self.assertEqual(chronology_conflicts(rows),{(1,'vld'),(2,'vld')})

    def test_small_reconstruction_jitter_is_not_a_new_match(self):
        rows=[((i,'vld'),dict(model_address=str(i),model_us=i,hardware_us=t))
              for i,t in enumerate([0,1,0.999,2])]
        self.assertEqual(chronology_conflicts(rows),set())


if __name__=='__main__':unittest.main()
