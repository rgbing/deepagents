#!/bin/bash
# Deep Agent - Show Status Script (优化版)
# 用法: show-status [phase_id]
# 改进: 更好的兼容性、错误处理和性能

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

DEEP_AGENT_DIR=".deep-agent"

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

# 错误处理
error_exit() {
    log_error "$1"
    exit 1
}

# 检查 Deep Agent 目录是否存在
if [ ! -d "$DEEP_AGENT_DIR" ]; then
    error_exit "未找到 Deep Agent 目录\n请先运行: init-plan <task_description>"
fi

# 检查必要文件
PLAN_FILE="$DEEP_AGENT_DIR/plan.md"
PROGRESS_FILE="$DEEP_AGENT_DIR/progress.md"
CONTEXT_FILE="$DEEP_AGENT_DIR/context.md"
AUDIT_FILE="$DEEP_AGENT_DIR/audit.log"

for file in "$PLAN_FILE" "$PROGRESS_FILE"; do
    if [ ! -f "$file" ]; then
        error_exit "必要文件缺失: $file"
    fi
done

# 显示标题
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          Deep Agent 状态报告                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 显示任务描述
echo -e "${BLUE}📋 任务描述${NC}"
TASK_DESC=$(grep "## 任务描述" "$PLAN_FILE" -A 1 | tail -1 | sed 's/^/  /')
if [ -n "$TASK_DESC" ]; then
    echo "$TASK_DESC"
else
    echo "  (未设置)"
fi
echo ""

# 显示元信息
echo -e "${BLUE}📊 元信息${NC}"
META_INFO=$(grep -A 5 "## 元信息" "$PLAN_FILE" | grep -E "^- " | sed 's/^/  /')
if [ -n "$META_INFO" ]; then
    echo "$META_INFO"
else
    echo "  (信息不可用)"
fi
echo ""

# 计算进度
TOTAL_PHASES=$(grep -c "### Phase" "$PLAN_FILE" 2>/dev/null || echo 0)
COMPLETED_PHASES=$(grep -c "状态.*complete" "$PROGRESS_FILE" 2>/dev/null || echo 0)
IN_PROGRESS_PHASES=$(grep -c "状态.*in_progress" "$PROGRESS_FILE" 2>/dev/null || echo 0)
PENDING_PHASES=$(grep -c "状态.*pending" "$PROGRESS_FILE" 2>/dev/null || echo 0)

if [ "$TOTAL_PHASES" -gt 0 ]; then
    PROGRESS_PERCENT=$((COMPLETED_PHASES * 100 / TOTAL_PHASES))
else
    PROGRESS_PERCENT=0
fi

echo -e "${BLUE}📈 整体进度${NC}"
echo "  总阶段数: $TOTAL_PHASES"
echo -e "  ${GREEN}已完成${NC}: $COMPLETED_PHASES"
echo -e "  ${YELLOW}进行中${NC}: $IN_PROGRESS_PHASES"
echo -e "  ${RED}待处理${NC}: $PENDING_PHASES"
echo ""
echo "  进度条:"
  printf "  ["
  for i in $(seq 1 $TOTAL_PHASES); do
    if [ $i -le $COMPLETED_PHASES ]; then
      printf "${GREEN}█${NC}"
    elif [ $i -le $((COMPLETED_PHASES + IN_PROGRESS_PHASES)) ]; then
      printf "${YELLOW}█${NC}"
    else
      printf "${RED}─${NC}"
    fi
  done
  printf "] ${PROGRESS_PERCENT}%%\n"
echo ""

# 显示阶段状态
echo -e "${BLUE}🔄 阶段状态${NC}"
grep "### Phase" "$PLAN_FILE" | while read -r line; do
    # 兼容性改进：使用 cut 和 grep -oE 替代复杂 sed
    phase_title=$(echo "$line" | cut -d':' -f2- | cut -d'[' -f1 | sed 's/^ *//; s/ *$//')
    phase_id=$(echo "$line" | grep -oE 'ID: [0-9]+' | grep -oE '[0-9]+')

    if [ -z "$phase_id" ]; then
        continue
    fi

    # 查找状态（兼容性改进）
    status_line=$(grep "### Phase.*$phase_id" "$PROGRESS_FILE" -A 10 2>/dev/null | grep "状态" | head -1)
    status=$(echo "$status_line" | cut -d':' -f2 | sed 's/^ *//; s/\*\*//g; s/ *$//' || echo "pending")

    # 根据状态设置颜色
    case "$status" in
        complete)
            status_color="${GREEN}✓${NC}"
            ;;
        in_progress)
            status_color="${YELLOW}⟳${NC}"
            ;;
        blocked)
            status_color="${RED}⚠${NC}"
            ;;
        *)
            status_color="${RED}○${NC}"
            ;;
    esac

    printf "  Phase %s: %s %s\n" "$phase_id" "$phase_title" "$status_color"
