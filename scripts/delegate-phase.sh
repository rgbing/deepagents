#!/bin/bash
# Deep Agent - Delegate Phase Script
# 用法: delegate <phase_ids> [--agent <agent_type>] [--parallel]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

DEEP_AGENT_DIR=".deep-agent"
PLAN_FILE="$DEEP_AGENT_DIR/plan.md"
PROGRESS_FILE="$DEEP_AGENT_DIR/progress.md"

# 检查参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供阶段 ID${NC}"
    echo "用法: delegate <phase_ids> [--agent <agent_type>] [--parallel]"
    echo "示例:"
    echo "  delegate 1"
    echo "  delegate 1 2 3 --parallel"
    echo "  delegate 4 --agent researcher"
    exit 1
fi

# 解析参数
PHASE_IDS=()
AGENT_TYPE=""
PARALLEL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --agent)
            AGENT_TYPE="$2"
            shift 2
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        -*)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            exit 1
            ;;
        *)
            PHASE_IDS+=("$1")
            shift
            ;;
    esac
done

# 检查 Deep Agent 目录是否存在
if [ ! -d "$DEEP_AGENT_DIR" ]; then
    echo -e "${RED}错误: 未找到 Deep Agent 目录${NC}"
    echo "请先运行: init-plan <task_description>"
    exit 1
fi

echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Deep Agent 任务委托${NC}"
echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
echo ""

# 显示委托信息
echo -e "${BLUE}委托信息:${NC}"
echo "  阶段 IDs: ${PHASE_IDS[*]}"
echo "  子代理类型: ${AGENT_TYPE:-自动选择}"
echo "  执行模式: $([ "$PARALLEL" = true ] && echo "并行" || echo "串行")"
echo ""

# 验证阶段 IDs
echo -e "${BLUE}验证阶段...${NC}"
VALID_PHASES=()
for phase_id in "${PHASE_IDS[@]}"; do
    if grep -q "ID: $phase_id" "$PLAN_FILE"; then
        VALID_PHASES+=("$phase_id")
        phase_title=$(grep "### Phase" "$PLAN_FILE" | grep "ID: $phase_id" | sed 's/### Phase [0-9]*: //' | sed 's/ \[.*\]//')
        echo -e "  ${GREEN}✓${NC} Phase $phase_id: $phase_title"
    else
        echo -e "  ${RED}✗${NC} Phase $phase_id: 未找到"
    fi
done

if [ ${#VALID_PHASES[@]} -eq 0 ]; then
    echo -e "${RED}错误: 没有有效的阶段 ID${NC}"
    exit 1
fi

echo ""

# 选择子代理
echo -e "${BLUE}选择子代理...${NC}"

if [ -z "$AGENT_TYPE" ]; then
    # 自动选择子代理
    FIRST_PHASE=${VALID_PHASES[0]}
    RECOMMENDED_AGENT=$(grep "### Phase $FIRST_PHASE" "$PLAN_FILE" -A 10 | grep "可委托给" | head -1 | sed 's/.*- **可委托给**: //')
    AGENT_TYPE="${RECOMMENDED_AGENT:-orchestrator}"
    echo "  自动选择: $AGENT_TYPE"
else
    echo "  指定代理: $AGENT_TYPE"
fi

# 验证子代理配置
AGENT_CONFIG="$DEEP_AGENT_DIR/subagents/${AGENT_TYPE}.yaml"
if [ ! -f "$AGENT_CONFIG" ]; then
    echo -e "${YELLOW}警告: 未找到 $AGENT_TYPE 配置，使用默认配置${NC}"
else
    echo "  配置文件: $AGENT_CONFIG"
    echo "  描述: $(grep 'description:' "$AGENT_CONFIG" | cut -d':' -f2- | xargs)"
fi

echo ""

# 准备委托任务
echo -e "${BLUE}准备委托任务...${NC}"

DELEGATION_TASKS=""
for phase_id in "${VALID_PHASES[@]}"; do
    phase_title=$(grep "### Phase" "$PLAN_FILE" | grep "ID: $phase_id" | sed 's/### Phase [0-9]*: //' | sed 's/ \[.*\]//')
    phase_desc=$(grep "### Phase $phase_id" "$PLAN_FILE" -A 10 | grep "描述" | head -1 | sed 's/.*- **描述**: //')
    phase_subtasks=$(grep "### Phase $phase_id" "$PLAN_FILE" -A 20 | grep -A 10 "子任务" | grep "^\- " | head -5 | sed 's/^- //' | tr '\n' '; ')

    if [ -z "$DELEGATION_TASKS" ]; then
        DELEGATION_TASKS="{
  \"goal\": \"$phase_title: $phase_desc\",
  \"context\": \"子任务: $phase_subtasks。参考计划文件: $PLAN_FILE\"
}"
    else
        DELEGATION_TASKS="$DELEGATION_TASKS, {
  \"goal\": \"$phase_title: $phase_desc\",
  \"context\": \"子任务: $phase_subtasks。参考计划文件: $PLAN_FILE\"
}"
    fi
