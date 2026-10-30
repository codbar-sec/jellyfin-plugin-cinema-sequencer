#!/usr/bin/env bash
# Build the plugin and package the release zip.
#
#   bash scripts/package.sh <4-part version> [output dir]
#   bash scripts/package.sh 2.0.0.0 dist
#
# Environment overrides: JELLYFIN_VERSION (default 10.11.0), TFM (default net9.0)
#
# The zip contains the plugin DLL and its non-Jellyfin dependencies ONLY. Jellyfin's own
# assemblies are provided by the server; shipping a second copy breaks type matching.
set -euo pipefail

VERSION="${1:?usage: package.sh <4-part version, e.g. 2.0.0.0> [output dir]}"
OUTDIR="${2:-dist}"
JELLYFIN_VERSION="${JELLYFIN_VERSION:-10.11.0}"
TFM="${TFM:-net9.0}"

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: version must have four numeric parts, e.g. 2.0.0.0 (got '$VERSION')" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBLISH="$(mktemp -d)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$PUBLISH" "$STAGE"' EXIT

mkdir -p "$ROOT/$OUTDIR"
ZIP="$ROOT/$OUTDIR/cinema-sequencer_${VERSION}.zip"
rm -f "$ZIP"

dotnet publish "$ROOT/Jellyfin.Plugin.CinemaSequencer/Jellyfin.Plugin.CinemaSequencer.csproj" \
  -c Release -o "$PUBLISH" \
  -p:JellyfinVersion="$JELLYFIN_VERSION" -p:TFM="$TFM" \
  -p:AssemblyVersion="$VERSION" -p:FileVersion="$VERSION"

[ -f "$PUBLISH/Jellyfin.Plugin.CinemaSequencer.dll" ] || { echo "ERROR: plugin DLL missing from publish output" >&2; exit 1; }

for f in "$PUBLISH"/*.dll; do
  name="$(basename "$f")"
  case "$name" in
    Jellyfin.Plugin.CinemaSequencer.dll) ;;                                     # always keep
    Jellyfin.*|MediaBrowser.*|Emby.*|Microsoft.*|System.*) continue ;;          # provided by the server
  esac
  cp "$f" "$STAGE/"
done

( cd "$STAGE" && zip -q -r "$ZIP" . )

echo "Packaged: $ZIP"
echo "Contents:"
unzip -l "$ZIP" | awk 'NR>3 && $4 != "" {print "  " $4}'
if command -v md5sum >/dev/null 2>&1; then md5sum "$ZIP"; else md5 "$ZIP"; fi
