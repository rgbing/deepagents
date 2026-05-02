#!/bin/bash
# Deep Agent - Save Context Script
# 用法: save-context <checkpoint_name>

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

DEEP_AGENT_DIR=".deep-agent"
CHECKPOINTS_DIR="$DEEP_AGENT_DIR/checkpoints"

# 检查参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供保存点名称${NC}"
    echo "用法: save-context <checkpoint_name>"
    echo "示例: save-context milestone-1"
    exit 1
fi

CHECKPOINT_NAME="$1"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
CHECKPOINT_FILE="$CHECKPOINTS_DIR/$CHECKPOINT_NAME-$TIMESTAMP.md"

# 检查 Deep Agent 目录是否存在
if [ ! -d "$DEEP_AGENT_DIR" ]; then
    echo -e "${RED}错误: 未找到 Deep Agent 目录${NC}"
    echo "请先运行: init-plan <task_description>"
    exit 1
fi

echo -e "${BLUE}正在保存上下文到保存点: $CHECKPOINT_NAME${NC}"
echo ""

# 创建保存点文件
cat > "$CHECKPOINT_FILE" << EOF
# Deep Agent 上下文保存点

## 保存点信息
- **名称**: $CHECKPOINT_NAME
- **时间戳**: $(date '+%Y-%m-%d %H:%M:%S')
- **会话**: ${TIMESTAMP}

## 任务描述
$(grep "## 任务描述" "$DEEP_AGENT_DIR/plan.md" -A 1 | tail -1)

## 整体进度
$(grep -A 3 "## 阶段进度" "$DEEP_AGENT_DIR/progress.md" | head -5)

## 当前阶段
$(grep "## 当前阶段" "$DEEP_AGENT_DIR/context.md" -A 2 | tail -3)

## 已完成的工作
$(grep -A 20 "## 已完成工作" "$DEEP_AGENT_DIR/context.md" | head -25)

## 当前状态
$(grep -A 20 "## 当前状态" "$DEEP_AGENT_DIR/context.md" | head -25)

## 待办事项
$(grep -A 20 "## 待办事项" "$DEEP_AGENT_DIR/context.md" | head -25)

## 关键决策
$(grep -A 20 "## 关键决策" "$DEEP_AGENT_DIR/context.md" | head -25)

## 待解决的问题
$(grep -A 20 "## 待解决的问题" "$DEEP_AGENT_DIR/context.md" | head -25)

## 最近的审计日志
$(tail -10 "$DEEP_AGENT_DIR/audit.log")

## 资源使用快照
$(grep -A 5 "## 资源使用" "$DEEP_AGENT_DIR/progress.md" | tail -5)

## 保存时的文件列表
$(find . -type f -not -path "./.deep-agent/*" -not -path "./.git/*" -not -path "./node_modules/*" | head -50 | sed 's/^/- /')

## 恢复指令
要从此保存点恢复，运行:
\`\`\`bash
load-context $CHECKPOINT_NAME
\`\`\`

---
*此保存点由 Deep Agent 自动生成*
EOF

# 添加到审计日志
echo "| $(date '+%Y-%m-%d %H:%M:%S') | save-context | system | - | ✅ | 保存上下文: $CHECKPOINT_NAME |" >> "$DEEP_AGENT_DIR/audit.log"

# 添加到会话日志
echo "" >> "$DEEP_AGENT_DIR/session.log"
echo "### 保存上下文" >> "$DEEP_AGENT_DIR/session.log"
echo "- 时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$DEEP_AGENT_DIR/session.log"
echo "- 保存点: $CHECKPOINT_NAME" >> "$DEEP_AGENT_DIR/session.log"
echo "- 文件: $CHECKPOINT_FILE" >> "$DEEP_AGENT_DIR/session.log"

echo -e "${GREEN}✓ 上下文已保存${NC}"
echo -e "  保存点名称: ${CYAN}$CHECKPOINT_NAME${NC}"
echo -e "  文件位置: ${CYAN}$CHECKPOINT_FILE${NC}"
echo ""
echo -e "${YELLOW}使用以下命令恢复此保存点:${NC}"
echo "  load-context $CHECKPOINT_NAME"
echo ""

# 显示所有可用的保存点
echo -e "${BLUE}可用的保存点:${NC}"
if [ "$(ls -A $CHECKPOINTS_DIR 2>/dev/null)" ]; then
    ls -lt "$CHECKPOINTS_DIR" | grep -v "^total" | awk '{print "  " $9}' | head -10
else
    echo "  (无其他保存点)"
fi
echo ""
