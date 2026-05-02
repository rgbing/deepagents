#!/bin/bash
# Deep Agent - Initialize Plan Script
# 用法: init-plan <task_description>

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供任务描述${NC}"
    echo "用法: init-plan <task_description>"
    echo "示例: init-plan '构建一个 Python Web 应用'"
    exit 1
fi

TASK_DESC="$1"
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M:%S')
DEEP_AGENT_DIR=".deep-agent"

# 创建目录结构
echo -e "${BLUE}初始化 Deep Agent 计划...${NC}"
mkdir -p "$DEEP_AGENT_DIR"/{checkpoints,subagents}

# 标记活动会话
touch "$DEEP_AGENT_DIR/.active"

# 创建主计划文件
cat > "$DEEP_AGENT_DIR/plan.md" << EOF
# Deep Agent 计划

## 任务描述
${TASK_DESC}

## 元信息
- **创建日期**: ${DATE} ${TIME}
- **状态**: active
- **当前阶段**: Phase 1

## 阶段列表

### Phase 1: 需求分析 [ID: 1]
- **状态**: pending
- **优先级**: high
- **预计时间**: 15m
- **依赖**: 无
- **描述**: 明确任务需求、目标和约束条件
- **子任务**:
  - 1.1 收集和分析需求
  - 1.2 识别技术要求
  - 1.3 定义成功标准
- **可委托给**: researcher
- **输出**:
  - requirements.md

### Phase 2: 规划和设计 [ID: 2]
- **状态**: pending
- **优先级**: high
- **预计时间**: 20m
- **依赖**: Phase 1
- **描述**: 制定详细的执行计划和技术设计
- **子任务**:
  - 2.1 分解任务为子任务
  - 2.2 选择技术栈
  - 2.3 设计架构
- **可委托给**: orchestrator, developer
- **输出**:
  - design.md
  - architecture.md

### Phase 3: 实施 [ID: 3]
- **状态**: pending
- **优先级**: high
- **预计时间**: 30m
- **依赖**: Phase 2
- **描述**: 根据设计和计划实现功能
- **子任务**:
  - 3.1 设置项目结构
  - 3.2 实现核心功能
  - 3.3 编写测试
- **可委托给**: developer
- **输出**:
  - 源代码文件
  - 测试文件
  - 配置文件

### Phase 4: 测试和验证 [ID: 4]
- **状态**: pending
- **优先级**: medium
- **预计时间**: 20m
- **依赖**: Phase 3
- **描述**: 测试实现的功能并验证是否满足需求
- **子任务**:
  - 4.1 运行单元测试
  - 4.2 进行集成测试
  - 4.3 验证功能完整性
- **可委托给**: reviewer, analyst
- **输出**:
  - test-report.md
  - validation-report.md

### Phase 5: 文档和总结 [ID: 5]
- **状态**: pending
- **优先级**: low
- **预计时间**: 15m
- **依赖**: Phase 4
- **描述**: 编写文档和总结项目
- **子任务**:
  - 5.1 编写 API 文档
  - 5.2 创建用户指南
  - 5.3 总结经验教训
- **可委托给**: writer, orchestrator
- **输出**:
  - docs/
  - summary.md

## 并行机会

- Phase 3 的某些子任务可以并行执行
- Phase 4 的测试可以并行运行

## 优化建议

1. 识别可自动化的步骤
2. 重用现有组件和模式
3. 考虑使用缓存提高性能
4. 设置适当的错误处理和重试机制

## 风险和缓解

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|----------|
| 需求变更 | 中 | 高 | 定期审查需求，保持灵活性 |
| 技术困难 | 中 | 中 | 预先研究技术方案 |
| 时间超限 | 低 | 中 | 定期检查进度，调整优先级 |

## 决策日志

| 时间 | 决策 | 理由 |
|------|------|------|
| ${TIME} | 初始化计划 | 开始新任务：${TASK_DESC} |
EOF

# 创建进度文件
cat > "$DEEP_AGENT_DIR/progress.md" << EOF
# Deep Agent 进度跟踪

## 会话信息
- **开始时间**: ${DATE} ${TIME}
- **最后更新**: ${DATE} ${TIME}
- **总进度**: 0% (0/5 phases complete)

## 阶段进度

### Phase 1: 需求分析 [ID: 1]
- **状态**: pending
- **开始时间**: -
- **完成时间**: -
- **耗时**: -
- **执行者**: -
- **输出**: -
- **备注**:

### Phase 2: 规划和设计 [ID: 2]
- **状态**: pending
- **开始时间**: -
- **完成时间**: -
- **耗时**: -
- **执行者**: -
- **输出**: -
- **备注**:

### Phase 3: 实施 [ID: 3]
- **状态**: pending
- **开始时间**: -
- **完成时间**: -
- **耗时**: -
- **执行者**: -
- **输出**: -
- **备注**:

### Phase 4: 测试和验证 [ID: 4]
- **状态**: pending
- **开始时间**: -
- **完成时间**: -
- **耗时**: -
- **执行者**: -
- **输出**: -
- **备注**:

