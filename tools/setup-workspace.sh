#!/usr/bin/env bash
# ============================================================
# Mihomo X 分析工作区初始化脚本
#
# 作用：在当前目录建一个持久工作区，把模块包下载、解包、只保留关键文本文件，
#       并初始化分析记录文件。重复执行不会重复下载。给 AI（豆包等）用。
#
# 用法（在当前目录下执行）：
#   bash setup-workspace.sh              # 最新版本，建到 ./mihomo-x
#   bash setup-workspace.sh v1.9.47      # 指定版本
#   bash setup-workspace.sh latest ./dir # 指定目标目录
#
# 依赖：bash、curl、unzip
# 完成后：读 ./mihomo-x/src/ 里的文件，分析结论追加到 ./mihomo-x/analysis.md
# ============================================================

set -u

REPO="xygsdgd/Mihomo-X"
TAG="${1:-latest}"
DEST="${2:-./mihomo-x}"

command -v curl  >/dev/null || { echo "缺少 curl";  exit 1; }
command -v unzip >/dev/null || { echo "缺少 unzip"; exit 1; }

mkdir -p "$DEST" || { echo "无法创建目录：$DEST"; exit 1; }
cd "$DEST" || exit 1
SRC="./src"
mkdir -p "$SRC"

# ---------- 解析真实 tag ----------
if [ "$TAG" = "latest" ]; then
  PAGE="https://github.com/$REPO/releases/latest"
else
  PAGE="https://github.com/$REPO/releases/tag/$TAG"
fi

REAL=$(curl -fsSL -o /dev/null -w '%{url_effective}' --max-time 25 "$PAGE" 2>/dev/null)
REAL_TAG=$(printf '%s' "$REAL" | sed 's|.*/tag/||')
[ -n "$REAL_TAG" ] || { echo "取不到版本号，检查仓库地址或网络"; exit 1; }
echo "版本：$REAL_TAG"

# ---------- 找到 zip 附件 ----------
EXP=$(curl -fsSL --max-time 25 "https://github.com/$REPO/releases/expanded_assets/$REAL_TAG" 2>/dev/null)
REL_PATH=$(printf '%s' "$EXP" | grep -o "/$REPO/releases/download/[^\"]*\.zip" | head -1)
if [ -z "$REL_PATH" ]; then
  echo "该 Release 没有 zip 附件：https://github.com/$REPO/releases/tag/$REAL_TAG"
  exit 1
fi
ASSET="https://github.com$REL_PATH"
ZIP_NAME=$(basename "$REL_PATH")

# ---------- 下载（已存在则跳过） ----------
if [ -f "$ZIP_NAME" ]; then
  echo "已存在 $ZIP_NAME，跳过下载"
else
  echo "下载：$ZIP_NAME"
  curl -fL --max-time 300 -o "$ZIP_NAME" "$ASSET" || { echo "下载失败"; exit 1; }
fi

# ---------- 解包并只留关键文本 ----------
rm -rf ./pkg
mkdir -p ./pkg
unzip -qo "$ZIP_NAME" -d ./pkg || { echo "解包失败：包可能损坏"; exit 1; }

KEEP="module.prop customize.sh service.sh post-fs-data.sh action.sh uninstall.sh scripts/mihomo.sh data/config.yaml"
for f in $KEEP; do
  if [ -f "./pkg/$f" ]; then
    mkdir -p "$SRC/$(dirname "$f")"
    cp "./pkg/$f" "$SRC/$f"
  fi
done

rm -rf ./pkg

# ---------- 初始化分析记录 ----------
SHA=$( (sha256sum "$ZIP_NAME" 2>/dev/null || shasum -a 256 "$ZIP_NAME" 2>/dev/null) | awk '{print $1}')
if [ ! -f analysis.md ]; then
  {
    echo "# Mihomo X 分析记录"
    echo ""
    echo "版本：$REAL_TAG"
    echo "包：$ZIP_NAME"
    echo "SHA256：${SHA:-未知}"
    echo "初始化时间：$(date '+%Y-%m-%d %H:%M')"
    echo ""
  } > analysis.md
  echo "已创建 analysis.md"
else
  echo "analysis.md 已存在，保留历史记录"
fi

# ---------- 汇总 ----------
echo ""
echo "工作区：$(pwd)"
echo "关键文件："
ls -lh "$SRC" 2>/dev/null | awk 'NR>1{print "  "$5"\t"$9}'
echo ""
echo "怎么用："
echo "  1. 读 ./mihomo-x/src/scripts/mihomo.sh（约 9000 行，模块全部逻辑）"
echo "  2. 读 ./mihomo-x/src/customize.sh（安装逻辑与架构限制）"
echo "  3. 分析结论追加到 ./mihomo-x/analysis.md，格式："
echo "     ## $(date '+%Y-%m-%d') ｜ 问题：xxx"
echo "     - 结论：xxx"
echo "     - 证据：scripts/mihomo.sh:行号"
echo "     - 处置：xxx"
echo "  4. core/ 是二进制内核，不要读"
