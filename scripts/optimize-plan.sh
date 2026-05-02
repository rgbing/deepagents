#!/bin/bash
# Deep Agent - Optimize Plan Script
# 用法: optimize-plan

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

# 检查 Deep Agent 目录是否存在
if [ ! -d "$DEEP_AGENT_DIR" ]; then
    echo -e "${RED}错误: 未找到 Deep Agent 目录${NC}"
    echo "请先运行: init-plan <task_description>"
    exit 1
fi

echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Deep Agent 计划优化${NC}"
echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
echo ""

# 分析当前计划
echo -e "${BLUE}1. 分析当前计划...${NC}"

TOTAL_PHASES=$(grep -c "### Phase" "$PLAN_FILE" || true)
COMPLETED_PHASES=$(grep -c "状态.*complete" "$PROGRESS_FILE" || true)
IN_PROGRESS_PHASES=$(grep -c "状态.*in_progress" "$PROGRESS_FILE" || true)
PENDING_PHASES=$(grep -c "状态.*pending" "$PROGRESS_FILE" || true)

echo "  总阶段数: $TOTAL_PHASES"
echo "  已完成: $COMPLETED_PHASES"
echo "  进行中: $IN_PROGRESS_PHASES"
echo "  待处理: $PENDING_PHASES"
echo ""

# 识别并行机会
echo -e "${BLUE}2. 识别并行机会...${NC}"

# 查找没有依赖的阶段
PARALLEL_OPPORTUNITIES=0
grep "### Phase" "$PLAN_FILE" | while read -r line; do
    phase_id=$(echo "$line" | grep -oE 'ID: [0-9]+' | grep -oE '[0-9]+')
    phase_status=$(grep "### Phase $phase_id" "$PROGRESS_FILE" -A 10 | grep "状态" | head -1 | cut -d':' -f2 | sed 's/^ *\*//; s/\*\* *$//')

    if [ "$phase_status" = "pending" ]; then
        dependencies=$(grep "### Phase $phase_id" "$PLAN_FILE" -A 10 | grep "依赖" | head -1 | cut -d':' -f2 | sed 's/^ *//')

        if [ "$dependencies" = "无" ] || [ -z "$dependencies" ]; then
            echo -e "  ${GREEN}✓ Phase $phase_id${NC} - 无依赖，可以并行执行"
            ((PARALLEL_OPPORTUNITIES++))
        fi
    fi
done

echo ""

# 估算总时间
echo -e "${BLUE}3. 估算执行时间...${NC}"

TOTAL_ESTIMATED=0
grep "### Phase" "$PLAN_FILE" | while read -r line; do
    phase_id=$(echo "$line" | grep -oE 'ID: [0-9]+' | grep -oE '[0-9]+')
    estimated=$(grep "### Phase $phase_id" "$PLAN_FILE" -A 10 | grep "预计时间" | head -1 | cut -d':' -f2 | sed 's/^ *//')
    # 提取数字（假设格式为 "15m", "2h", "30m" 等）
    if [[ $estimated =~ ([0-9]+)m ]]; then
        TOTAL_ESTIMATED=$((TOTAL_ESTIMATED + ${BASH_REMATCH[1]}))
    elif [[ $estimated =~ ([0-9]+)h ]]; then
        TOTAL_ESTIMATED=$((TOTAL_ESTIMATED + ${BASH_REMATCH[1]} * 60))
    fi
done

echo "  预计总时间: ${TOTAL_ESTIMATED}m ($((TOTAL_ESTIMATED / 60))h $((TOTAL_ESTIMATED % 60))m)"
echo ""

# 优化建议
echo -e "${BLUE}4. 生成优化建议...${NC}"

OPTIMIZATIONS=0

# 建议 1: 并行化
if [ $PARALLEL_OPPORTUNITIES -gt 1 ]; then
    echo -e "  ${GREEN}[并行化]${NC} 检测到 $PARALLEL_OPPORTUNITIES 个可并行阶段"
    echo "    建议: 使用并行委托同时执行这些阶段"
    echo "    命令: delegate <phase1> <phase2> --parallel"
    ((OPTIMIZATIONS++))
fi

# 建议 2: 合并小阶段
echo "  ${GREEN}[合并阶段]${NC} 检查是否有可以合并的小阶段"
echo "    建议: 将相似或连续的小阶段合并以提高效率"
((OPTIMIZATIONS++))

# 建议 3: 添加检查点
echo "  ${GREEN}[检查点]${NC} 建议在关键阶段后添加保存点"
echo "    建议: 在每个主要阶段完成后保存上下文"
echo "    命令: complete-phase <id>; save-context milestone-<id>"
((OPTIMIZATIONS++))

