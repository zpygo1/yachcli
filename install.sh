#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${YACH_INSTALL_DIR:-$HOME/.local/bin}"
YACH_REPO="${YACH_REPO:-zpygo1/yachcli}"
SOURCE_URL="${YACH_SOURCE_URL:-https://raw.githubusercontent.com/$YACH_REPO/main/bin/yach}"

mkdir -p "$INSTALL_DIR"

if [ -f "./bin/yach" ]; then
  cp "./bin/yach" "$INSTALL_DIR/yach"
else
  curl -fsSL "$SOURCE_URL" -o "$INSTALL_DIR/yach"
fi

chmod +x "$INSTALL_DIR/yach"

cat <<EOF
yach installed to: $INSTALL_DIR/yach

Next:
  export PATH="$INSTALL_DIR:\$PATH"
  yach init
  yach doctor

If you publish this repo, set YACH_REPO in install.sh first.
EOF
