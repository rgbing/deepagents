#!/bin/bash
# Deep Agent - Backup Script
# 用法: deep-backup [backup_name]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DEEP_AGENT_DIR=".deep-agent"
BACKUP_DIR="$DEEP_AGENT_DIR/backups"

# 日志函数
log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# 检查 Deep Agent 目录是否存在
if [ ! -d "$DEEP_AGENT_DIR" ]; then
    log_error "未找到 Deep Agent 目录"
    exit 1
fi

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成备份名称
BACKUP_NAME="${1:-backup-$(date +%Y%m%d_%H%M%S)}"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME.tar.gz"

log_info "正在创建备份: $BACKUP_NAME"

# 创建临时备份目录
TEMP_BACKUP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_BACKUP_DIR" EXIT

# 复制文件到临时目录
log_info "复制文件..."
cp -r "$DEEP_AGENT_DIR"/{plan.md,progress.md,context.md,audit.log,session.log,checkpoints,subagents} "$TEMP_BACKUP_DIR/" 2>/dev/null || true

# 创建备份信息
cat > "$TEMP_BACKUP_DIR/backup-info.txt" << EOF
备份名称: $BACKUP_NAME
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
创建者: $(whoami)@$(hostname)
Git 提交: $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")
Git 分支: $(git branch --show-current 2>/dev/null || echo "N/A")
EOF

# 创建压缩包
log_info "创建压缩包..."
tar -czf "$BACKUP_PATH" -C "$TEMP_BACKUP_DIR" . 2>/dev/null

# 获取备份大小
BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)

log_success "备份创建成功！"
echo ""
echo "备份信息:"
echo "  名称: $BACKUP_NAME"
echo "  路径: $BACKUP_PATH"
echo "  大小: $BACKUP_SIZE"
echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 显示可用备份列表
log_info "可用备份列表:"
ls -lh "$BACKUP_DIR" | grep -E "\.tar\.gz$" | awk '{print "  " $9 " (" $5 ")"}'
echo ""

# 清理旧备份（保留最近 10 个）
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    log_info "清理旧备份（保留最近 10 个）..."
    ls -1t "$BACKUP_DIR"/*.tar.gz | tail -n +11 | xargs rm -f
    log_success "清理完成"
fi

log_success "备份流程完成"
