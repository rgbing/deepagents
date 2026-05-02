---
name: deep-agent
description: Deep Agent - 深度优化的多代理协调框架。基于 LangChain Deep Agents 概念，提供规划、文件系统操作、Shell 访问、子代理委托、智能上下文管理和自动摘要等核心功能。适用于复杂的多步骤任务、研究项目、代码开发和自动化工作流。
version: "1.0.0"
category: autonomous-ai-agents
user-invocable: true
allowed-tools: "delegate_task, terminal, read_file, write_file, search_files, execute_code, browser_navigate, browser_click, browser_type, browser_vision, patch, skill_view, memory, session_search"
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: "if [ -f .deep-agent/plan.md ]; then echo '[Deep Agent] Active Plan:'; cat .deep-agent/plan.md | head -80; echo ''; echo '[Deep Agent] Recent Progress:'; tail -30 .deep-agent/progress.md 2>/dev/null; echo ''; echo '[Deep Agent] Continue from current phase. Use show-status for details.'; fi"
  PreToolUse:
    - matcher: "delegate_task|terminal"
      hooks:
        - type: command
          command: "cat .deep-agent/plan.md 2>/dev/null | head -50 || echo '[Deep Agent] No active plan. Create one with: init-plan <task_description>'"
  PostToolUse:
    - matcher: "delegate_task|terminal|write_file|patch"
      hooks:
        - type: command
          command: "if [ -f .deep-agent/plan.md ]; then echo '[Deep Agent] Update progress.md and review plan.md. Mark completed phases.'; fi"
  Stop:
    - hooks:
        - type: command
          command: "if [ -f .deep-agent/.active ]; then echo '[Deep Agent] Session ending. Saving state...'; echo \"$(date '+%Y-%m-%d %H:%M:%S') - Session stopped\" >> .deep-agent/session.log; rm -f .deep-agent/.active; fi"
metadata:
  author: "Hermes Agent"
  langchain-compat: true
  requires-python: ">=3.9"
  features:
    - planning
    - filesystem
    - shell-access
    - sub-agents
    - context-management
    - auto-summarization
---

# Deep Agent

深度优化的多代理协调框架，灵感来自 LangChain Deep Agents，专为 Hermes Agent 设计。

## 核心理念

```
Deep Agent = Planning + Execution + Coordination + Optimization

- Planning: 将复杂任务分解为可执行的子任务
- Execution: 通过子代理并行或串行执行任务
- Coordination: 协调多个子代理的工作流程
- Optimization: 自动优化资源分配和执行策略
```

## 快速开始

### 初始化 Deep Agent

对于任何复杂任务（3+ 步骤），首先初始化计划：

```bash
# 创建新的计划
init-plan "构建一个 Python Web 应用"
```

这将创建 `.deep-agent/` 目录结构并生成初始计划文件。

### 核心命令

| 命令 | 用途 |
|------|------|
| `init-plan <task>` | 初始化新任务计划 |
| `show-status` | 显示当前状态和进度 |
| `add-phase <title>` | 添加新阶段 |
| `complete-phase <id>` | 标记阶段完成 |
| `delegate <phase-id>` | 委托阶段给子代理 |
| `optimize-plan` | 优化执行计划 |
| `save-context` | 保存当前上下文 |
| `load-context` | 加载保存的上下文 |

## 深度优化特性

### 1. 智能规划引擎

Deep Agent 使用分层规划策略：

```
Level 1: 宏任务 (Macro Tasks)
  └─ Level 2: 阶段 (Phases)
      └─ Level 3: 子任务 (Subtasks)
          └─ Level 4: 原子操作 (Atomic Operations)
```

**规划原则：**
- 每个阶段应该是独立的、可验证的
- 子任务应该可以在 5-10 分钟内完成
- 原子操作应该是单一工具调用
- 识别并标记可并行化的任务

**规划模板：**
```markdown
## Phase 1: 需求分析 [ID: 1]
- Status: pending
- Priority: high
- Estimated: 15m
- Dependencies: none
- Subtasks:
  - 1.1 收集用户需求
  - 1.2 分析技术栈
  - 1.3 评估可行性
```

### 2. 高效子代理协调

#### 子代理类型

