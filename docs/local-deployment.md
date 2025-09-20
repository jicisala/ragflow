# RAGFlow 本地部署指南

本文档介绍如何在本地部署 RAGFlow，其中基础设施服务（MySQL、Redis、MinIO、Elasticsearch）运行在 Docker 容器中，而 RAGFlow 主服务在本地运行。

## 架构概述

```
┌─────────────────────────────────────────────────────────────┐
│                    本地部署架构                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │   RAGFlow 服务   │    │        Docker 基础设施          │ │
│  │   (本地运行)     │◄──►│                                 │ │
│  │                 │    │  ┌─────────┐  ┌─────────────┐   │ │
│  │ • Python 3.10+  │    │  │ MySQL   │  │ Elasticsearch│   │ │
│  │ • Flask API     │    │  │ :5455   │  │ :1200       │   │ │
│  │ • 端口: 9380    │    │  └─────────┘  └─────────────┘   │ │
│  └─────────────────┘    │                                 │ │
│                         │  ┌─────────┐  ┌─────────────┐   │ │
│                         │  │ Redis   │  │ MinIO       │   │ │
│                         │  │ :6379   │  │ :9000       │   │ │
│                         │  └─────────┘  └─────────────┘   │ │
│                         └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 前置要求

1. **Docker 和 Docker Compose**
   - Docker Desktop 或 Docker Engine
   - Docker Compose v2+

2. **Python 环境**
   - Python 3.10 - 3.12
   - pip 包管理器

3. **系统要求**
   - 至少 8GB RAM
   - 至少 20GB 可用磁盘空间

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/jicisala/ragflow.git
cd ragflow
```

### 2. 启动基础设施服务

```bash
# 启动 Docker 基础设施服务
docker compose -f docker/docker-compose-base.yml --env-file docker/.env up -d mysql redis minio es01

# 检查服务状态
docker compose -f docker/docker-compose-base.yml --env-file docker/.env ps
```

### 3. 安装 Python 依赖

```bash
# 使用 uv (推荐)
uv sync

# 或使用 pip
pip install -r requirements.txt
```

### 4. 启动 RAGFlow 服务

```bash
# 设置环境变量
export PYTHONPATH=$(pwd)

# 启动 RAGFlow
python -m api.ragflow_server
```

### 5. 访问服务

打开浏览器访问：http://localhost:9380

## 使用启动脚本

我们提供了两个启动脚本来简化部署过程：

### Python 脚本 (推荐)

```bash
# 启动所有服务
python start_local.py

# 查看服务状态
python start_local.py --status

# 停止所有服务
python start_local.py --stop

# 重启所有服务
python start_local.py --restart
```

### Shell 脚本

```bash
# 启动所有服务
./start_local.sh

# 查看服务状态
./start_local.sh status

# 停止所有服务
./start_local.sh stop

# 重启所有服务
./start_local.sh restart
```

## 配置说明

### 服务配置

配置文件位于 `conf/service_conf.yaml`，主要配置项：

```yaml
ragflow:
  host: 0.0.0.0
  http_port: 9380

mysql:
  host: 'localhost'
  port: 5455
  user: 'root'
  password: 'infini_rag_flow'

redis:
  host: 'localhost:6379'
  password: 'infini_rag_flow'

minio:
  host: 'localhost:9000'
  user: 'rag_flow'
  password: 'infini_rag_flow'

es:
  hosts: 'http://localhost:1200'
  username: 'elastic'
  password: 'infini_rag_flow'
```

### 端口映射

| 服务 | 容器端口 | 主机端口 | 说明 |
|------|----------|----------|------|
| RAGFlow | - | 9380 | 主服务 API |
| MySQL | 3306 | 5455 | 数据库 |
| Redis | 6379 | 6379 | 缓存 |
| MinIO | 9000 | 9000 | 对象存储 |
| MinIO Console | 9001 | 9001 | 管理界面 |
| Elasticsearch | 9200 | 1200 | 搜索引擎 |

## 故障排除

### 常见问题

1. **Docker 服务启动失败**
   ```bash
   # 检查 Docker 是否运行
   docker info
   
   # 查看服务日志
   docker compose -f docker/docker-compose-base.yml logs [service_name]
   ```

2. **Python 依赖安装失败**
   ```bash
   # 在 Windows 上，某些包（如 pyicu）可能需要额外的系统依赖
   # 可以跳过这些可选依赖，或使用预编译的 wheel
   pip install --only-binary=all [package_name]
   ```

3. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -an | grep :9380
   
   # 修改 conf/service_conf.yaml 中的端口配置
   ```

4. **服务连接失败**
   ```bash
   # 确保所有基础设施服务都已启动并健康
   docker compose -f docker/docker-compose-base.yml ps
   
   # 测试连接
   curl http://localhost:1200  # Elasticsearch
   curl http://localhost:9000  # MinIO
   ```

### 日志查看

```bash
# RAGFlow 服务日志
# 直接在终端查看，或检查 logs/ 目录

# Docker 服务日志
docker compose -f docker/docker-compose-base.yml logs -f [service_name]
```

## 开发模式

对于开发，你可能需要：

1. **启用调试模式**
   ```bash
   export FLASK_ENV=development
   export FLASK_DEBUG=1
   ```

2. **使用代码热重载**
   ```bash
   # 安装 watchdog
   pip install watchdog
   
   # 使用 Flask 开发服务器
   flask --app api.ragflow_server run --debug --port 9380
   ```

3. **数据库迁移**
   ```bash
   # 如果需要重置数据库
   docker compose -f docker/docker-compose-base.yml down -v
   docker compose -f docker/docker-compose-base.yml up -d mysql
   ```

## 生产部署注意事项

1. **安全配置**
   - 修改默认密码
   - 配置防火墙规则
   - 使用 HTTPS

2. **性能优化**
   - 调整内存限制
   - 配置连接池
   - 启用缓存

3. **监控和日志**
   - 配置日志轮转
   - 设置监控告警
   - 备份数据

## 支持

如果遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查 GitHub Issues
3. 提交新的 Issue 并提供详细的错误信息和环境信息

## 更新日志

- **v1.0.0** - 初始版本，支持基本的本地部署
- **v1.1.0** - 添加启动脚本和故障排除指南