done

# 更新进度文件
for phase_id in "${VALID_PHASES[@]}"; do
    # 更新阶段状态为 in_progress
    sed -i "s/### Phase $phase_id.*$/### Phase $phase_id/; /- \*\*状态\*\*: pending/{ n; s/pending/in_progress/; }" "$PROGRESS_FILE"

    # 添加开始时间
    sed -i "/### Phase $phase_id/,/### Phase $((phase_id + 1))/ {
        /- \*\*开始时间\*\*: -/ {
            s/- \*\*开始时间\*\*: -/- **开始时间**: $(date '+%Y-%m-%d %H:%M:%S')/
        }
    }" "$PROGRESS_FILE"

    # 添加执行者
    sed -i "/### Phase $phase_id/,/### Phase $((phase_id + 1))/ {
        /- \*\*执行者\*\*: -/ {
            s/- \*\*执行者\*\*: -/- **执行者**: $AGENT_TYPE/
        }
    }" "$PROGRESS_FILE"
done

# 添加到审计日志
for phase_id in "${VALID_PHASES[@]}"; do
    echo "| $(date '+%Y-%m-%d %H:%M:%S') | delegate | $AGENT_TYPE | Phase $phase_id | ✅ | 委托阶段给 $AGENT_TYPE |" >> "$DEEP_AGENT_DIR/audit.log"
done

# 添加到会话日志
echo "" >> "$DEEP_AGENT_DIR/session.log"
echo "### 委托阶段" >> "$DEEP_AGENT_DIR/session.log"
echo "- 时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$DEEP_AGENT_DIR/session.log"
echo "- 阶段 IDs: ${VALID_PHASES[*]}" >> "$DEEP_AGENT_DIR/session.log"
echo "- 子代理: $AGENT_TYPE" >> "$DEEP_AGENT_DIR/session.log"
echo "- 模式: $([ "$PARALLEL" = true ] && echo "并行" || echo "串行")" >> "$DEEP_AGENT_DIR/session.log"

echo -e "${GREEN}✓ 委托准备完成${NC}"
echo ""
echo -e "${YELLOW}委托详情:${NC}"
echo "  委托的阶段: ${VALID_PHASES[*]}"
echo "  子代理类型: $AGENT_TYPE"
echo "  执行模式: $([ "$PARALLEL" = true ] && echo "并行" || echo "串行")"
echo ""
echo -e "${BLUE}下一步:${NC}"
echo "  1. 子代理将开始执行任务"
echo "  2. 使用 'show-status' 监控进度"
echo "  3. 完成后使用 'complete-phase <id>' 标记完成"
echo ""
echo -e "${YELLOW}提示:${NC}"
echo "  - 子代理将使用配置文件: $AGENT_CONFIG"
echo "  - 参考 plan.md 获取完整的阶段描述"
echo "  - 查看 .deep-agent/progress.md 跟踪进度"
echo ""

# 如果是并行模式，提供并行执行提示
if [ "$PARALLEL" = true ]; then
    echo -e "${CYAN}并行执行提示:${NC}"
    echo "  阶段 ${VALID_PHASES[*]} 将同时执行"
    echo "  监控每个阶段的独立进度"
    echo "  等待所有阶段完成后继续下一步"
    echo ""
fi
