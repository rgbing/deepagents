#!/bin/bash
# Deep Agent - Load Context Script
# 用法: load-context <checkpoint_name>

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
    echo "用法: load-context <checkpoint_name>"
    echo "示例: load-context milestone-1"
    echo ""
    echo -e "${BLUE}可用的保存点:${NC}"
    if [ -d "$CHECKPOINTS_DIR" ] && [ "$(ls -A $CHECKPOINTS_DIR 2>/dev/null)" ]; then
        ls -lt "$CHECKPOINTS_DIR" | grep -v "^total" | awk '{print "  " $9}' | sed 's/-[0-9]*\.md$//'
    else
        echo "  (无可用保存点)"
    fi
    exit 1
fi

CHECKPOINT_NAME="$1"

# 检查 Deep Agent 目录是否存在
if [ ! -d "$DEEP_AGENT_DIR" ]; then
    echo -e "${RED}错误: 未找到 Deep Agent 目录${NC}"
    echo "请先运行: init-plan <task_description>"
    exit 1
fi

# 查找保存点文件（支持模糊匹配）
CHECKPOINT_FILE=$(find "$CHECKPOINTS_DIR" -name "${CHECKPOINT_NAME}*.md" -type f | sort -r | head -1)

if [ -z "$CHECKPOINT_FILE" ]; then
    echo -e "${RED}错误: 未找到保存点 '$CHECKPOINT_NAME'${NC}"
    echo ""
    echo -e "${BLUE}可用的保存点:${NC}"
    if [ "$(ls -A $CHECKPOINTS_DIR 2>/dev/null)" ]; then
        ls -lt "$CHECKPOINTS_DIR" | grep -v "^total" | awk '{print "  " $9}' | sed 's/-[0-9]*\.md$//'
    else
        echo "  (无可用保存点)"
    fi
    exit 1
fi

echo -e "${BLUE}正在从保存点加载上下文: $CHECKPOINT_NAME${NC}"
echo -e "  文件: $CHECKPOINT_FILE"
echo ""

# 显示保存点信息
echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}保存点信息${NC}"
echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
grep -A 3 "## 保存点信息" "$CHECKPOINT_FILE" | sed 's/^/  /'
echo ""

# 恢复上下文
echo -e "${CYAN}恢复的上下文:${NC}"
echo ""

# 更新 context.md
cat > "$DEEP_AGENT_DIR/context-restored.md" << EOF
# Deep Agent 上下文 (从保存点恢复)

## 恢复信息
- **保存点**: $CHECKPOINT_NAME
- **恢复时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **源文件**: $CHECKPOINT_FILE

## 原始上下文
$(cat "$CHECKPOINT_FILE")

## 恢复后的行动
1. 审查恢复的上下文
2. 确认当前状态
3. 从上一步继续工作
4. 更新进度文件

## 注意事项
- 检查是否有新的更改需要整合
- 验证所有文件仍然存在
- 确认依赖项仍然有效
EOF

# 替换当前上下文
mv "$DEEP_AGENT_DIR/context-restored.md" "$DEEP_AGENT_DIR/context.md"

# 显示恢复的内容
echo -e "${GREEN}✓ 任务描述${NC}"
grep "## 任务描述" "$CHECKPOINT_FILE" -A 1 | tail -1 | sed 's/^/  /'
echo ""

echo -e "${GREEN}✓ 进度状态${NC}"
grep "## 整体进度" "$CHECKPOINT_FILE" -A 5 | sed 's/^/  /'
echo ""

echo -e "${GREEN}✓ 当前阶段${NC}"
grep "## 当前阶段" "$CHECKPOINT_FILE" -A 2 | sed 's/^/  /'
echo ""

echo -e "${GREEN}✓ 待办事项${NC}"
grep "## 待办事项" "$CHECKPOINT_FILE" -A 5 | sed 's/^/  /'
echo ""

# 添加到审计日志
echo "| $(date '+%Y-%m-%d %H:%M:%S') | load-context | system | - | ✅ | 加载上下文: $CHECKPOINT_NAME |" >> "$DEEP_AGENT_DIR/audit.log"

# 添加到会话日志
echo "" >> "$DEEP_AGENT_DIR/session.log"
echo "### 加载上下文" >> "$DEEP_AGENT_DIR/session.log"
echo "- 时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$DEEP_AGENT_DIR/session.log"
echo "- 保存点: $CHECKPOINT_NAME" >> "$DEEP_AGENT_DIR/session.log"
echo "- 文件: $CHECKPOINT_FILE" >> "$DEEP_AGENT_DIR/session.log"

echo -e "${GREEN}✓ 上下文已成功恢复${NC}"
echo ""
echo -e "${YELLOW}下一步:${NC}"
echo "  1. 查看恢复的状态: cat .deep-agent/context.md"
echo "  2. 查看当前进度: show-status"
echo "  3. 继续工作: start-phase <id>"
echo ""
