#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

COMPOSE_FILE="compose.yml"
ENV_FILE=".env"
CT="open-llama-gpu"
IMAGE="open-llama:gpu-latest"
INSTANCE_ENV="${INSTANCE_ENV:-instance.env}"
FORCE="${FORCE:-0}"

log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }
die() { log "ERROR: $*"; exit 1; }
running() { [ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null)" = "true" ]; }
health() { docker inspect -f '{{.State.Health.Status}}' "$1" 2>/dev/null || echo "none"; }

command -v docker >/dev/null 2>&1 || die "docker not found"
[ -f "${COMPOSE_FILE}" ] || die "missing ${COMPOSE_FILE}"
[ -f "${ENV_FILE}" ] || die "missing ${ENV_FILE}"

POOL_IN="${POOL:-}"
WORKER_IN="${WORKER:-}"
POOL2_IN="${POOL2:-}"
GPU_COIN_IN="${GPU_COIN:-}"
START_IN="${START:-}"
GPU_VISIBLE_IN="${GPU_VISIBLE:-}"
GPU_API_PORT_IN="${GPU_API_PORT:-}"
GPU_DEVICES_IN="${GPU_DEVICES:-}"

. "${ENV_FILE}"

if [ -f "${INSTANCE_ENV}" ]; then
  . "${INSTANCE_ENV}"
fi

if [ -n "${POOL_IN}" ]; then POOL="${POOL_IN}"; fi
if [ -n "${WORKER_IN}" ]; then WORKER="${WORKER_IN}"; fi
if [ -n "${POOL2_IN}" ]; then POOL2="${POOL2_IN}"; fi
if [ -n "${GPU_COIN_IN}" ]; then GPU_COIN="${GPU_COIN_IN}"; fi
if [ -n "${START_IN}" ]; then START="${START_IN}"; fi
if [ -n "${GPU_VISIBLE_IN}" ]; then GPU_VISIBLE="${GPU_VISIBLE_IN}"; fi
if [ -n "${GPU_API_PORT_IN}" ]; then GPU_API_PORT="${GPU_API_PORT_IN}"; fi
if [ -n "${GPU_DEVICES_IN}" ]; then GPU_DEVICES="${GPU_DEVICES_IN}"; fi

if [ "$#" -ge 2 ]; then
  POOL="$1"
  WORKER="$2"
  POOL2="${3:-${POOL2:-}}"
fi

POOL="${POOL:-}"
WORKER="${WORKER:-}"
POOL2="${POOL2:-}"
GPU_COIN="${GPU_COIN:-}"
START="${START:-0}"

[ -n "${POOL}" ] || die "POOL required"
[ -n "${WORKER}" ] || die "WORKER required"
[ -n "${GPU_COIN}" ] || die "GPU_COIN required"

export POOL WORKER POOL2 GPU_COIN GPU_VISIBLE GPU_API_PORT GPU_DEVICES

docker image inspect "${IMAGE}" >/dev/null 2>&1 || die "missing image ${IMAGE}"

if running "${CT}" && [ "${FORCE}" != "1" ]; then
  die "${CT} is running, use FORCE=1"
fi

docker stop -t 10 "${CT}" >/dev/null 2>&1 || true
docker rm -f "${CT}" >/dev/null 2>&1 || true

log "create ${CT}"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" create --no-build

env_dump="$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "${CT}" 2>/dev/null || true)"
pool_ok=0
worker_ok=0
coin_ok=0
while IFS= read -r line; do
  case "${line}" in
    POOL=?*) pool_ok=1 ;;
    WORKER=?*) worker_ok=1 ;;
    COIN=?*) coin_ok=1 ;;
  esac
done <<< "${env_dump}"
[ "${pool_ok}" = "1" ] || die "POOL missing in ${CT}"
[ "${worker_ok}" = "1" ] || die "WORKER missing in ${CT}"
[ "${coin_ok}" = "1" ] || die "COIN missing in ${CT}"

log "env ok: ${CT}"

if [ "${START}" = "1" ]; then
  log "start ${CT}"
  docker start "${CT}" >/dev/null
  log "health: $(health "${CT}")"
fi

log "done"
