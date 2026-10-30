#!/usr/bin/env python3
"""Add (or replace) a version entry in the Jellyfin plugin repository manifest.

Usage:
  update_manifest.py --manifest manifest.json --version 2.0.0.0 --zip dist/cinema-sequencer_2.0.0.0.zip \
      --repo codbar-sec/jellyfin-plugin-cinema-sequencer --tag v2.0.0 [--changelog CHANGELOG.md] [--target-abi 10.11.0.0]

The release workflow calls this. The entry holds the zip's MD5 checksum, which Jellyfin checks on install.
"""
import argparse
import hashlib
import json
import os
import re
import sys
from datetime import datetime, timezone


def md5_of(path):
    h = hashlib.md5()  # Jellyfin's plugin manifest format uses MD5
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def changelog_for(changelog_path, version):
    """Return the text of the '## [x.y.z]' section for the 3-part version, or a short fallback."""
    short = ".".join(version.split(".")[:3])
    fallback = f"See CHANGELOG.md for the changes in {short}."
    if not changelog_path or not os.path.exists(changelog_path):
        return fallback
    text = open(changelog_path, encoding="utf-8").read()
    m = re.search(rf"^## \[{re.escape(short)}\][^\n]*\n(.*?)(?=^## \[|\Z)", text, re.S | re.M)
    if not m:
        return fallback
    body = re.sub(r"\n{3,}", "\n\n", m.group(1).strip())
    return body or fallback


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", required=True)
    ap.add_argument("--version", required=True, help="4-part version, e.g. 2.0.0.0")
    ap.add_argument("--zip", required=True)
    ap.add_argument("--repo", required=True, help="OWNER/REPO")
    ap.add_argument("--tag", required=True, help="release tag, e.g. v2.0.0")
    ap.add_argument("--changelog", default=None)
    ap.add_argument("--target-abi", default="10.11.0.0")
    a = ap.parse_args()

    if not re.fullmatch(r"\d+\.\d+\.\d+\.\d+", a.version):
        sys.exit(f"version must be four numeric parts, got {a.version!r}")
    if not re.fullmatch(r"[A-Za-z0-9._-]+/[A-Za-z0-9._-]+", a.repo):
        sys.exit(f"repo must look like OWNER/REPO, got {a.repo!r}")
    if not re.fullmatch(r"v\d+\.\d+\.\d+", a.tag):
        sys.exit(f"tag must look like v1.2.3, got {a.tag!r}")

    with open(a.manifest, encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, list) or not data:
        sys.exit("manifest must be a non-empty JSON list with one plugin entry")
    plugin = data[0]

    entry = {
        "version": a.version,
        "changelog": changelog_for(a.changelog, a.version),
        "targetAbi": a.target_abi,
        "sourceUrl": f"https://github.com/{a.repo}/releases/download/{a.tag}/{os.path.basename(a.zip)}",
        "checksum": md5_of(a.zip),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }

    versions = [v for v in plugin.get("versions", []) if v.get("version") != a.version]
    versions.insert(0, entry)
    plugin["versions"] = versions

    with open(a.manifest, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"manifest updated: {a.version} ({entry['checksum']})")


if __name__ == "__main__":
    main()
