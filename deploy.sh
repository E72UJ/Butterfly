#!/usr/bin/env bash
#
# 一键构建并部署 MkDocs 站点到服务器。
#
#   用法：  ./deploy.sh              正式部署
#           ./deploy.sh --dry-run    只看会传哪些文件，不实际传输
#
#   可用环境变量覆盖默认值：
#           DEPLOY_HOST   默认 root@43.153.169.236
#           DEPLOY_PORT   默认 22
#           DEPLOY_PATH   默认 /www/wwwroot/butterfly/
#
set -euo pipefail

DEPLOY_HOST="${DEPLOY_HOST:-root@43.153.169.236}"
DEPLOY_PORT="${DEPLOY_PORT:-22}"
DEPLOY_PATH="${DEPLOY_PATH:-/www/wwwroot/butterfly/}"

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
  echo "== 演练模式：不会真正传输 =="
fi

cd "$(dirname "$0")"

echo "== 1/3 构建站点 =="
python3 -m mkdocs build --strict
echo "   产物大小：$(du -sh site | cut -f1)"

echo "== 2/3 同步到 ${DEPLOY_HOST}:${DEPLOY_PATH} =="
# --delete 让服务器与本地完全一致，删掉已移除的旧页面
# --exclude 排除系统垃圾文件
rsync -az --delete $DRY_RUN \
  --exclude '.DS_Store' \
  --exclude 'Thumbs.db' \
  -e "ssh -p ${DEPLOY_PORT}" \
  site/ "${DEPLOY_HOST}:${DEPLOY_PATH}"

if [[ -z "$DRY_RUN" ]]; then
  echo "== 3/3 完成 =="
  echo "   https://butterfly.seer2.org/"
fi
