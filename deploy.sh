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
#           PYTHON        指定解释器（默认自动探测）
#
set -euo pipefail

DEPLOY_HOST="${DEPLOY_HOST:-root@43.153.169.236}"
DEPLOY_PORT="${DEPLOY_PORT:-22}"
DEPLOY_PATH="${DEPLOY_PATH:-/www/wwwroot/Butterfly.seer2.org/}"
DEPLOY_OWNER="${DEPLOY_OWNER:-www:www}"

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
  echo "== 演练模式：不会真正传输 =="
fi

cd "$(dirname "$0")"

# ---- 探测可用的 Python 解释器 ----
# 优先项目内的 .venv，其次系统 python3，最后用 PATH 里的 mkdocs
if [[ -n "${PYTHON:-}" ]]; then
  PY="$PYTHON"
elif [[ -x ".venv/bin/python" ]] && .venv/bin/python -c "import mkdocs" 2>/dev/null; then
  PY=".venv/bin/python"
elif python3 -c "import mkdocs" 2>/dev/null; then
  PY="python3"
else
  echo "错误：找不到可用的 MkDocs 环境。" >&2
  echo "请先初始化虚拟环境：" >&2
  echo "  python3 -m venv .venv && .venv/bin/pip install -r requirements.txt" >&2
  exit 1
fi
echo "== 使用解释器：${PY} =="

echo "== 1/4 构建站点 =="
"$PY" -m mkdocs build --strict
echo "   产物大小：$(du -sh site | cut -f1)"

echo "== 2/4 同步到 ${DEPLOY_HOST}:${DEPLOY_PATH} =="
# --delete 让服务器与本地完全一致，删掉已移除的旧页面
# --exclude 排除系统垃圾文件
rsync -az --delete $DRY_RUN \
  --exclude '.DS_Store' \
  --exclude 'Thumbs.db' \
  -e "ssh -p ${DEPLOY_PORT}" \
  site/ "${DEPLOY_HOST}:${DEPLOY_PATH}"

if [[ -z "$DRY_RUN" ]]; then
  echo "== 3/4 修正文件属主与权限 =="
  # rsync 以 root 运行会上传成 root:root，宝塔面板和 nginx 需要 www:www
  # 目录 755、文件 644，保证可读且目录可进入
  ssh -p "${DEPLOY_PORT}" "${DEPLOY_HOST}" \
    "chown -R ${DEPLOY_OWNER} '${DEPLOY_PATH}' && \
     find '${DEPLOY_PATH}' -type d -exec chmod 755 {} + && \
     find '${DEPLOY_PATH}' -type f -exec chmod 644 {} +"
  echo "   属主已设为 ${DEPLOY_OWNER}"

  echo "== 4/4 完成 =="
  echo "   https://butterfly.seer2.org/"
fi