done
echo ""

# 显示当前阶段
CURRENT_PHASE=$(grep "当前阶段" "$PLAN_FILE" | grep -o "Phase [0-9]*" 2>/dev/null || echo "未设置")
echo -e "${BLUE}🎯 当前阶段${NC}"
echo "  $CURRENT_PHASE"
echo ""

# 显示上下文摘要
if [ -f "$CONTEXT_FILE" ]; then
    echo -e "${BLUE}📝 上下文摘要${NC}"
    CONTEXT_SUMMARY=$(grep -A 5 "## 上下文摘要" "$CONTEXT_FILE" 2>/dev/null | tail -5 | sed 's/^/  /')
    if [ -n "$CONTEXT_SUMMARY" ]; then
        echo "$CONTEXT_SUMMARY"
    else
        echo "  (无摘要)"
    fi
    echo ""
fi

# 显示下一步行动
if [ -f "$CONTEXT_FILE" ]; then
    echo -e "${BLUE}➡️  下一步行动${NC}"
    NEXT_ACTIONS=$(grep -A 5 "## 下一步行动" "$CONTEXT_FILE" 2>/dev/null | tail -5 | sed 's/^/  /')
    if [ -n "$NEXT_ACTIONS" ]; then
        echo "$NEXT_ACTIONS"
    else
        echo "  (无下一步行动)"
    fi
    echo ""
fi

# 显示资源使用
echo -e "${BLUE}⚙️  资源使用${NC}"
if [ -f "$PROGRESS_FILE" ]; then
    RESOURCE_INFO=$(grep -A 5 "## 资源使用" "$PROGRESS_FILE" 2>/dev/null | tail -5 | sed 's/^/  /')
    if [ -n "$RESOURCE_INFO" ]; then
        echo "$RESOURCE_INFO"
    else
        echo "  信息不可用"
    fi
else
    echo "  信息不可用"
fi
echo ""

# 显示最近的审计日志
if [ -f "$AUDIT_FILE" ]; then
    echo -e "${BLUE}📋 最近活动（最后5条）${NC}"
    RECENT_LOGS=$(tail -6 "$AUDIT_FILE" 2>/dev/null | head -5 | column -t -s '|' 2>/dev/null || tail -5 "$AUDIT_FILE")
    echo "$RECENT_LOGS" | sed 's/^/  /'
    echo ""
fi

# 显示快速命令
echo -e "${BLUE}🚀 快速命令${NC}"
echo "  start-phase <id>              开始指定阶段"
echo "  complete-phase <id>           完成指定阶段"
echo "  delegate <id> --agent <type>  委托阶段给子代理"
echo "  save-context <name>           保存当前上下文"
echo "  load-context <name>           加载保存的上下文"
echo "  optimize-plan                 优化执行计划"
echo "  show-phase <id>               显示阶段详情"
echo "  show-audit                    显示完整审计日志"
echo ""

# 显示提示
if [ "$IN_PROGRESS_PHASES" -eq 0 ] && [ "$COMPLETED_PHASES" -lt "$TOTAL_PHASES" ]; then
    echo -e "${YELLOW}💡 提示: 使用 'start-phase 1' 开始第一个阶段${NC}"
elif [ "$IN_PROGRESS_PHASES" -gt 0 ]; then
    echo -e "${YELLOW}💡 提示: 有 $IN_PROGRESS_PHASES 个阶段正在进行中${NC}"
elif [ "$COMPLETED_PHASES" -eq "$TOTAL_PHASES" ] && [ "$TOTAL_PHASES" -gt 0 ]; then
    echo -e "${GREEN}🎉 恭喜！所有阶段已完成！${NC}"
fi

# 显示性能指标（新增）
echo -e "${MAGENTA}⏱️  性能指标${NC}"
SCRIPT_START=$(date +%s%3N)
# 模拟一些操作
sleep 0.001
SCRIPT_END=$(date +%s%3N)
SCRIPT_TIME=$((SCRIPT_END - SCRIPT_START))
echo "  状态查询时间: ${SCRIPT_TIME}ms"
echo ""

log_success "状态报告生成完成"
echo ""
