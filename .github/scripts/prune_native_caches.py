"""Retain the latest default-branch and non-default-branch native caches."""

import argparse
from datetime import datetime
import json
import re
import subprocess


PREFIX = "native-manylinux-2-34-x64-"


def select_caches(caches, default_branch):
    native = []
    seen = set()
    for cache in caches:
        if not str(cache.get("key", "")).startswith(PREFIX):
            continue
        if (type(cache.get("id")) is not int or cache["id"] <= 0
                or cache["id"] in seen or not isinstance(cache.get("ref"), str)
                or type(cache.get("size_in_bytes")) is not int
                or cache["size_in_bytes"] < 0):
            raise ValueError("invalid native cache metadata")
        created = datetime.fromisoformat(cache["created_at"].replace("Z", "+00:00"))
        if created.tzinfo is None:
            raise ValueError("cache creation time must include a timezone")
        seen.add(cache["id"])
        native.append((created, cache["id"], cache))
    native.sort(reverse=True, key=lambda entry: entry[:2])
    keep, remove = [], []
    scopes = set()
    for _, _, cache in native:
        scope = "default" if cache["ref"] == "refs/heads/" + default_branch else "other"
        if scope not in scopes:
            keep.append(cache)
            scopes.add(scope)
        else:
            remove.append(cache)
    return keep, remove


def api(path, *options):
    return json.loads(subprocess.check_output(["gh", "api", *options, path], text=True))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--delete", action="store_true", help="Apply the cleanup; default is a dry run")
    args = parser.parse_args()
    if not re.fullmatch(r"[\w.-]+/[\w.-]+", args.repo):
        parser.error("expected OWNER/REPO")
    repository = "repos/" + args.repo
    default_branch = api(repository)["default_branch"]
    pages = api(repository + "/actions/caches?per_page=100", "--paginate", "--slurp")
    caches = [cache for page in pages for cache in page["actions_caches"]]
    keep, remove = select_caches(caches, default_branch)
    for cache in keep:
        print(f"Keep {cache['id']} {cache['ref']} {cache['key']}", flush=True)
    for cache in remove:
        if args.delete:
            subprocess.run(["gh", "api", "--method", "DELETE",
                            f"{repository}/actions/caches/{cache['id']}"], check=True)
        action = "Deleted" if args.delete else "Would delete"
        print(f"{action} {cache['id']} {cache['ref']} {cache['key']}", flush=True)
    print(f"{'Reclaimed' if args.delete else 'Reclaimable'} bytes: "
          f"{sum(cache['size_in_bytes'] for cache in remove)}")


if __name__ == "__main__":
    main()
