# Deep Agent - Quick Reference

## 快速开始

```bash
# 1. 初始化计划
init-plan "<task_description>"

# 2. 查看状态
show-status

# 3. 开始/委托阶段
start-phase 1
# 或
delegate 1 --agent researcher

# 4. 监控进度
show-status

# 5. 完成阶段
complete-phase 1

# 6. 保存上下文
save-context milestone-1

# 7. 优化计划
optimize-plan
```

## 命令速查

### 初始化

| 命令 | 用途 |
|------|------|
| `init-plan <task>` | 初始化新任务计划 |

### 执行

| 命令 | 用途 |
|------|------|
| `start-phase <id>` | 开始指定阶段 |
| `complete-phase <id>` | 完成指定阶段 |
| `delegate <ids>` | 委托阶段给子代理 |
| `delegate <ids> --parallel` | 并行委托 |

### 状态和监控

| 命令 | 用途 |
|------|------|
| `show-status` | 显示整体状态 |
| `show-phase <id>` | 显示阶段详情 |
| `show-audit` | 显示审计日志 |

### 上下文管理

| 命令 | 用途 |
|------|------|
| `save-context <name>` | 保存当前上下文 |
| `load-context <name>` | 加载保存的上下文 |

### 优化

| 命令 | 用途 |
|------|------|
| `optimize-plan` | 优化执行计划 |

## 子代理类型

| 类型 | 用途 | 工具集 |
|------|------|--------|
| `researcher` | 信息收集、文档研究 | web, search, read_file |
| `developer` | 代码编写、开发 | terminal, write_file, execute_code |
| `analyst` | 数据分析、报告 | execute_code, search_files |
| `reviewer` | 代码审查、质量检查 | read_file, search_files |
| `orchestrator` | 协调、管理 | delegate_task, memory |

## 文件结构

```
.deep-agent/
├── plan.md              # 主计划
├── progress.md          # 进度跟踪
├── context.md           # 当前上下文
├── audit.log            # 审计日志
├── session.log          # 会话日志
├── checkpoints/         # 上下文保存点
└── subagents/           # 子代理配置
```

## 工作流程

```
1. init-plan
   ↓
2. 查看和优化计划
   ↓
3. 逐阶段执行（委托给子代理）
   ↓
4. 监控进度和调整
   ↓
5. 完成和总结
```

## 状态标记

| 标记 | 含义 |
|------|------|
| `pending` | 待处理 |
| `in_progress` | 进行中 |
| `complete` | 已完成 |

## 优先级

| 优先级 | 含义 |
|--------|------|
| `high` | 高优先级 |
| `medium` | 中等优先级 |
| `low` | 低优先级 |

## 常用模式

### 串行执行

```bash
start-phase 1
# 等待完成
complete-phase 1
start-phase 2
```

### 并行执行

```bash
delegate 1 2 3 --parallel
# 等待所有完成
complete-phase 1 2 3
```

### 保存和恢复

```bash
# 保存
save-context checkpoint-1

# ... 继续工作 ...

# 恢复
load-context checkpoint-1
```

### 自定义子代理

```bash
delegate 4 --agent my-custom-agent
```

## 性能指标

| 指标 | 目标 |
|------|------|
| 任务完成时间 | < 预计时间 120% |
| 子代理成功率 | > 90% |
| 并行加速比 | > 1.5x |
| 上下文利用率 | < 80% |

## 故障排除

### 问题：子代理失败

```bash
# 查看审计日志
cat .deep-agent/audit.log

# 重试
delegate <id> --agent <different-agent>
```

### 问题：上下文溢出

```bash
# 保存并清理
save-context checkpoint
# 继续工作
```

### 问题：查看详细状态

```bash
# 查看计划
cat .deep-agent/plan.md

# 查看进度
cat .deep-agent/progress.md

# 查看上下文
cat .deep-agent/context.md
```

## 最佳实践

1. ✅ 花时间做好规划
2. ✅ 使用合适的子代理
3. ✅ 在关键点保存上下文
4. ✅ 定期监控进度
5. ✅ 记录重要决策
6. ✅ 验证每个阶段的输出
7. ✅ 并行执行独立任务

## 集成

### 与 planning-with-files

```bash
# 初始化 planning-with-files
~/.hermes/skills/planning-with-files/scripts/init-session.sh project

# 使用 Deep Agent
init-plan "描述任务"
```

### 与 superpowers

```bash
# 使用 superpowers 的 TDD 流程
# 在 Phase 3 中遵循 TDD 原则
```

### 与 agentmemory

```bash
# 使用 agentmemory 存储长期知识
# 在完成阶段后记录经验教训
```

## 快捷键提示

- `Ctrl+C` - 停止当前操作
- `↑/↓` - 浏览命令历史
- `Tab` - 自动补全命令

## 获取帮助

- 查看完整文档: `cat ~/.hermes/skills/deep-agent/SKILL.md`
- 查看示例: `cat ~/.hermes/skills/deep-agent/examples/`
- 查看审计日志: `cat .deep-agent/audit.log`

---

**记住**: Deep Agent 是关于规划和协调，而不仅仅是执行！