# 建议 4: 资源分配
echo -e "  ${GREEN}[资源分配]${NC} 根据阶段复杂度优化子代理分配"
echo "    建议: 复杂任务分配给 developer，研究任务分配给 researcher"
((OPTIMIZATIONS++))

# 建议 5: 缓存策略
echo -e "  ${GREEN}[缓存策略]${NC} 识别可缓存的重复操作"
echo "    建议: 缓存文件读取、搜索结果等"
((OPTIMIZATIONS++))

echo ""
echo -e "${BLUE}共生成 $OPTIMIZATIONS 条优化建议${NC}"
echo ""

# 创建优化后的计划
echo -e "${BLUE}5. 生成优化后的计划结构...${NC}"

OPTIMIZED_PLAN="$DEEP_AGENT_DIR/plan-optimized.md"

cat > "$OPTIMIZED_PLAN" << 'EOF'
# Deep Agent 优化计划

## 优化策略
1. **并行执行**: 识别无依赖阶段并行执行
2. **智能委托**: 根据任务类型选择最合适的子代理
3. **上下文管理**: 在关键点保存和恢复上下文
4. **错误处理**: 实现重试和回退机制
5. **资源优化**: 优化工具和资源分配

## 优化后的执行流程
EOF

# 添加并行执行组
cat >> "$OPTIMIZED_PLAN" << EOF
### 并行执行组 1
- **阶段**: $(grep "依赖.*无" "$PLAN_FILE" -B 5 | grep "### Phase" | sed 's/### Phase //' | sed 's/ \[.*\]//' | tr '\n' ', ' | sed 's/,$//')
- **策略**: 同时执行这些阶段
- **预期加速**: ~${PARALLEL_OPPORTUNITIES}x

### 串行执行组
- 按依赖关系顺序执行剩余阶段

EOF

# 添加资源分配建议
cat >> "$OPTIMIZED_PLAN" << 'EOF'
## 推荐的子代理分配

| 阶段类型 | 推荐子代理 | 原因 |
|----------|-----------|------|
| 信息收集 | researcher | 专门用于研究和信息处理 |
| 代码编写 | developer | 专门用于编码和开发 |
| 架构设计 | orchestrator | 需要全局视野和协调能力 |
| 测试验证 | reviewer | 专门用于质量保证 |
| 数据分析 | analyst | 专门用于数据处理和分析 |

## 检查点策略

| 检查点 | 时机 | 内容 |
|--------|------|------|
| CP-1 | 需求分析后 | requirements.md, design.md |
| CP-2 | 核心实现后 | 源代码, 测试文件 |
| CP-3 | 全部完成后 | 完整项目, 文档 |

## 性能目标

- **并行加速比**: > 1.5x
- **子代理成功率**: > 90%
- **上下文利用率**: < 80%
- **总执行时间**: < 预计时间的 80%

---
*此计划由 Deep Agent 自动生成和优化*
EOF

# 添加到审计日志
echo "| $(date '+%Y-%m-%d %H:%M:%S') | optimize-plan | system | - | ✅ | 优化计划，生成 $OPTIMIZATIONS 条建议 |" >> "$DEEP_AGENT_DIR/audit.log"

# 添加到会话日志
echo "" >> "$DEEP_AGENT_DIR/session.log"
echo "### 优化计划" >> "$DEEP_AGENT_DIR/session.log"
echo "- 时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$DEEP_AGENT_DIR/session.log"
echo "- 总阶段数: $TOTAL_PHASES" >> "$DEEP_AGENT_DIR/session.log"
echo "- 并行机会: $PARALLEL_OPPORTUNITIES" >> "$DEEP_AGENT_DIR/session.log"
echo "- 优化建议: $OPTIMIZATIONS" >> "$DEEP_AGENT_DIR/session.log"

echo -e "${GREEN}✓ 计划优化完成${NC}"
echo ""
echo -e "${YELLOW}优化结果:${NC}"
echo "  - 识别了 $PARALLEL_OPPORTUNITIES 个可并行阶段"
echo "  - 生成了 $OPTIMIZATIONS 条优化建议"
echo "  - 创建了优化后的计划结构"
echo ""
echo -e "${BLUE}查看优化后的计划:${NC}"
echo "  cat $OPTIMIZED_PLAN"
echo ""
echo -e "${BLUE}应用优化建议:${NC}"
echo "  根据上述建议手动调整 plan.md 文件"
echo ""
