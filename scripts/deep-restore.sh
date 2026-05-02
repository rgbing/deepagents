#!/bin/bash
# Deep Agent - Restore Script
# 用法: deep-restore <backup_name>

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

# 检查参数
if [ -z "$1" ]; then
    log_error "请提供备份名称"
    echo ""
    echo "用法: deep-restore <backup_name>"
    echo ""
    echo "可用备份:"
    if [ -d "$BACKUP_DIR" ]; then
        ls -lh "$BACKUP_DIR" | grep -E "\.tar\.gz$" | awk '{print "  " $9 " (" $5 ")"}'
    else
        echo "  (无可用备份)"
    fi
    exit 1
fi

BACKUP_NAME="$1"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME.tar.gz"

# 检查备份文件是否存在
if [ ! -f "$BACKUP_PATH" ]; then
    log_error "备份文件不存在: $BACKUP_PATH"
    exit 1
fi

# 显示备份信息
if tar -tzf "$BACKUP_PATH" backup-info.txt >/dev/null 2>&1; then
    echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}备份信息${NC}"
    echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
    tar -xzf "$BACKUP_PATH" -O backup-info.txt 2>/dev/null
    echo ""
fi

# 确认恢复
echo -e "${YELLOW}警告: 恢复备份将覆盖当前状态！${NC}"
read -p "确定要恢复吗？(yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    log_info "恢复已取消"
    exit 0
fi

# 创建当前状态的备份
log_info "创建当前状态的备份..."
CURRENT_BACKUP="pre-restore-$(date +%Y%m%d_%H%M%S)"
./scripts/deep-backup.sh "$CURRENT_BACKUP" >/dev/null 2>&1 || true

# 创建临时目录
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 解压备份
log_info "解压备份..."
tar -xzf "$BACKUP_PATH" -C "$TEMP_DIR" 2>/dev/null

# 备份当前文件（如果有）
log_info "备份当前文件..."
if [ -d "$DEEP_AGENT_DIR" ]; then
    cp -r "$DEEP_AGENT_DIR" "$TEMP_DIR/current-backup" 2>/dev/null || true
fi

# 恢复文件
log_info "恢复文件..."
cp -r "$TEMP_DIR"/{plan.md,progress.md,context.md,audit.log,session.log,checkpoints,subagents} "$DEEP_AGENT_DIR/" 2>/dev/null || true

log_success "恢复完成！"
echo ""
echo "恢复信息:"
echo "  备份名称: $BACKUP_NAME"
echo "  恢复时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  当前状态已备份到: $CURRENT_BACKUP"
echo ""

# 显示恢复后的状态
log_info "恢复后的状态:"
./scripts/show-status.sh | head -30
