# 技术纲要（Steering / Tech）

> 目的：沉淀技术栈、架构与工程规范，确保实现与运维的一致性与可持续性。

- 文档版本：v0.1
- 更新日期：2025-01-20
- 负责人：RAGFlow 技术团队

## 1. 当前技术栈（Tech Stack）
- **语言与运行时**：Python 3.10-3.12（主要）、TypeScript/JavaScript（前端）
- **后端框架**：Flask 3.0.3 + Werkzeug（HTTP 服务）
- **前端框架**：React 18 + UmiJS 4 + Ant Design + TailwindCSS
- **向量/检索**：Elasticsearch 8.12 / OpenSearch / Infinity（可选）
- **模型与推理**：
  - LLM：OpenAI、Azure、Anthropic、Ollama、Qianfan、Zhipu、Groq 等
  - Embedding：BGE、BCE、Infinity、FastEmbed 等
  - 多模态：OCR、ASR、Image2Text 支持
- **数据存储**：MySQL/PostgreSQL（元数据）、MinIO/S3（文件）、Redis/Valkey（缓存）
- **文档处理**：PyPDF、python-docx、python-pptx、OpenCV、Pillow
- **基础设施**：Docker + Docker Compose、Nginx（反向代理）

## 2. 架构总览（Architecture Overview）
- **分层架构**：Web UI → API 层 → 业务逻辑层 → 数据访问层
- **核心流程**：文档上传 → 解析 → 分块 → 向量化 → 索引 → 检索 → 生成
- **服务组件**：
  - `ragflow-server`：主服务（API + 任务调度）
  - `mysql`：元数据存储
  - `redis`：缓存与分布式锁
  - `minio`：文件对象存储
  - `elasticsearch`：向量检索引擎

## 3. 核心组件（Core Components）
- **API 层**（`api/`）：RESTful API、认证授权、请求路由
- **RAG 引擎**（`rag/`）：检索、生成、流程编排
- **文档解析**（`deepdoc/`）：多格式文档解析与理解
- **图谱推理**（`graphrag/`）：知识图谱构建与查询
- **智能代理**（`agent/`）：工具调用与推理能力
- **插件系统**（`plugin/`）：可扩展的功能插件
- **MCP 服务**（`mcp/`）：模型上下文协议支持

## 4. 数据与模型（Data & Models）
- **数据流**：原始文档 → 结构化解析 → 语义分块 → 向量嵌入 → 检索索引
- **模型策略**：
  - 支持多厂商 LLM（OpenAI、Claude、国产大模型等）
  - 内置优化的 Embedding 模型（BGE、BCE）
  - 可配置的 Rerank 模型提升检索精度
- **数据管理**：文档版本控制、增量更新、批量处理

## 5. 性能与容量（Perf & Capacity）
- **响应时间**：文档解析 <30s、检索查询 <2s、问答生成 <10s
- **并发能力**：支持多用户并发访问，通过 Redis 分布式锁协调
- **存储容量**：支持 TB 级文档存储，向量索引自动分片
- **扩展策略**：水平扩展（多实例）+ 垂直扩展（GPU 加速）

## 6. 可观测性（Observability）
- **日志系统**：结构化日志，支持不同级别（DEBUG/INFO/WARN/ERROR）
- **监控指标**：系统资源、API 响应时间、文档处理进度
- **错误追踪**：异常堆栈记录，便于问题定位
- **健康检查**：服务状态监控，依赖组件连通性检查

## 7. 安全与合规（Security & Compliance）
- **身份认证**：支持多种认证方式（本地账户、OAuth、LDAP）
- **权限控制**：基于角色的访问控制（RBAC）
- **数据安全**：文档加密存储、API 密钥管理
- **隐私保护**：支持本地部署，数据不出企业边界

## 8. 开发流程与工程工具（DevEx）
- **代码规范**：Python（Ruff）、TypeScript（ESLint + Prettier）
- **依赖管理**：uv（Python）、npm/pnpm（Node.js）
- **容器化**：Docker 多阶段构建，支持 GPU 和 CPU 版本
- **测试框架**：pytest（后端）、Jest（前端）
- **版本控制**：语义化版本（SemVer），当前 v0.20.4

## 9. 依赖与版本策略（Dependencies）
- **核心依赖**：Flask、Elasticsearch、PyTorch、Transformers
- **模型依赖**：支持多种 LLM 和 Embedding 模型
- **兼容性**：Python 3.10-3.12、Node.js >=18.20.4
- **更新策略**：定期更新安全补丁，谨慎升级主要版本

## 10. 决策记录（ADRs）
- **ADR-001**：选择 Elasticsearch 作为默认向量检索引擎
- **ADR-002**：采用 Flask 而非 FastAPI 保持轻量级
- **ADR-003**：支持多种 LLM 厂商避免供应商锁定
- **ADR-004**：使用 Docker Compose 简化部署复杂度

## 11. 风险与技术债（Risks & Debts）
- **技术风险**：
  - 大模型 API 限流和成本控制
  - 复杂文档解析准确性有待提升
  - 向量检索性能在大规模数据下的优化
- **技术债**：
  - 部分遗留代码需要重构
  - 测试覆盖率有待提升
  - 文档和注释需要完善

## 12. 未来演进（Roadmap）
- **短期（1-2 版本）**：GraphRAG 优化、多模态能力增强、MCP 协议完善
- **中期（3-5 版本）**：分布式部署、实时数据同步、高级 Agent 能力
- **长期（6+ 版本）**：云原生架构、边缘计算支持、行业定制化方案

---
提示：技术纲要需与产品纲要与后续设计文档保持一致，重大变更需更新并审批。

