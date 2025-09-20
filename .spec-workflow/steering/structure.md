# 结构纲要（Steering / Structure）

> 目的：沉淀代码仓库组织、模块边界与工程约定，降低协作与维护成本。

- 文档版本：v0.1
- 更新日期：2025-01-20
- 负责人：RAGFlow 架构团队

## 1. 仓库总览（Repository Overview）
- **仓库性质**：开源 RAG 引擎，包含完整的前后端代码、文档、部署配置
- **主要用途**：企业级文档问答系统、知识库构建、智能检索服务
- **技术边界**：不包含模型训练代码，专注于检索增强生成应用层

## 2. 目录结构（Directory Layout）
```
ragflow/                           # 项目根目录
├── api/                          # 后端 API 服务
│   ├── apps/                     # 业务应用模块
│   ├── db/                       # 数据库模型与服务
│   ├── utils/                    # 工具函数
│   └── ragflow_server.py         # 主服务入口
├── web/                          # 前端 React 应用
│   ├── src/                      # 源码目录
│   ├── public/                   # 静态资源
│   └── package.json              # 前端依赖配置
├── rag/                          # RAG 核心引擎
│   ├── app/                      # 应用逻辑
│   ├── llm/                      # 大模型集成
│   ├── nlp/                      # 自然语言处理
│   └── utils/                    # RAG 工具函数
├── deepdoc/                      # 文档解析引擎
│   ├── parser/                   # 各格式解析器
│   └── vision/                   # 视觉理解模块
├── graphrag/                     # 图谱增强检索
├── agent/                        # 智能代理模块
├── plugin/                       # 插件系统
├── mcp/                          # MCP 协议支持
├── docker/                       # 容器化配置
├── docs/                         # 项目文档
├── test/                         # 测试代码
├── conf/                         # 配置文件
├── pyproject.toml                # Python 项目配置
└── README.md                     # 项目说明
```

## 3. 模块与边界（Modules & Boundaries）
- **API 层**（`api/`）：对外接口，不直接处理业务逻辑
- **RAG 引擎**（`rag/`）：核心业务逻辑，可被 API 和 Agent 调用
- **文档解析**（`deepdoc/`）：独立的文档处理模块
- **图谱推理**（`graphrag/`）：知识图谱相关功能
- **智能代理**（`agent/`）：高级推理与工具调用
- **依赖方向**：API → RAG → DeepDoc，禁止反向依赖

## 4. 命名与约定（Naming & Conventions）
- **Python 代码**：snake_case（文件名、函数名、变量名）
- **TypeScript 代码**：camelCase（变量、函数）、PascalCase（组件、类）
- **目录命名**：小写 + 下划线（Python）、小写 + 连字符（前端）
- **常量命名**：UPPER_SNAKE_CASE
- **国际化**：支持中英文，使用 i18next（前端）
- **编码约定**：UTF-8，统一使用 LF 换行符

## 5. 依赖约束（Dependency Rules）
- **分层原则**：上层可依赖下层，禁止循环依赖
- **核心依赖**：优先使用成熟稳定的开源库
- **版本锁定**：使用 uv.lock 和 package-lock.json 锁定版本
- **安全扫描**：定期检查依赖漏洞，及时更新安全补丁

## 6. 代码风格与格式化（Code Style）
- **Python**：使用 Ruff 进行 Lint 和 Format
- **TypeScript**：ESLint + Prettier，配置在 web/.eslintrc.js
- **提交前检查**：Husky + lint-staged 自动格式化
- **行长度限制**：Python 200 字符，TypeScript 80 字符

## 7. 测试约定（Testing）
- **Python 测试**：pytest 框架，测试文件以 test_ 开头
- **前端测试**：Jest + Testing Library，组件测试和单元测试
- **测试数据**：使用 fixtures 和 mock 数据，避免依赖外部服务
- **覆盖率目标**：核心模块 >80%，新增功能必须有测试

## 8. 分支与发布（Branches & Release）
- **主分支**：main（稳定版本）
- **开发分支**：feature/xxx、bugfix/xxx、hotfix/xxx
- **发布流程**：语义化版本（SemVer），当前 v0.20.4
- **变更日志**：维护 CHANGELOG.md，记录重要变更

## 9. 贡献流程（Contributing）
- **Issue 模板**：Bug 报告、功能请求、问题讨论
- **PR 规范**：清晰的标题和描述，关联相关 Issue
- **代码审查**：至少一人审查，核心模块需要维护者审查
- **CI/CD**：自动化测试、构建、安全扫描

## 10. 文档与知识（Docs & Knowledge）
- **API 文档**：使用 Swagger/OpenAPI 自动生成
- **用户文档**：docs/ 目录，支持多语言
- **开发文档**：README、贡献指南、架构说明
- **知识库**：Wiki 记录设计决策和最佳实践

## 11. 维护与更新（Maintenance）
- **定期维护**：每月检查依赖更新、安全漏洞
- **性能监控**：关注关键指标，及时优化瓶颈
- **技术债务**：季度回顾，制定偿还计划
- **版本演进**：保持向后兼容，渐进式升级

---
提示：本结构纲要为跨团队协作与审阅的基线，请保持与实际仓库随时同步更新。