| 类型 | 用途 | 工具集 |
|------|------|--------|
| **researcher** | 信息收集、文档研究 | web, search, read_file |
| **developer** | 代码编写、测试 | terminal, write_file, patch |
| **analyst** | 数据分析、报告生成 | execute_code, search_files |
| **reviewer** | 代码审查、质量检查 | read_file, search_files |
| **orchestrator** | 协调其他子代理 | delegate_task, memory |

#### 委托策略

```python
# 串行委托（顺序执行）
delegate_phase(phase_id, mode="sequential")

# 并行委托（同时执行）
delegate_phase(phase_id, mode="parallel")

# 条件委托（基于结果）
delegate_phase(phase_id, mode="conditional", condition="success")
```

#### 子代理最佳实践

1. **隔离上下文**：每个子代理有自己的上下文窗口
2. **明确目标**：为每个子代理提供清晰的单一目标
3. **限制工具**：只提供必要的工具，减少混乱
4. **设置超时**：为每个子代理设置合理的超时时间
5. **错误处理**：定义子代理失败时的回退策略

### 3. 上下文管理

#### 自动摘要

当对话超过阈值时，自动总结上下文：

```markdown
## Context Summary (Generated at 2026-04-30 14:30)

### Completed Work
- Phase 1: ✅ 需求分析完成
- Phase 2: ✅ 架构设计完成
- Phase 3: 🔄 实现中

### Key Decisions
- 使用 FastAPI 作为 Web 框架
- 采用 PostgreSQL 作为数据库
- 前端使用 React + TypeScript

### Pending Work
- 实现 API 端点
- 编写单元测试
- 部署到生产环境
```

#### 上下文保存点

```bash
# 在关键点保存上下文
save-context checkpoint-1

# 恢复上下文
load-context checkpoint-1
```

### 4. 性能优化

#### 并行执行

识别独立的子任务并并行执行：

```python
# 并行执行多个子代理
tasks = [
    {"goal": "实现用户认证", "phase_id": "3.1"},
    {"goal": "设计数据库 schema", "phase_id": "3.2"},
    {"goal": "编写 API 文档", "phase_id": "3.3"},
]

# 使用 delegate_task 的 tasks 参数并行执行
delegate_task(tasks=tasks)
```

#### 缓存策略

```python
# 缓存常用操作结果
@cached(ttl=3600)  # 缓存 1 小时
def get_file_info(filepath):
    return read_file(filepath)
```

#### 资源限制

```python
# 为每个子代理设置资源限制
subagent_config = {
    "max_tokens": 4000,
    "max_tools": 10,
    "timeout": 300,
    "memory_limit": "1GB"
}
```

### 5. 安全性

#### 工具权限

```yaml
# 为不同子代理设置不同的工具权限
permissions:
  researcher:
    allowed_tools: [web, search, read_file]
    denied_tools: [write_file, terminal]
  developer:
    allowed_tools: [terminal, write_file, patch, execute_code]
    denied_tools: []
  reviewer:
    allowed_tools: [read_file, search_files]
    denied_tools: [write_file, terminal]
```

#### 沙箱执行

```bash
# 在沙箱中执行危险命令
sandbox-run "rm -rf /tmp/test"
```

#### 审计日志

```markdown
## Audit Log

| Timestamp | Action | Agent | Success | Notes |
|-----------|--------|-------|---------|-------|
| 2026-04-30 14:00 | execute | developer | ✅ | Created main.py |
| 2026-04-30 14:05 | write_file | developer | ✅ | Updated config.yaml |
| 2026-04-30 14:10 | terminal | developer | ❌ | Command failed, retrying |
```

## 文件结构

```
.deep-agent/
├── plan.md              # 主计划文件
├── progress.md          # 进度跟踪
├── context.md           # 当前上下文摘要
├── audit.log            # 审计日志
├── checkpoints/         # 上下文保存点
│   ├── checkpoint-1.md
│   └── checkpoint-2.md
├── subagents/           # 子代理配置
│   ├── researcher.yaml
│   ├── developer.yaml
│   └── analyst.yaml
└── .active             # 活动会话标记
```

## 工作流程

### 标准工作流

```
1. init-plan <task>
   ↓
2. 审查和优化计划
   ↓
3. 逐阶段执行（委托给子代理）
   ↓
4. 监控进度和调整
   ↓
5. 完成和总结
```

### 并行工作流

