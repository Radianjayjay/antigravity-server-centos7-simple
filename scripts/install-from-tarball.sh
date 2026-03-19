#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install-from-tarball.sh --tarball <file> [options]

Required:
  --tarball             Antigravity server tar.gz file.

Optional:
  --install-dir         Install root (default: ~/.antigravity-server)
  --strip-components    Tar strip-components value (default: 1)
  --gnu-dir             GNU runtime source directory to copy into <install-dir>/gnu
  --entry               Entry executable path relative to install dir for verify
  --create-skip-check   Create compatibility check skip flag files under /tmp
EOF
}

TARBALL=""
INSTALL_DIR="${HOME}/.antigravity-server"
STRIP_COMPONENTS="1"
GNU_DIR=""
ENTRY=""
CREATE_SKIP_CHECK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tarball) TARBALL="${2:-}"; shift 2 ;;
    --install-dir) INSTALL_DIR="${2:-}"; shift 2 ;;
    --strip-components) STRIP_COMPONENTS="${2:-}"; shift 2 ;;
    --gnu-dir) GNU_DIR="${2:-}"; shift 2 ;;
    --entry) ENTRY="${2:-}"; shift 2 ;;
    --create-skip-check) CREATE_SKIP_CHECK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$TARBALL" ]]; then
  echo "--tarball is required" >&2
  usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_SCRIPT="$SCRIPT_DIR/patch-antigravity-server.sh"

TARBALL="$(realpath "$TARBALL")"
if [[ ! -f "$TARBALL" ]]; then
  echo "Tarball not found: $TARBALL" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
INSTALL_DIR="$(realpath "$INSTALL_DIR")"

echo "Installing $TARBALL -> $INSTALL_DIR"
tar xzf "$TARBALL" -C "$INSTALL_DIR" --strip-components "$STRIP_COMPONENTS"

cmd=("$PATCH_SCRIPT" --server-dir "$INSTALL_DIR")
if [[ -n "$GNU_DIR" ]]; then
  cmd+=(--gnu-dir "$GNU_DIR")
fi
if [[ -n "$ENTRY" ]]; then
  cmd+=(--entry "$ENTRY")
fi
if [[ "$CREATE_SKIP_CHECK" == "1" ]]; then
  cmd+=(--create-skip-check)
fi

"${cmd[@]}"

echo "Done."
