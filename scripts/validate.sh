#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_dir"

required_files=(
  compose.yaml
  .env.example
  README.md
  SECURITY.md
  CONTRIBUTING.md
  CHANGELOG.md
  LICENSE
  mysql/init/01-nacos-schema.sql
  mysql/init/02-seata-schema.sql
  seata/application.yml
  sentinel/Dockerfile
)

for file in "${required_files[@]}"; do
  [[ -s "$file" ]] || {
    echo "缺少必要文件或文件为空：$file" >&2
    exit 1
  }
done

bash -n scripts/init-env.sh scripts/smoke-test.sh scripts/validate.sh

if rg -n '(codelong|MYSQL_(ROOT_)?PASSWORD=nacos)' compose.yaml mysql nacos seata sentinel 2>/dev/null; then
  echo "发现已知的历史硬编码凭证。" >&2
  exit 1
fi

if rg -n '(privileged:[[:space:]]*true|/var/run/docker.sock|-[[:space:]]*/:/)' compose.yaml sentinel 2>/dev/null; then
  echo "发现禁止的高风险容器配置。" >&2
  exit 1
fi

test_env=(
  BIND_ADDRESS=127.0.0.1
  MYSQL_ROOT_PASSWORD=test-root-password
  MYSQL_APP_PASSWORD=test-app-password
  NACOS_AUTH_TOKEN=dGVzdC10b2tlbi10ZXN0LXRva2VuLXRlc3QtdG9rZW4tdGVzdC10b2tlbg==
  NACOS_AUTH_IDENTITY_KEY=test-identity-key
  NACOS_AUTH_IDENTITY_VALUE=test-identity-value
  NACOS_ADMIN_PASSWORD=test-nacos-admin-password
  SENTINEL_USERNAME=sentinel
  SENTINEL_PASSWORD=test-sentinel-password
)

env "${test_env[@]}" docker compose config --quiet

echo "静态验证通过。"
