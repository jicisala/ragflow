# 产品纲要（Steering / Product）

> 目的：统一愿景、目标与价值主张，为后续规格（requirements/design/tasks）提供清晰的产品方向。

- 文档版本：v0.1
- 更新日期：2025-01-20
- 负责人：RAGFlow 团队

## 1. 愿景（Vision）
- **核心愿景**：构建基于深度文档理解的开源 RAG 引擎，为各种规模的企业提供可信赖的问答能力
- **长期目标**：成为全球领先的企业级 RAG 解决方案，支持复杂格式文档的智能检索与生成

## 2. 目标（Goals）
- **用户增长**：提升开源社区活跃度，增加 Docker 拉取量和 GitHub Stars
- **技术能力**：支持多模态文档解析（PDF、Word、PPT、Excel、图片等）
- **企业采用**：为中小企业到大型企业提供可部署的 RAG 解决方案
- **生态建设**：完善 SDK、插件系统和第三方集成

## 3. 非目标（Non-Goals）
- 不做通用聊天机器人（专注于文档问答场景）
- 不做模型训练平台（专注于检索增强生成）
- 暂不支持实时流式数据处理
- 不提供云端 SaaS 服务（专注开源自部署）

## 4. 用户画像与核心场景（Personas & Scenarios）
- **企业开发者**：需要在内部系统集成文档问答能力
- **数据科学家**：需要处理大量研究文档和技术资料
- **知识管理员**：需要构建企业知识库和智能客服
- **核心场景**：
  - 企业内部文档智能问答
  - 研究论文检索与分析
  - 客服知识库构建

## 5. 价值主张（Value Proposition）
- **深度文档理解**：相比通用 RAG 方案，专门优化复杂格式文档解析
- **开源可控**：企业可完全自主部署，数据安全可控
- **多模态支持**：支持文本、图片、表格等多种内容类型
- **易于集成**：提供完整的 API 和 SDK，便于系统集成

## 6. 范围与边界（Scope & Boundaries）
- **核心能力**：文档解析、向量检索、问答生成、知识图谱
- **支持格式**：PDF、Word、PPT、Excel、Markdown、HTML、图片
- **部署方式**：Docker、源码部署、Kubernetes
- **边界**：不包含模型训练、不提供云服务、不做实时数据流处理

## 7. 里程碑与成功指标（Milestones & Success Metrics）
- **技术指标**：文档解析准确率 >95%、检索响应时间 <2s
- **用户指标**：GitHub Stars 增长、Docker 拉取量、社区贡献者数量
- **功能里程碑**：多语言支持、GraphRAG、Agent 能力、MCP 集成

## 8. 风险与假设（Risks & Assumptions）
- **技术风险**：大模型 API 成本和稳定性、复杂文档解析准确性
- **竞争风险**：大厂推出类似开源方案、商业化 RAG 产品竞争
- **假设条件**：用户有足够的计算资源、愿意自主部署和维护

## 9. 术语表（Glossary）
- **RAG**：检索增强生成（Retrieval-Augmented Generation）
- **向量检索**：基于语义相似度的文档检索技术
- **GraphRAG**：基于知识图谱的检索增强生成
- **MCP**：模型上下文协议（Model Context Protocol）
- **Agent**：智能代理，具备工具调用和推理能力

## 10. 参考资料（References）
- [RAGFlow 官方文档](https://ragflow.io/docs/)
- [GitHub 仓库](https://github.com/infiniflow/ragflow)
- [在线演示](https://demo.ragflow.io)
- [Docker Hub](https://hub.docker.com/r/infiniflow/ragflow)

---
提示：本产品纲要将作为后续 Requirements → Design → Tasks 的上游输入；任何重大变更请先更新此文档并走审批。

