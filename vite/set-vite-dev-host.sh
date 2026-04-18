#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WP_ROOT="$(cd "${THEME_DIR}/../../.." && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env.local"

if ! command -v wp >/dev/null 2>&1; then
  echo "[set-vite-dev-host] wp command not found. Skip updating ${ENV_FILE}."
  exit 0
fi

WP_CLI_PHP_ARGS='-d display_errors=0 -d error_reporting=E_ALL&~E_DEPRECATED&~E_USER_DEPRECATED'
HOME_URL_RAW="$(
  WP_CLI_PHP_ARGS="${WP_CLI_PHP_ARGS}" wp --path="${WP_ROOT}" option get home 2>&1 || true
)"

HOME_URL="$(
  printf '%s\n' "${HOME_URL_RAW}" \
    | tr -d '\r' \
    | sed -nE 's#.*(https?://[^[:space:]]+).*#\1#p' \
    | head -n1
)"

if [ -z "${HOME_URL}" ]; then
  echo "[set-vite-dev-host] Could not read WordPress home URL. Skip updating ${ENV_FILE}."
  exit 0
fi

HOST="$(printf '%s' "${HOME_URL}" | sed -E 's#^[a-zA-Z]+://##; s#/.*$##')"
if [ -z "${HOST}" ]; then
  echo "[set-vite-dev-host] Could not parse host from: ${HOME_URL}"
  exit 0
fi

TMP_FILE="$(mktemp)"
if [ -f "${ENV_FILE}" ]; then
  grep -v '^VITE_DEV_SERVER_HOST=' "${ENV_FILE}" > "${TMP_FILE}" || true
fi

printf 'VITE_DEV_SERVER_HOST=%s\n' "${HOST}" >> "${TMP_FILE}"
mv "${TMP_FILE}" "${ENV_FILE}"

echo "[set-vite-dev-host] Updated VITE_DEV_SERVER_HOST=${HOST} in ${ENV_FILE}"

if command -v open >/dev/null 2>&1; then
  open "${HOME_URL}" >/dev/null 2>&1 || true
  echo "[set-vite-dev-host] Opened ${HOME_URL} in browser."
fi
