#!/usr/bin/env bash
set -euo pipefail

DEST="/usr/local/bin/whonix-type"
RAW_URL="https://raw.githubusercontent.com/Heretek-AI/whonix-type/main/whonix-type"

echo "==> Installing whonix-type to ${DEST}..."
if [ -f "./whonix-type" ]; then
    install -m 755 "./whonix-type" "${DEST}"
else
    curl -fsSL "${RAW_URL}" -o "${DEST}"
    chmod 755 "${DEST}"
fi

echo "==> Successfully installed whonix-type!"
echo "==> Run 'whonix-type --help' for usage instructions."
