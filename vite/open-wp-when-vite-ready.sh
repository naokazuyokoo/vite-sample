#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOT_FILE="${SCRIPT_DIR}/.hot"
HOME_URL_FILE="${SCRIPT_DIR}/.wp-home-url"

if ! command -v open >/dev/null 2>&1; then
  exit 0
fi

# Wait up to 30s for Vite to become ready and write .hot.
for _ in $(seq 1 300); do
  if [ -s "${HOT_FILE}" ]; then
    break
  fi
  sleep 0.1
done

if [ ! -s "${HOT_FILE}" ] || [ ! -f "${HOME_URL_FILE}" ]; then
  exit 0
fi

VITE_BASE_URL="$(head -n1 "${HOT_FILE}" | tr -d '\r')"
if [ -z "${VITE_BASE_URL}" ]; then
  exit 0
fi

# Wait up to 10s for Vite client endpoint to become reachable.
for _ in $(seq 1 100); do
  if curl -kfsS -o /dev/null "${VITE_BASE_URL}/@vite/client"; then
    break
  fi
  sleep 0.1
done

if ! curl -kfsS -o /dev/null "${VITE_BASE_URL}/@vite/client"; then
  exit 0
fi

HOME_URL="$(head -n1 "${HOME_URL_FILE}" | tr -d '\r')"
if [ -z "${HOME_URL}" ]; then
  exit 0
fi

open "${HOME_URL}" >/dev/null 2>&1 || true
echo "[open-wp-when-vite-ready] Opened ${HOME_URL} in browser."
