# Deep Agent - 简单 Web 应用示例

## 概述

这个示例展示如何使用 Deep Agent 构建一个简单的 Web 应用。

## 步骤

### 1. 初始化计划

```bash
init-plan "构建一个简单的 Todo API"
```

### 2. 查看生成的计划

```bash
cat .deep-agent/plan.md
```

### 3. 自定义计划（可选）

编辑 `.deep-agent/plan.md` 以添加特定需求：

```markdown
### Phase 3: 实施 [ID: 3]
- **状态**: pending
- **优先级**: high
- **预计时间**: 30m
- **依赖**: Phase 2
- **描述**: 使用 FastAPI 实现 Todo API
- **子任务**:
  - 3.1 创建项目结构
  - 3.2 实现 CRUD 端点
  - 3.3 添加数据验证
  - 3.4 编写单元测试
- **可委托给**: developer
- **输出**:
  - main.py
  - models.py
  - test_main.py
```

### 4. 开始执行

```bash
# 开始第一个阶段
start-phase 1

# 或者委托给研究者
delegate 1 --agent researcher
```

### 5. 监控进度

```bash
show-status
```

### 6. 完成阶段

当阶段完成后：

```bash
complete-phase 1
```

### 7. 优化计划

在执行过程中，可以优化计划：

```bash
optimize-plan
```

### 8. 保存上下文

在关键点保存上下文：

```bash
save-context milestone-design-complete
```

### 9. 继续执行

继续下一个阶段：

```bash
start-phase 2
```

### 10. 并行执行

如果有独立的阶段，可以并行执行：

```bash
# 假设 Phase 3.1 和 3.2 是独立的
delegate "3.1" "3.2" --parallel
```

## 预期输出

### 生成的文件结构

```
.
├── .deep-agent/
│   ├── plan.md
│   ├── progress.md
│   ├── context.md
│   ├── audit.log
│   ├── session.log
│   ├── checkpoints/
│   │   └── milestone-design-complete-20260430-143000.md
│   └── subagents/
│       ├── researcher.yaml
│       ├── developer.yaml
│       └── orchestrator.yaml
├── main.py
├── models.py
├── test_main.py
└── requirements.txt
```

### 最终结果

一个功能完整的 Todo API，包含：
- CRUD 操作
- 数据验证
- 单元测试
- API 文档

## 高级用法

### 使用自定义子代理

创建自定义子代理配置：

```yaml
# .deep-agent/subagents/api-developer.yaml
name: api-developer
description: 专门用于 API 开发的子代理
system_prompt: |
  你是一个 API 开发专家。专注于：
  1. RESTful API 设计
  2. FastAPI 框架使用
  3. 数据验证和序列化
  4. API 文档编写

  遵循 OpenAPI 规范和最佳实践。

allowed_tools:
  - terminal
  - write_file
  - read_file
  - execute_code

max_tokens: 6000
timeout: 600
```

然后使用：

```bash
delegate 3 --agent api-developer
```

### 与其他技能集成

结合 `planning-with-files` 技能：

```bash
# 使用 planning-with-files 创建详细计划
~/.hermes/skills/planning-with-files/scripts/init-session.sh todo-api

# 使用 Deep Agent 协调执行
init-plan "构建 Todo API"
```

### 批量操作

使用脚本自动化多个阶段：

```bash
# 完成所有研究阶段
for i in {1..3}; do
    delegate $i --agent researcher
    wait
    complete-phase $i
done

# 并行执行开发阶段
delegate 4 5 6 --parallel
```

## 故障排除

### 问题：子代理失败

**解决方案**：
1. 检查审计日志：`cat .deep-agent/audit.log`
2. 查看错误详情：`cat .deep-agent/progress.md`
3. 重试或使用不同的子代理

### 问题：上下文溢出

**解决方案**：
1. 保存当前上下文：`save-context checkpoint`
2. 清理旧的上下文
3. 从保存点恢复：`load-context checkpoint`

### 问题：并行任务冲突

**解决方案**：
1. 检查文件依赖
2. 使用文件锁
3. 改为串行执行

## 最佳实践

1. **详细规划**: 花时间做好规划，执行会更快
2. **小步迭代**: 将大任务分解为小步骤
3. **频繁保存**: 在关键点保存上下文
4. **监控进度**: 定期检查进度和调整
5. **记录决策**: 记录所有重要决策及其理由
6. **测试验证**: 每个阶段后验证结果
7. **文档编写**: 同步编写文档

## 扩展阅读

- [Deep Agent 技能文档](../SKILL.md)
- [LangChain Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview)
- [Hermes Agent 文档](https://hermes-agent.nousresearch.com/docs)

---

**提示**: 这个示例只是一个起点。根据你的具体需求调整和扩展。
