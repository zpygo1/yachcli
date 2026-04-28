#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$ROOT_DIR"

bash -n bin/yach
bash -n install.sh

chmod +x bin/yach install.sh

./bin/yach --version >/dev/null
./bin/yach --help >/dev/null

YACH_CONFIG_DIR="$TMP_DIR/config" \
YACH_CACHE_DIR="$TMP_DIR/cache" \
  ./bin/yach config set default-admin 123456

YACH_CONFIG_DIR="$TMP_DIR/config" \
YACH_CACHE_DIR="$TMP_DIR/cache" \
  ./bin/yach doctor --offline >/dev/null

YACH_INSTALL_DIR="$TMP_DIR/bin" ./install.sh >/dev/null
"$TMP_DIR/bin/yach" --version >/dev/null

echo "smoke ok"