```
1. init-plan <task>
   ↓
2. 识别可并行任务
   ↓
3. 并行委托多个子代理
   ↓
4. 汇总结果
   ↓
5. 合并和验证
```

### 迭代工作流

```
1. init-plan <task>
   ↓
2. 执行第一阶段
   ↓
3. 基于结果更新计划
   ↓
4. 执行第二阶段
   ↓
5. 重复直到完成
```

## 最佳实践

### 规划阶段

1. **明确目标**：每个阶段都有清晰的成功标准
2. **估计时间**：为每个阶段提供时间估计
3. **识别依赖**：标记阶段之间的依赖关系
4. **设置优先级**：高优先级任务优先执行
5. **考虑风险**：识别潜在的风险和回退计划

### 执行阶段

1. **委托而非执行**：尽可能委托给专门的子代理
2. **并行化**：识别并并行执行独立任务
3. **持续监控**：定期检查进度和调整
4. **记录决策**：记录所有重要决策及其理由
5. **处理错误**：优雅地处理错误并继续

### 完成阶段

1. **验证结果**：确保所有阶段都完成并验证
2. **生成报告**：创建详细的完成报告
3. **保存上下文**：保存最终上下文供将来参考
4. **清理资源**：清理临时文件和资源
5. **总结经验**：记录学到的经验和改进建议

## 错误处理

### 3 次重试规则

```
ATTEMPT 1: 直接执行
  → 如果失败，记录错误

ATTEMPT 2: 调整后重试
  → 修改参数或方法
  → 如果仍失败，尝试替代方案

ATTEMPT 3: 完全替代
  → 使用不同的工具或方法
  → 如果失败，请求用户介入
```

### 错误分类

| 类型 | 处理策略 |
|------|----------|
| **临时错误**（网络超时） | 自动重试 |
| **配置错误** | 请求用户提供正确配置 |
| **权限错误** | 检查并修复权限 |
| **逻辑错误** | 修正逻辑后重试 |
| **未知错误** | 请求用户帮助 |

## 监控和调试

### 状态查看

```bash
# 查看整体状态
show-status

# 查看特定阶段
show-phase <phase-id>

# 查看子代理状态
show-subagent <agent-name>

# 查看审计日志
show-audit
```

### 调试模式

```bash
# 启用调试日志
export DEEP_AGENT_DEBUG=1

# 查看详细执行日志
tail -f .deep-agent/execution.log
```

## 集成

### 与其他技能集成

- **planning-with-files**: 使用其文件规划系统
- **superpowers**: 使用其 TDD 和代码审查流程
- **agentmemory**: 使用其记忆系统存储长期知识

### MCP 集成

Deep Agent 支持 MCP（Model Context Protocol）服务器：

```python
from deepagents import create_deep_agent
from langchain_mcp_adapters import McpToolkit

agent = create_deep_agent(
    tools=[McpToolkit("filesystem"), McpToolkit("database")]
)
```

## 性能指标

跟踪以下指标以优化性能：

| 指标 | 目标 | 测量方法 |
|------|------|----------|
| **任务完成时间** | < 预计时间 120% | 记录开始和结束时间 |
| **子代理成功率** | > 90% | 统计成功/失败次数 |
| **并行加速比** | > 1.5x | 比较串行和并行执行时间 |
| **上下文利用率** | < 80% | 监控 token 使用 |
| **错误恢复时间** | < 5 min | 测量从错误到恢复的时间 |

## 扩展性

### 自定义子代理

创建自定义子代理类型：

```yaml
# .deep-agent/subagents/custom.yaml
name: custom-agent
description: 我的自定义子代理
allowed_tools: [tool1, tool2, tool3]
system_prompt: |
  你是一个专门处理 X 任务的代理。
  使用工具 Y 来完成工作。
  遵循以下原则：...
max_tokens: 2000
timeout: 180
```

### 自定义工具

注册自定义工具：

```python
from deepagents import Tool

@Tool(name="custom_tool", description="My custom tool")
def custom_tool(param: str) -> str:
    """执行自定义操作"""
    # 实现逻辑
    return result
```

## 故障排除

### 常见问题

**Q: 子代理失败怎么办？**
A: 检查审计日志，使用不同的子代理类型，或调整参数重试。

**Q: 上下文溢出怎么办？**
A: 启用自动摘要，手动保存上下文，或增加 token 限制。

