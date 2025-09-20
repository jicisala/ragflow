#!/bin/bash

# RAGFlow 本地部署启动脚本
# 
# 这个脚本会：
# 1. 启动 Docker 基础设施服务（MySQL, Redis, MinIO, Elasticsearch）
# 2. 等待服务就绪
# 3. 在本地启动 RAGFlow 服务

set -e

# 配置
DOCKER_COMPOSE_FILE="docker/docker-compose-base.yml"
DOCKER_ENV_FILE="docker/.env"
RAGFLOW_PORT=9380
SERVICES_TO_START="mysql redis minio es01"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要文件
check_prerequisites() {
    log_info "检查必要文件..."
    
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        log_error "Docker Compose 文件不存在: $DOCKER_COMPOSE_FILE"
        exit 1
    fi
    
    if [ ! -f "$DOCKER_ENV_FILE" ]; then
        log_error "环境变量文件不存在: $DOCKER_ENV_FILE"
        exit 1
    fi
    
    # 检查 Docker 是否运行
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker 未运行，请先启动 Docker"
        exit 1
    fi
    
    log_success "必要文件检查通过"
}

# 启动基础设施服务
start_infrastructure() {
    log_info "启动基础设施服务..."
    
    docker compose -f "$DOCKER_COMPOSE_FILE" --env-file "$DOCKER_ENV_FILE" up -d $SERVICES_TO_START
    
    log_info "等待服务启动..."
    wait_for_services
}

# 等待服务就绪
wait_for_services() {
    log_info "检查服务健康状态..."
    
    local max_attempts=60  # 最多等待5分钟
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local all_healthy=true
        
        # 检查 MySQL
        if ! docker exec ragflow-mysql mysqladmin ping -uroot -pinfini_rag_flow --silent >/dev/null 2>&1; then
            all_healthy=false
        fi
        
        # 检查 Redis
        if ! docker exec ragflow-redis redis-cli -a infini_rag_flow ping >/dev/null 2>&1; then
            all_healthy=false
        fi
        
        # 检查 MinIO
        if ! docker exec ragflow-minio curl -f http://localhost:9000/minio/health/live >/dev/null 2>&1; then
            all_healthy=false
        fi
        
        # 检查 Elasticsearch
        if ! docker exec ragflow-es-01 curl -s http://localhost:9200 >/dev/null 2>&1; then
            all_healthy=false
        fi
        
        if [ "$all_healthy" = true ]; then
            log_success "所有基础设施服务已就绪!"
            return 0
        fi
        
        echo -n "."
        sleep 5
        ((attempt++))
    done
    
    log_warning "服务启动超时，但继续尝试启动 RAGFlow..."
}

# 启动 RAGFlow 服务
start_ragflow() {
    log_info "启动 RAGFlow 服务..."
    
    # 设置环境变量
    export PYTHONPATH="$(pwd)"
    
    log_info "在端口 $RAGFLOW_PORT 启动 RAGFlow..."
    log_info "按 Ctrl+C 停止服务"
    log_info "访问地址: http://localhost:$RAGFLOW_PORT"
    
    # 启动 RAGFlow
    python -m api.ragflow_server
}

# 停止基础设施服务
stop_infrastructure() {
    log_info "停止基础设施服务..."
    
    docker compose -f "$DOCKER_COMPOSE_FILE" --env-file "$DOCKER_ENV_FILE" down
}

# 显示服务状态
show_status() {
    log_info "服务状态:"
    
    docker compose -f "$DOCKER_COMPOSE_FILE" --env-file "$DOCKER_ENV_FILE" ps
}

# 停止所有服务
stop_all() {
    log_info "停止所有服务..."
    stop_infrastructure
    log_success "所有服务已停止"
}

# 重启所有服务
restart_all() {
    log_info "重启所有服务..."
    stop_all
    sleep 2
    start_all
}

# 启动所有服务
start_all() {
    check_prerequisites
    start_infrastructure
    start_ragflow
}

# 信号处理
cleanup() {
    log_info "收到停止信号，正在清理..."
    exit 0
}

trap cleanup SIGINT SIGTERM

# 主函数
main() {
    case "${1:-start}" in
        "start")
            log_info "🎯 RAGFlow 本地部署启动器"
            echo "=" | tr '\n' '=' | head -c 50; echo
            log_info "项目根目录: $(pwd)"
            log_info "RAGFlow 端口: $RAGFLOW_PORT"
            log_info "基础设施服务: $SERVICES_TO_START"
            echo "=" | tr '\n' '=' | head -c 50; echo
            
            start_all
            ;;
        "stop")
            stop_all
            ;;
        "restart")
            restart_all
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            echo "用法: $0 [start|stop|restart|status|help]"
            echo ""
            echo "命令:"
            echo "  start    启动所有服务 (默认)"
            echo "  stop     停止所有服务"
            echo "  restart  重启所有服务"
            echo "  status   查看服务状态"
            echo "  help     显示此帮助信息"
            ;;
        *)
            log_error "未知命令: $1"
            echo "使用 '$0 help' 查看帮助信息"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
