#!/usr/bin/env bash
# Scan the repository for secrets and personal data before you commit or publish.
#
#   bash scripts/check-no-secrets.sh
#   EXTRA_PATTERNS='yourname|yourdomain\.com|192\.168\.1\.' bash scripts/check-no-secrets.sh
#
# EXTRA_PATTERNS is an extended regex of your own identifying strings (name, username, domain,
# home addresses). It is read from the environment or from a local, git-ignored file
# named .secretscan-extra (one regex per line), so you never have to commit those strings.
#
# Exit code 0 = nothing found. 1 = something found (details printed, matching text is masked).
# This is a best-effort tripwire, not a guarantee. Look through the diff yourself too.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
SELF="scripts/check-no-secrets.sh"
FOUND=0

# Files to scan: tracked files if this is a git repo, otherwise everything except junk.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -t FILES < <(git ls-files --cached --others --exclude-standard)
else
  mapfile -t FILES < <(find . -type f -not -path './.git/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path './dist/*' | sed 's#^\./##')
fi

report() {  # report <label> <file> <line-number>   (never prints the matching text)
  echo "  FOUND  $1  ->  $2:$3"
  FOUND=1
}

scan() {  # scan <label> <extended-regex> [skip-file-regex] [sed-prefilter]
  # sed-prefilter: a sed -E expression applied to each line BEFORE matching (used to blank out
  # known harmless tokens such as Jellyfin version numbers) without changing line numbers.
  local label="$1" re="$2" skip="${3:-}" pre="${4:-}"
  local f
  for f in "${FILES[@]}"; do
    [ "$f" = "$SELF" ] && continue
    [ -n "$skip" ] && [[ "$f" =~ $skip ]] && continue
    [ -f "$f" ] || continue
    # skip binary files
    if grep -qI . "$f" 2>/dev/null; then
      while IFS=: read -r ln _; do
        [ -n "$ln" ] && report "$label" "$f" "$ln"
      done < <( { if [ -n "$pre" ]; then sed -E "$pre" "$f"; else cat "$f"; fi; } \
                | grep -n -E -i -- "$re" 2>/dev/null | cut -d: -f1 | sed 's/$/:/')
    fi
  done
}

echo "Scanning ${#FILES[@]} files..."

# 1. Forbidden file names (credentials, local settings, logs, media).
for f in "${FILES[@]}"; do
  base="$(basename "$f")"
  case "$base" in
    cookies*.txt|*cookies*.txt|.env|.env.*|*.pem|*.key|*.pfx|*.log|Jellyfin.Plugin.*.xml|*.bak*|*.mp4|*.mkv|*.mov)
      echo "  FOUND  forbidden file name  ->  $f"; FOUND=1 ;;
  esac
done

# 2. Credential-shaped content.
scan "JWT / TMDB read token"      'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.'
scan "api_key= with a value"      'api_key=[0-9a-f]{16,}'
scan "bare 32-hex string (TMDB v3 key shape)" '(^|[^0-9a-f-])[0-9a-f]{32}([^0-9a-f-]|$)' '^manifest\.json$'
scan "private key block"          'BEGIN [A-Z ]*PRIVATE KEY'
scan "Netscape cookie line"       '\.(youtube|google)\.com[[:space:]]+(TRUE|FALSE)[[:space:]]'
scan "Bearer token with value"    'Bearer[[:space:]]+[A-Za-z0-9._-]{20,}'
scan "GitHub token"               'gh[pousr]_[A-Za-z0-9]{30,}'
scan "AWS-style access key"       'AKIA[0-9A-Z]{16}'

# 3. Personal / environment data.
#    Jellyfin version numbers such as 10.11.0.0 look like 10.x LAN addresses, so those are blanked first.
scan "private LAN IP address"     '\b(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})\b' '' 's/\b10\.(9|1[0-2])\.[0-9]+\.[0-9]+/VERSION/g'
scan "Linux home path"            '/home/[a-z_][a-z0-9_-]*/'
scan "Windows user path"          '[A-Za-z]:\\Users\\[^\\ ]+'
scan "email address"              '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' '^(\.github/workflows/.*)$'

# 4. The author's own identifying strings (kept out of the repo on purpose).
EXTRA=""
[ -n "${EXTRA_PATTERNS:-}" ] && EXTRA="$EXTRA_PATTERNS"
if [ -f .secretscan-extra ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue
    EXTRA="${EXTRA:+$EXTRA|}$line"
  done < .secretscan-extra
fi
if [ -n "$EXTRA" ]; then
  scan "your own identifying strings" "$EXTRA"
else
  echo "  (no EXTRA_PATTERNS given: not checking for your own name/domain/addresses)"
fi

# 5. Allow-list: emails that are fine in this repo.
#    noreply addresses and the example domain are not secrets; handled by manual review of the report above.

if [ "$FOUND" -eq 0 ]; then
  echo "OK: nothing found."
  exit 0
fi
echo
echo "Problems found. Remove or rewrite the lines listed above (values are not printed on purpose)."
echo "If anything below was ever pushed, assume it is public: revoke the key or credential at its source."
exit 1
