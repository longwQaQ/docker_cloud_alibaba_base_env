#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_dir"

COMPOSE_PROJECT_NAME="spring-cloud-alibaba-base-smoke-$$"
export COMPOSE_PROJECT_NAME

: "${MYSQL_ROOT_PASSWORD:=smoke-root-password}"
: "${MYSQL_APP_PASSWORD:=smoke-app-password}"
: "${NACOS_AUTH_TOKEN:=c21va2UtdGVzdC10b2tlbi1tdXN0LWJlLWxvbmdlci10aGFuLTMytlrloZc=}"
: "${NACOS_AUTH_IDENTITY_KEY:=smoke-identity-key}"
: "${NACOS_AUTH_IDENTITY_VALUE:=smoke-identity-value}"
: "${NACOS_ADMIN_PASSWORD:=smoke-nacos-admin-password}"
: "${SENTINEL_PASSWORD:=smoke-sentinel-password}"

export MYSQL_ROOT_PASSWORD MYSQL_APP_PASSWORD NACOS_AUTH_TOKEN
export NACOS_AUTH_IDENTITY_KEY NACOS_AUTH_IDENTITY_VALUE NACOS_ADMIN_PASSWORD
export SENTINEL_PASSWORD

cleanup() {
  docker compose down --volumes
}
trap cleanup EXIT

docker compose down --volumes
docker compose up -d --build --wait --wait-timeout 240
docker compose ps -a

curl -fsS "http://${BIND_ADDRESS:-127.0.0.1}:${NACOS_HTTP_PORT:-8848}/nacos/v1/console/health/readiness" \
  | grep -q OK
curl -fsS "http://${BIND_ADDRESS:-127.0.0.1}:${SENTINEL_PORT:-8858}/" >/dev/null

docker compose logs --no-color > /tmp/spring-cloud-alibaba-base-smoke.log
if grep -En '(Public Key Retrieval is not allowed|Server start failed|Access denied for user)' \
  /tmp/spring-cloud-alibaba-base-smoke.log; then
  echo "启动日志包含致命错误。" >&2
  exit 1
fi

echo "完整启动验证通过。"