**Q: 并行任务冲突怎么办？**
A: 使用文件锁，添加同步点，或改为串行执行。

**Q: 计划不完整怎么办？**
A: 使用 `add-phase` 添加新阶段，或重新规划。

### Shell 脚本兼容性问题

**问题**: 某些 grep 和 sed 命令在不同系统上可能不兼容，特别是：
- `grep -oP` (Perl 兼容正则表达式) 在某些系统上不可用
- 复杂的 sed 正则表达式（包含 markdown `**` 和 `[` 字符）会失败

**解决方案**:

1. **替换 grep -oP**:
   ```bash
   # ❌ 不兼容
   phase_id=$(echo "$line" | grep -oP 'ID: \K[0-9]+')
   
   # ✅ 兼容
   phase_id=$(echo "$line" | grep -oE 'ID: [0-9]+' | grep -oE '[0-9]+')
   ```

2. **使用 cut 替代复杂 sed**:
   ```bash
   # ❌ 失败（markdown ** 字符导致正则错误）
   status=$(echo "$line" | sed 's/.*- **状态**: //')
   
   # ✅ 兼容
   status=$(echo "$line" | cut -d':' -f2 | sed 's/^ *\*\*//; s/\*\* *$//')
   
   # ❌ 失败（markdown [ 字符导致正则错误）
   phase_title=$(echo "$line" | sed 's/### Phase [0-9]*: //' | sed 's/ \[ID: [0-9]*\]//')
   
   # ✅ 兼容
   phase_title=$(echo "$line" | cut -d':' -f2- | cut -d'[' -f1 | sed 's/^ *//; s/ *$//')
   ```

3. **受影响的脚本**:
   - `scripts/show-status.sh` - 用于提取阶段标题、ID 和状态
   - `scripts/optimize-plan.sh` - 用于提取阶段 ID 和元数据
   - 其他处理 markdown 格式文件的脚本

**最佳实践**:
- 在编写 shell 脚本时，优先使用 `cut` 和基本 `grep` 选项
- 避免在 sed 中使用 markdown 特殊字符（`**`, `[`, `]`, `_` 等）
- 使用 `grep -oE` (扩展正则) 而非 `grep -oP` (Perl 正则)
- 在开发过程中测试脚本的实际输出，而不仅仅是语法检查

**更多参考**:
- 详见 `hermes-agent` 技能中的 `references/script-compatibility-issues.md`，包含更多常见的 shell 脚本兼容性问题和解决方案

## 示例

### 示例 1: 构建简单的 Web 应用

```bash
# 初始化计划
init-plan "构建一个 Todo API"

# 查看生成的计划
cat .deep-agent/plan.md

# 执行计划
execute-plan

# 监控进度
show-status
```

### 示例 2: 并行数据分析

```bash
# 初始化计划
init-plan "分析多个数据集"

# 手动编辑计划以启用并行
# 在 plan.md 中标记可并行任务

# 执行并行计划
execute-plan --parallel

# 查看结果
cat .deep-agent/progress.md
```

### 示例 3: 研究项目

```bash
# 初始化研究计划
init-plan "研究 AI 在医疗诊断中的应用"

# 委托研究阶段给多个研究者
delegate 1 2 3 --parallel

# 委托分析阶段给分析师
delegate 4 --agent analyst

# 委托报告编写给作者
delegate 5 --agent writer
```

## 参考资料

- [LangChain Deep Agents 文档](https://docs.langchain.com/oss/python/deepagents/overview)
- [LangGraph 文档](https://docs.langchain.com/oss/python/langgraph/overview)
- [Agent Skills 规范](https://agentskills.io/home)
- [Hermes Agent 文档](https://hermes-agent.nousresearch.com/docs)

## 版本历史

- **1.0.0** (2026-04-30): 初始版本
  - 基础规划引擎
  - 子代理协调
  - 上下文管理
  - 性能优化
  - 安全特性

## 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 仓库
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License - 与 LangChain Deep Agents 保持一致

## 安全策略

Deep Agent 遵循 "信任 LLM" 模型。在工具/沙箱级别强制边界，而不是期望模型自我监管。详见 [安全策略](https://github.com/langchain-ai/deepagents?tab=security-ov-file)。

---

**记住**: Deep Agent 的力量在于规划和协调，而不仅仅是执行。花时间做好规划，执行会变得简单得多。
