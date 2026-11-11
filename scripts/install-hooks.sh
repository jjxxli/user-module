#!/bin/sh
# ============================================================
# 安装 Git 本地钩子：把 core.hooksPath 指向仓库内的 .githooks 目录
# 用法（在仓库根目录或任意位置执行）：
#   sh scripts/install-hooks.sh
#   或在 Git Bash 中：./scripts/install-hooks.sh
# ============================================================
set -eu

# 仓库根目录 = 本脚本所在目录的上一级
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)

cd "$repo_root"

if [ ! -d .githooks ]; then
    echo "❌ 未找到 .githooks 目录，请确认脚本位于 <仓库根>/scripts/ 下。" >&2
    exit 1
fi

# 1. 设置本地 git 配置：钩子从仓库内的 .githooks 读取
git config core.hooksPath .githooks

# 2. 给所有钩子添加可执行权限（Linux / macOS / Git Bash 下必需）
for hook in .githooks/*; do
    [ -f "$hook" ] || continue
    chmod +x "$hook" 2>/dev/null || true
done

# 3. 打印安装结果
echo "✅ Git 本地钩子安装完成。"
echo "   仓库：$repo_root"
echo "   core.hooksPath = $(git config --get core.hooksPath)"
echo "   已启用钩子："
for hook in .githooks/*; do
    [ -f "$hook" ] || continue
    echo "     - $(basename "$hook")"
done
echo ""
echo "提示：钩子只影响本地提交；push 后仍会经过 GitHub Actions CI 检查。"
