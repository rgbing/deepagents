#!/bin/bash
# Deep Agent - Performance Monitor
# 用法: deep-monitor

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

DEEP_AGENT_DIR=".deep-agent"
METRICS_FILE="$DEEP_AGENT_DIR/metrics.json"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# 检查 Deep Agent 目录
if [ ! -d "$DEEP_AGENT_DIR" ]; then
    echo -e "${RED}错误: 未找到 Deep Agent 目录${NC}"
    exit 1
fi

# 显示标题
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          Deep Agent 性能监控                          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. 系统资源
echo -e "${BLUE}📊 系统资源${NC}"
echo "  CPU 使用率: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')%"
echo "  内存使用: $(free -h | awk '/^Mem:/{printf "%.1f/%.1fGB (%.1f%%)", $3, $2, $3/$2*100}')"
echo "  磁盘使用: $(df -h . | awk 'NR==2{printf "%s/%s (%.0f%%)", $3, $2, $5}')"
echo ""

# 2. 项目统计
echo -e "${BLUE}📁 项目统计${NC}"
if [ -f "$DEEP_AGENT_DIR/plan.md" ]; then
    TOTAL_PHASES=$(grep -c "### Phase" "$DEEP_AGENT_DIR/plan.md" 2>/dev/null || echo 0)
    echo "  总阶段数: $TOTAL_PHASES"
fi
if [ -f "$DEEP_AGENT_DIR/progress.md" ]; then
    COMPLETED=$(grep -c "状态.*complete" "$DEEP_AGENT_DIR/progress.md" 2>/dev/null || echo 0)
    IN_PROGRESS=$(grep -c "状态.*in_progress" "$DEEP_AGENT_DIR/progress.md" 2>/dev/null || echo 0)
    PENDING=$(grep -c "状态.*pending" "$DEEP_AGENT_DIR/progress.md" 2>/dev/null || echo 0)
    echo "  已完成: $COMPLETED"
    echo "  进行中: $IN_PROGRESS"
    echo "  待处理: $PENDING"
fi

# 文件大小
if [ -d "$DEEP_AGENT_DIR/checkpoints" ]; then
    CHECKPOINT_COUNT=$(ls -1 "$DEEP_AGENT_DIR/checkpoints" 2>/dev/null | wc -l)
    CHECKPOINT_SIZE=$(du -sh "$DEEP_AGENT_DIR/checkpoints" 2>/dev/null | cut -f1)
    echo "  检查点数: $CHECKPOINT_COUNT"
    echo "  检查点大小: $CHECKPOINT_SIZE"
fi

if [ -f "$DEEP_AGENT_DIR/audit.log" ]; then
    AUDIT_LINES=$(wc -l < "$DEEP_AGENT_DIR/audit.log" 2>/dev/null || echo 0)
    AUDIT_SIZE=$(du -h "$DEEP_AGENT_DIR/audit.log" 2>/dev/null | cut -f1)
    echo "  审计日志: $AUDIT_LINES 行 ($AUDIT_SIZE)"
fi
echo ""

# 3. 时间统计
echo -e "${BLUE}⏱️  时间统计${NC}"
if [ -f "$DEEP_AGENT_DIR/progress.md" ]; then
    START_TIME=$(grep "开始时间" "$DEEP_AGENT_DIR/progress.md" | head -1 | cut -d':' -f2- | sed 's/^ *//' || echo "")
    LAST_UPDATE=$(grep "最后更新" "$DEEP_AGENT_DIR/progress.md" | head -1 | cut -d':' -f2- | sed 's/^ *//' || echo "")
    echo "  开始时间: $START_TIME"
    echo "  最后更新: $LAST_UPDATE"

    if [ -n "$START_TIME" ]; then
        # 计算已用时间（简化版本）
        echo "  项目状态: 活跃"
    fi
fi
echo ""

# 4. 性能指标
echo -e "${BLUE}🚀 性能指标${NC}"

# 脚本执行时间
SCRIPT_START=$(date +%s%3N)
# 测试状态查询
if [ -f "$DEEP_AGENT_DIR/scripts/show-status.sh" ]; then
    TIME_START=$(date +%s%3N)
    bash "$DEEP_AGENT_DIR/scripts/show-status.sh" >/dev/null 2>&1 || true
    TIME_END=$(date +%s%3N)
    STATUS_TIME=$((TIME_END - TIME_START))
    echo "  状态查询: ${STATUS_TIME}ms"
fi
SCRIPT_END=$(date +%s%3N)
OVERHEAD=$((SCRIPT_END - SCRIPT_START))

echo "  监控开销: ${OVERHEAD}ms"
echo ""

# 5. 健康检查
echo -e "${BLUE}🏥 健康检查${NC}"
HEALTH_SCORE=100
ISSUES=()

# 检查必要文件
for file in plan.md progress.md context.md; do
    if [ ! -f "$DEEP_AGENT_DIR/$file" ]; then
        ISSUES+=("缺失文件: $file")
        HEALTH_SCORE=$((HEALTH_SCORE - 20))
    fi
done

# 检查目录
for dir in checkpoints subagents; do
    if [ ! -d "$DEEP_AGENT_DIR/$dir" ]; then
        ISSUES+=("缺失目录: $dir")
        HEALTH_SCORE=$((HEALTH_SCORE - 10))
    fi
done

# 检查文件大小
if [ -f "$DEEP_AGENT_DIR/audit.log" ]; then
    AUDIT_SIZE=$(stat -f%z "$DEEP_AGENT_DIR/audit.log" 2>/dev/null || stat -c%s "$DEEP_AGENT_DIR/audit.log" 2>/dev/null || echo 0)
    if [ "$AUDIT_SIZE" -gt 10485760 ]; then  # 10MB
        ISSUES+=("审计日志过大 (>10MB)")
        HEALTH_SCORE=$((HEALTH_SCORE - 5))
    fi
fi

# 显示健康状态
if [ $HEALTH_SCORE -ge 90 ]; then
    echo -e "  ${GREEN}健康评分: $HEALTH_SCORE/100${NC}"
elif [ $HEALTH_SCORE -ge 70 ]; then
    echo -e "  ${YELLOW}健康评分: $HEALTH_SCORE/100${NC}"
else
    echo -e "  ${RED}健康评分: $HEALTH_SCORE/100${NC}"
fi

# 显示问题
if [ ${#ISSUES[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}发现问题:${NC}"
    for issue in "${ISSUES[@]}"; do
        echo "  ⚠️  $issue"
    done
fi
echo ""

# 6. 建议
echo -e "${BLUE}💡 优化建议${NC}"

if [ "$COMPLETED" -lt "$TOTAL_PHASES" ] && [ "$TOTAL_PHASES" -gt 0 ]; then
    PROGRESS=$((COMPLETED * 100 / TOTAL_PHASES))
    if [ "$PROGRESS" -lt 50 ]; then
        echo "  📈 项目进度较低 ($PROGRESS%)，建议加快执行"
    fi
fi

if [ "$AUDIT_LINES" -gt 1000 ]; then
    echo "  📝 审计日志较长，建议定期归档"
fi

if [ ${#ISSUES[@]} -gt 0 ]; then
    echo "  🔧 发现 ${#ISSUES[@]} 个问题，建议尽快修复"
else
    echo "  ✅ 系统运行良好，继续保持"
fi
echo ""

log_success "监控完成"
