"""Cache cleanup must retain main even when branch snapshots are newer."""

from pathlib import Path
import runpy
import unittest


SCRIPT = Path(__file__).resolve().parents[2] / ".github/scripts/prune_native_caches.py"
select_caches = runpy.run_path(str(SCRIPT))["select_caches"]


def cache(identity, ref="main", *, key=None):
    return dict(id=identity, ref="refs/heads/" + ref, size_in_bytes=100,
                created_at=f"2026-10-{identity:02d}T00:00:00Z",
                key=key or f"native-manylinux-2-34-x64-hash-{identity}")


class CacheRetentionTest(unittest.TestCase):
    def ids(self, caches, default="main"):
        keep, remove = select_caches(caches, default)
        return {row["id"] for row in keep}, {row["id"] for row in remove}

    def test_newer_branch_caches_cannot_displace_main(self):
        self.assertEqual(self.ids([cache(1), cache(2, "feature-a"), cache(3, "feature-b")]),
                         ({1, 3}, {2}))

    def test_only_latest_snapshot_in_each_scope_is_retained(self):
        self.assertEqual(self.ids([cache(1), cache(2, "feature"),
                                   cache(3, "feature"), cache(4)]),
                         ({3, 4}, {1, 2}))

    def test_without_main_only_latest_branch_snapshot_is_retained(self):
        self.assertEqual(self.ids([cache(1, "feature-a"), cache(2, "feature-b")]),
                         ({2}, {1}))

    def test_unrelated_caches_are_never_deleted(self):
        self.assertEqual(self.ids([cache(1), cache(2, key="node-cache-npm")]), ({1}, set()))

    def test_repository_default_branch_is_honored(self):
        self.assertEqual(self.ids([cache(1, "dev"), cache(2), cache(3)], default="dev"),
                         ({1, 3}, {2}))

    def test_invalid_metadata_fails_before_cleanup(self):
        for field, value in (("id", True), ("ref", None), ("size_in_bytes", -1),
                             ("created_at", "2026-10-01T00:00:00")):
            with self.subTest(field=field), self.assertRaises(ValueError):
                select_caches([dict(cache(1), **{field: value})], "main")


if __name__ == "__main__":
    unittest.main()