### Phase 5: 文档和总结 [ID: 5]
- **状态**: pending
- **开始时间**: -
- **完成时间**: -
- **耗时**: -
- **执行者**: -
- **输出**: -
- **备注**:

## 测试结果

| 测试 | 预期 | 实际 | 状态 | 时间 |
|------|------|------|------|------|
| | | | | |

## 错误日志

| 时间 | 阶段 | 错误 | 重试次数 | 解决方案 |
|------|------|------|----------|----------|
| | | | | |

## 资源使用

- **总预计时间**: 100m
- **已用时间**: 0m
- **剩余时间**: 100m
- **子代理调用次数**: 0
- **工具调用次数**: 0

## 优化指标

- **并行加速比**: N/A
- **子代理成功率**: N/A
- **平均响应时间**: N/A
EOF

# 创建上下文文件
cat > "$DEEP_AGENT_DIR/context.md" << EOF
# Deep Agent 上下文

## 当前会话
- **开始时间**: ${DATE} ${TIME}
- **任务**: ${TASK_DESC}
- **当前阶段**: Phase 1

## 已完成工作
无

## 当前状态
等待开始 Phase 1: 需求分析

## 待办事项
1. 开始需求分析
2. 收集相关文档和信息
3. 明确技术要求
4. 定义成功标准

## 关键决策
无

## 待解决的问题
无

## 上下文摘要
初始化完成，准备开始执行计划。

## 下一步行动
使用 \`start-phase 1\` 开始第一阶段，或委托给 researcher 子代理。
EOF

# 创建审计日志
cat > "$DEEP_AGENT_DIR/audit.log" << EOF
# Deep Agent 审计日志

| 时间戳 | 操作 | 代理 | 阶段 | 成功 | 备注 |
|--------|------|------|------|------|------|
| ${DATE} ${TIME} | init-plan | system | - | ✅ | 初始化计划: ${TASK_DESC} |
EOF

# 创建会话日志
cat > "$DEEP_AGENT_DIR/session.log" << EOF
# Deep Agent 会话日志

## Session ${DATE}-${TIME}

### 初始化
- 任务: ${TASK_DESC}
- 时间: ${DATE} ${TIME}
- 操作: 初始化 Deep Agent 计划

### 活动记录
EOF

# 创建默认子代理配置
cat > "$DEEP_AGENT_DIR/subagents/researcher.yaml" << EOF
name: researcher
description: 专门用于信息收集和文档研究的子代理
system_prompt: |
  你是一个专业的研究者。你的任务是：
  1. 收集和分析信息
  2. 阅读和理解文档
  3. 总结和提取关键信息
  4. 提供准确和可靠的答案

  原则：
  - 验证信息来源
  - 引用参考资料
  - 保持客观和准确
  - 提供清晰的结构化输出

allowed_tools:
  - web
  - search
  - read_file
  - browser_navigate
  - browser_vision

denied_tools:
  - write_file
  - terminal
  - execute_code

max_tokens: 4000
timeout: 300
EOF

cat > "$DEEP_AGENT_DIR/subagents/developer.yaml" << EOF
name: developer
description: 专门用于代码编写和开发的子代理
system_prompt: |
  你是一个专业的开发者。你的任务是：
  1. 编写高质量、可维护的代码
  2. 遵循最佳实践和设计模式
  3. 编写测试和文档
  4. 调试和修复问题

  原则：
  - 编写清晰、简洁的代码
  - 遵循项目约定和风格指南
  - 考虑性能和安全性
  - 编写可测试的代码

allowed_tools:
  - terminal
  - write_file
  - patch
  - execute_code
  - read_file
  - search_files

denied_tools:
  - web
  - search

max_tokens: 6000
timeout: 600
EOF

cat > "$DEEP_AGENT_DIR/subagents/orchestrator.yaml" << EOF
name: orchestrator
description: 协调其他子代理和管理整体工作流
system_prompt: |
  你是一个专业的协调者。你的任务是：
  1. 协调多个子代理的工作
  2. 管理任务依赖和顺序
  3. 监控进度和调整计划
  4. 汇总和整合结果

  原则：
  - 保持全局视野
  - 优化资源分配
  - 处理依赖关系
  - 确保质量和效率

allowed_tools:
  - delegate_task
  - memory
  - read_file
  - write_file
  - terminal

denied_tools: []

max_tokens: 4000
timeout: 300
EOF

# 成功消息
echo -e "${GREEN}✓ Deep Agent 计划已初始化${NC}"
echo -e "${BLUE}任务: ${TASK_DESC}${NC}"
echo -e "${BLUE}目录: ${DEEP_AGENT_DIR}/${NC}"
echo ""
echo -e "${YELLOW}下一步操作:${NC}"
echo "  1. 查看计划: cat .deep-agent/plan.md"
echo "  2. 开始阶段: start-phase 1"
echo "  3. 委托任务: delegate 1 --agent researcher"
echo "  4. 查看状态: show-status"
echo ""
echo -e "${GREEN}Deep Agent 准备就绪！${NC}"
