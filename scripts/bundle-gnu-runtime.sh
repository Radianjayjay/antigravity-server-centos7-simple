#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bundle-gnu-runtime.sh --from <dir> --to <server-dir>

Copies GNU runtime files into <server-dir>/gnu and removes static/dev artifacts.
EOF
}

FROM=""
TO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM="${2:-}"; shift 2 ;;
    --to) TO="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$FROM" || -z "$TO" ]]; then
  echo "--from and --to are required" >&2
  usage
  exit 1
fi

FROM="$(realpath "$FROM")"
TO="$(realpath "$TO")"

if [[ ! -d "$FROM" ]]; then
  echo "Source runtime dir not found: $FROM" >&2
  exit 1
fi
if [[ ! -d "$TO" ]]; then
  echo "Server dir not found: $TO" >&2
  exit 1
fi

mkdir -p "$TO/gnu"
cp -a "$FROM"/. "$TO/gnu/"

find "$TO/gnu" -type f \( -name '*.a' -o -name '*.la' -o -name '*.o' -o -name '*.py' -o -name '*.spec' \) -delete

echo "Bundled GNU runtime into $TO/gnu"
