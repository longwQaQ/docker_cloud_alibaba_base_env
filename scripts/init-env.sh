#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
env_file="$repo_dir/.env"

if [[ -e "$env_file" ]]; then
  echo ".env 已存在，未覆盖。" >&2
  exit 1
fi

command -v openssl >/dev/null 2>&1 || {
  echo "缺少 openssl，无法生成随机凭证。" >&2
  exit 1
}

umask 077
mysql_root_password=$(openssl rand -hex 24)
mysql_app_password=$(openssl rand -hex 24)
nacos_auth_token=$(openssl rand -base64 48 | tr -d '\n')
nacos_identity_key=$(openssl rand -hex 16)
nacos_identity_value=$(openssl rand -hex 24)
nacos_admin_password=$(openssl rand -hex 24)
sentinel_password=$(openssl rand -hex 24)
temp_file=$(mktemp "$repo_dir/.env.tmp.XXXXXX")
trap 'rm -f "$temp_file"' EXIT

printf '%s\n' \
  'BIND_ADDRESS=127.0.0.1' \
  'MYSQL_PORT=3306' \
  'NACOS_HTTP_PORT=8848' \
  'NACOS_GRPC_PORT=9848' \
  'SENTINEL_PORT=8858' \
  'SEATA_PORT=8091' \
  "MYSQL_ROOT_PASSWORD=$mysql_root_password" \
  "MYSQL_APP_PASSWORD=$mysql_app_password" \
  "NACOS_AUTH_TOKEN=$nacos_auth_token" \
  "NACOS_AUTH_IDENTITY_KEY=$nacos_identity_key" \
  "NACOS_AUTH_IDENTITY_VALUE=$nacos_identity_value" \
  "NACOS_ADMIN_PASSWORD=$nacos_admin_password" \
  'SENTINEL_USERNAME=sentinel' \
  "SENTINEL_PASSWORD=$sentinel_password" \
  > "$temp_file"

chmod 600 "$temp_file"
mv "$temp_file" "$env_file"
trap - EXIT
echo "已生成 ${env_file}（权限 600）。"
