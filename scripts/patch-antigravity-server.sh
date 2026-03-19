#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  patch-antigravity-server.sh --server-dir <dir> [--gnu-dir <dir>] [--entry <path>] [--create-skip-check]

Options:
  --server-dir         Antigravity server root directory to patch.
  --gnu-dir            GNU runtime directory to place under <server-dir>/gnu (optional).
  --entry              Entry executable to verify after patching (optional).
  --create-skip-check  Create compatibility check skip flag files under /tmp (optional).
EOF
}

SERVER_DIR=""
GNU_DIR=""
ENTRY=""
CREATE_SKIP_CHECK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server-dir) SERVER_DIR="${2:-}"; shift 2 ;;
    --gnu-dir) GNU_DIR="${2:-}"; shift 2 ;;
    --entry) ENTRY="${2:-}"; shift 2 ;;
    --create-skip-check) CREATE_SKIP_CHECK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$SERVER_DIR" ]]; then
  echo "--server-dir is required" >&2
  usage
  exit 1
fi

if ! command -v patchelf >/dev/null 2>&1; then
  echo "patchelf is required but not found in PATH" >&2
  exit 1
fi

abspath() {
  if command -v realpath >/dev/null 2>&1; then
    realpath "$1"
  else
    readlink -f "$1"
  fi
}

SERVER_DIR="$(abspath "$SERVER_DIR")"
if [[ ! -d "$SERVER_DIR" ]]; then
  echo "Server dir not found: $SERVER_DIR" >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64|amd64)
    SYSTEM_INTERP="/lib64/ld-linux-x86-64.so.2"
    INTERP_NAME="ld-linux-x86-64.so.2"
    ;;
  aarch64|arm64)
    SYSTEM_INTERP="/lib/ld-linux-aarch64.so.1"
    INTERP_NAME="ld-linux-aarch64.so.1"
    ;;
  armv7l|armhf|arm)
    SYSTEM_INTERP="/lib/ld-linux-armhf.so.3"
    INTERP_NAME="ld-linux-armhf.so.3"
    ;;
  *)
    echo "Unsupported arch: $(uname -m)" >&2
    exit 1
    ;;
esac

if [[ -n "$GNU_DIR" ]]; then
  GNU_DIR="$(abspath "$GNU_DIR")"
  if [[ ! -d "$GNU_DIR" ]]; then
    echo "GNU dir not found: $GNU_DIR" >&2
    exit 1
  fi
  mkdir -p "$SERVER_DIR/gnu"
  cp -a "$GNU_DIR"/. "$SERVER_DIR/gnu/"
fi

NEW_INTERP="$SERVER_DIR/gnu/$INTERP_NAME"
if [[ ! -f "$NEW_INTERP" ]]; then
  echo "Missing bundled interpreter: $NEW_INTERP" >&2
  exit 1
fi

auto_detect_entry() {
  local cand
  for cand in \
    "$SERVER_DIR/antigravity-latest" \
    "$SERVER_DIR/code-latest" \
    "$SERVER_DIR/bin/antigravity-server" \
    "$SERVER_DIR/bin/code-server" \
    "$SERVER_DIR/bin/code"; do
    if [[ -x "$cand" ]]; then
      printf '%s\n' "$cand"
      return 0
    fi
  done

  cand="$(find "$SERVER_DIR" -maxdepth 1 -type f -name '*-latest' -perm -u+x | head -n1 || true)"
  if [[ -n "$cand" ]]; then
    printf '%s\n' "$cand"
    return 0
  fi

  return 1
}

echo "Server dir : $SERVER_DIR"
echo "Old interp : $SYSTEM_INTERP"
echo "New interp : $NEW_INTERP"

patched=0
elf_count=0
file_count=0

while IFS= read -r -d '' f; do
  file_count=$((file_count + 1))
  case "$f" in
    *.patchbak|*.patchtmp) continue ;;
  esac
  interp="$(patchelf --print-interpreter "$f" 2>/dev/null || true)"
  if [[ -z "$interp" ]]; then
    continue
  fi
  elf_count=$((elf_count + 1))
  if [[ "$interp" == "$SYSTEM_INTERP" ]]; then
    patchelf --set-interpreter "$NEW_INTERP" "$f"
    patched=$((patched + 1))
    echo "Patched: $f"
  fi
done < <(find "$SERVER_DIR" -type f -print0)

echo "Scanned files    : $file_count"
echo "Scanned ELF files: $elf_count"
echo "Patched files    : $patched"

if [[ -z "$ENTRY" ]]; then
  ENTRY="$(auto_detect_entry || true)"
fi

if [[ -n "$ENTRY" ]]; then
  if [[ "$ENTRY" != /* ]]; then
    ENTRY="$SERVER_DIR/$ENTRY"
  fi
  if [[ -x "$ENTRY" ]]; then
    echo "Entry executable : $ENTRY"
    echo "Entry interpreter:"
    patchelf --print-interpreter "$ENTRY" || true
  else
    echo "Entry not executable: $ENTRY" >&2
  fi
else
  echo "No entry executable detected automatically."
fi

if [[ "$CREATE_SKIP_CHECK" == "1" ]]; then
  touch /tmp/vscode-skip-server-requirements-check 2>/dev/null || true
  touch /tmp/antigravity-skip-server-requirements-check 2>/dev/null || true
  echo "Created skip-check flags under /tmp (best effort)."
fi
