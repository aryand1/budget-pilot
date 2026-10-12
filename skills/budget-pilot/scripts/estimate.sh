#!/usr/bin/env bash
# Rough input-token estimate for a set of paths. Usage: estimate.sh <path> [path...]
set -euo pipefail
[ $# -eq 0 ] && { echo "usage: estimate.sh <path> [path...]"; exit 1; }
bytes=0
for p in "$@"; do
  if [ -d "$p" ]; then
    b=$(find "$p" -type f \
      -not -path '*/node_modules/*' -not -path '*/.git/*' \
      -not -path '*/dist/*' -not -path '*/build/*' \
      \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' \
      -o -name '*.java' -o -name '*.go' -o -name '*.rs' -o -name '*.c' \
      -o -name '*.cpp' -o -name '*.rb' -o -name '*.md' -o -name '*.json' \
      -o -name '*.yaml' -o -name '*.yml' -o -name '*.txt' \) \
      -exec wc -c {} + 2>/dev/null | tail -1 | awk '{print $1+0}')
  elif [ -f "$p" ]; then
    b=$(wc -c < "$p")
  else
    b=0
  fi
  bytes=$((bytes + b))
done
read_tokens=$((bytes / 4))
working=$((read_tokens * 6))   # assumes ~3x re-reads plus ~2x output overhead
echo "files-bytes=$bytes"
echo "one-pass-read-tokens=~$read_tokens"
echo "working-estimate-tokens=~$working"
if   [ "$working" -lt 50000 ];   then tier=S
elif [ "$working" -lt 200000 ];  then tier=M
elif [ "$working" -lt 1000000 ]; then tier=L
else tier=XL; fi
echo "suggested-tier=$tier"
