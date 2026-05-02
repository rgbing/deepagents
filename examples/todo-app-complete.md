# Deep Agent 完整示例：构建 Web 应用

这个示例展示如何使用 Deep Agent 构建一个完整的 Web 应用。

## 场景描述

构建一个简单的 Todo List Web 应用，包含以下功能：
- 用户认证
- 增删改查 Todo 项
- 持久化存储
- 响应式 UI

## 第一步：初始化计划

```bash
cd ~/projects/todo-app
init-plan "构建一个 Todo List Web 应用"
```

这会创建 `.deep-agent/` 目录结构和初始计划。

## 第二步：审查和优化计划

```bash
cat .deep-agent/plan.md
```

根据实际需求修改计划：

```markdown
### Phase 1: 需求分析 [ID: 1]
- **状态**: pending
- **优先级**: high
- **预计时间**: 10m
- **依赖**: 无
- **描述**: 明确 Todo 应用需求和技术选型
- **子任务**:
  - 1.1 定义功能需求
  - 1.2 选择技术栈
  - 1.3 设计数据模型
- **可委托给**: researcher
- **输出**:
  - requirements.md
  - tech-stack.md

### Phase 2: 项目初始化 [ID: 2]
- **状态**: pending
- **优先级**: high
- **预计时间**: 15m
- **依赖**: Phase 1
- **描述**: 创建项目结构和基础配置
- **子任务**:
  - 2.1 初始化项目
  - 2.2 配置开发环境
  - 2.3 设置数据库
- **可委托给**: developer
- **输出**:
  - 项目文件
  - 配置文件

### Phase 3: 后端开发 [ID: 3]
- **状态**: pending
- **优先级**: high
- **预计时间**: 30m
- **依赖**: Phase 2
- **描述**: 实现 API 和数据库逻辑
- **子任务**:
  - 3.1 实现用户认证
  - 3.2 实现 Todo CRUD API
  - 3.3 编写单元测试
- **可委托给**: developer
- **输出**:
  - API 代码
  - 测试文件

### Phase 4: 前端开发 [ID: 4]
- **状态**: pending
- **优先级**: high
- **预计时间**: 30m
- **依赖**: Phase 2
- **描述**: 实现 UI 和交互逻辑
- **子任务**:
  - 4.1 创建页面布局
  - 4.2 实现表单和列表
  - 4.3 集成 API
- **可委托给**: developer
- **输出**:
  - 前端代码

### Phase 5: 测试和优化 [ID: 5]
- **状态**: pending
- **优先级**: medium
- **预计时间**: 20m
- **依赖**: Phase 3, Phase 4
- **描述**: 测试应用并优化性能
- **子任务**:
  - 5.1 集成测试
  - 5.2 性能优化
  - 5.3 安全审查
- **可委托给**: qa, security
- **输出**:
  - 测试报告
  - 优化建议

### Phase 6: 部署和文档 [ID: 6]
- **状态**: pending
- **优先级**: low
- **预计时间**: 15m
- **依赖**: Phase 5
- **描述**: 部署应用并编写文档
- **子任务**:
  - 6.1 配置 CI/CD
  - 6.2 部署到生产环境
  - 6.3 编写用户文档
- **可委托给**: devops, writer
- **输出**:
  - 部署配置
  - 文档

## 并行机会

- Phase 3（后端）和 Phase 4（前端）可以并行执行
- Phase 5 的测试可以并行运行
```

## 第三步：开始执行

### 串行执行（适合首次开发）

```bash
# 开始 Phase 1
start-phase 1

# 查看进度
show-status

# 完成后标记
complete-phase 1

# 继续 Phase 2
start-phase 2
complete-phase 2

# ...
```

### 委托执行（推荐）

```bash
# 委托 Phase 1 给 researcher
delegate 1 --agent researcher

# 等待完成后
complete-phase 1

# 委托 Phase 3 和 Phase 4 并行执行
delegate 3 4 --parallel

# 等待完成后
complete-phase 3 4

# 委托 Phase 5
delegate 5 --agent qa
complete-phase 5

# 最后 Phase 6
delegate 6 --agent devops
complete-phase 6
```

## 第四步：监控进度

```bash
# 查看整体状态
show-status

# 查看特定阶段
show-phase 3

# 查看审计日志
cat .deep-agent/audit.log

# 使用性能监控
deep-monitor
```

## 第五步：保存和恢复

```bash
# 在关键点保存
save-context milestone-backend-complete
save-context milestone-frontend-complete
save-context milestone-testing-complete

# 如果需要恢复
load-context milestone-backend-complete
```

## 第六步：备份和恢复

```bash
# 创建备份
deep-backup

# 恢复备份
deep-restore backup-20260502_120000
```

## 第七步：完成和总结

```bash
# 所有阶段完成后
show-status

# 查看最终报告
cat .deep-agent/progress.md
cat .deep-agent/context.md

# 创建最终备份
deep-backup final
```

## 实际输出示例

### 状态报告

```
╔════════════════════════════════════════════════════════╗
║          Deep Agent 状态报告                            ║
╚════════════════════════════════════════════════════════╝

📋 任务描述
  构建一个 Todo List Web 应用

📊 元信息
  - **创建日期**: 2026-05-02 12:00:00
  - **状态**: active
  - **当前阶段**: Phase 5

📈 整体进度
  总阶段数: 6
  已完成: 4
  进行中: 1
  待处理: 1

  进度条:
  [█████████░░] 83%

🔄 阶段状态
  Phase 1: 需求分析 ✓
  Phase 2: 项目初始化 ✓
  Phase 3: 后端开发 ✓
  Phase 4: 前端开发 ✓
  Phase 5: 测试和优化 ⟳
  Phase 6: 部署和文档 ○

🎯 当前阶段
  Phase 5

📝 上下文摘要
  - 后端 API 已完成，包含用户认证和 Todo CRUD
  - 前端 UI 已实现，包含所有功能
  - 正在进行集成测试

➡️  下一步行动
  - 完成集成测试
  - 修复发现的 bug
  - 优化性能

🚀 快速命令
  complete-phase 5           完成当前阶段
  delegate 6 --agent devops  委托最后阶段
```

### 性能监控

```
📊 系统资源
  CPU 使用率: 45%
  内存使用: 2.3/8.0GB (28.8%)
  磁盘使用: 15.2/50.0GB (30%)

📁 项目统计
  总阶段数: 6
  已完成: 4
  进行中: 1
  待处理: 1
  检查点数: 3
  检查点大小: 256K
  审计日志: 156 行 (12K)

🏥 健康检查
  健康评分: 100/100

💡 优化建议
  ✅ 系统运行良好，继续保持
```

## 总结

这个完整示例展示了：

1. ✅ 如何初始化和规划项目
2. ✅ 如何执行和监控阶段
3. ✅ 如何使用委托和并行执行
4. ✅ 如何保存和恢复上下文
5. ✅ 如何备份和恢复项目
6. ✅ 如何监控性能和健康状态

通过这个示例，您应该能够理解 Deep Agent 的完整工作流程，并应用到自己的项目中。
