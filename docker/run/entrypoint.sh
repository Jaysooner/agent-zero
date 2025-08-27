#!/usr/bin/env bash
set -euo pipefail

# Default to /workspace, but let the user override where Agent Zero should run
A0_WORKDIR_DEFAULT="/workspace"
A0_WORKDIR="${A0_WORKDIR:-$A0_WORKDIR_DEFAULT}"
mkdir -p "$A0_WORKDIR"

# Optional ownership fix
if [[ "${CHOWN_WORKSPACE:-0}" == "1" ]]; then
  uid="${TARGET_UID:-1000}"
  gid="${TARGET_GID:-1000}"
  echo "[entrypoint] chown -R ${uid}:${gid} ${A0_WORKDIR}"
  chown -R "${uid}:${gid}" "${A0_WORKDIR}" || echo "[entrypoint] chown skipped/failed (non-fatal)"
fi

# Common defaults that many Agent Zero setups expect
export A0_HOME="${A0_HOME:-${A0_WORKDIR}/.a0}"
export A0_DATA_DIR="${A0_DATA_DIR:-${A0_WORKDIR}}"
export A0_LOG_DIR="${A0_LOG_DIR:-${A0_WORKDIR}/logs}"
mkdir -p "$A0_HOME" "$A0_LOG_DIR"

# Compatibility symlinks so older scripts that assume /a0 or /app don't break
# We do not overwrite if real dirs already exist
[[ -e /a0 || -L /a0 ]] || ln -s "${A0_WORKDIR}" /a0
[[ -e /app || -L /app ]] || ln -s "${A0_WORKDIR}" /app

cd "$A0_WORKDIR"
echo "[entrypoint] PWD=$(pwd) UID=$(id -u) GID=$(id -g)"
echo "[entrypoint] A0_HOME=${A0_HOME} A0_DATA_DIR=${A0_DATA_DIR} A0_LOG_DIR=${A0_LOG_DIR}"
exec "$@"
