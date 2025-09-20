#!/usr/bin/env python3
"""
RAGFlow 本地部署启动脚本

这个脚本会：
1. 启动 Docker 基础设施服务（MySQL, Redis, MinIO, Elasticsearch）
2. 等待服务就绪
3. 在本地启动 RAGFlow 服务

使用方法：
    python start_local.py [--stop] [--restart] [--status]
    
选项：
    --stop      停止所有服务
    --restart   重启所有服务
    --status    查看服务状态
    --help      显示帮助信息
"""

import subprocess
import sys
import time
import argparse
import os
import signal
from pathlib import Path

# 配置
DOCKER_COMPOSE_FILE = "docker/docker-compose-base.yml"
DOCKER_ENV_FILE = "docker/.env"
RAGFLOW_PORT = 9380
SERVICES_TO_START = ["mysql", "redis", "minio", "es01"]  # 基础设施服务

class RAGFlowLocalDeployment:
    def __init__(self):
        self.project_root = Path(__file__).parent
        self.docker_compose_path = self.project_root / DOCKER_COMPOSE_FILE
        self.env_file_path = self.project_root / DOCKER_ENV_FILE
        self.ragflow_process = None
        
        # 检查必要文件
        if not self.docker_compose_path.exists():
            raise FileNotFoundError(f"Docker Compose 文件不存在: {self.docker_compose_path}")
        if not self.env_file_path.exists():
            raise FileNotFoundError(f"环境变量文件不存在: {self.env_file_path}")
    
    def run_command(self, cmd, cwd=None, check=True, capture_output=False):
        """执行命令"""
        if cwd is None:
            cwd = self.project_root
        
        print(f"执行命令: {' '.join(cmd)}")
        try:
            if capture_output:
                result = subprocess.run(cmd, cwd=cwd, check=check, 
                                      capture_output=True, text=True)
                return result.stdout.strip()
            else:
                subprocess.run(cmd, cwd=cwd, check=check)
        except subprocess.CalledProcessError as e:
            print(f"命令执行失败: {e}")
            if capture_output and e.stdout:
                print(f"输出: {e.stdout}")
            if capture_output and e.stderr:
                print(f"错误: {e.stderr}")
            if check:
                raise
    
    def start_infrastructure(self):
        """启动基础设施服务"""
        print("🚀 启动基础设施服务...")
        
        # 启动指定的服务
        cmd = ["docker", "compose", "-f", str(self.docker_compose_path), 
               "--env-file", str(self.env_file_path), "up", "-d"] + SERVICES_TO_START
        
        self.run_command(cmd)
        
        print("⏳ 等待服务启动...")
        self.wait_for_services()
    
    def wait_for_services(self):
        """等待服务就绪"""
        print("🔍 检查服务健康状态...")
        
        max_attempts = 60  # 最多等待5分钟
        attempt = 0
        
        while attempt < max_attempts:
            try:
                # 检查服务状态
                cmd = ["docker", "compose", "-f", str(self.docker_compose_path),
                       "--env-file", str(self.env_file_path), "ps", "--format", "json"]
                
                output = self.run_command(cmd, capture_output=True)
                
                if output:
                    import json
                    services = [json.loads(line) for line in output.split('\n') if line.strip()]
                    
                    all_healthy = True
                    for service in services:
                        if service.get('Name', '').replace('ragflow-', '') in ['mysql', 'redis', 'minio', 'es-01']:
                            state = service.get('State', '')
                            health = service.get('Health', '')
                            
                            print(f"  {service.get('Name', 'unknown')}: {state} ({health})")
                            
                            if state != 'running' or (health and health != 'healthy'):
                                all_healthy = False
                    
                    if all_healthy:
                        print("✅ 所有基础设施服务已就绪!")
                        return
                
            except Exception as e:
                print(f"检查服务状态时出错: {e}")
            
            attempt += 1
            time.sleep(5)
        
        print("⚠️  服务启动超时，但继续尝试启动 RAGFlow...")
    
    def start_ragflow(self):
        """启动 RAGFlow 服务"""
        print("🚀 启动 RAGFlow 服务...")
        
        # 设置环境变量
        env = os.environ.copy()
        env['PYTHONPATH'] = str(self.project_root)
        
        # 启动 RAGFlow
        cmd = [sys.executable, "-m", "api.ragflow_server"]
        
        print(f"在端口 {RAGFLOW_PORT} 启动 RAGFlow...")
        print("按 Ctrl+C 停止服务")
        
        try:
            self.ragflow_process = subprocess.Popen(
                cmd, 
                cwd=self.project_root,
                env=env
            )
            
            # 等待进程结束
            self.ragflow_process.wait()
            
        except KeyboardInterrupt:
            print("\n🛑 收到停止信号...")
            self.stop_ragflow()
        except Exception as e:
            print(f"启动 RAGFlow 时出错: {e}")
            self.stop_ragflow()
    
    def stop_ragflow(self):
        """停止 RAGFlow 服务"""
        if self.ragflow_process:
            print("停止 RAGFlow 服务...")
            self.ragflow_process.terminate()
            try:
                self.ragflow_process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                print("强制终止 RAGFlow 服务...")
                self.ragflow_process.kill()
            self.ragflow_process = None
    
    def stop_infrastructure(self):
        """停止基础设施服务"""
        print("🛑 停止基础设施服务...")
        
        cmd = ["docker", "compose", "-f", str(self.docker_compose_path),
               "--env-file", str(self.env_file_path), "down"]
        
        self.run_command(cmd, check=False)
    
    def show_status(self):
        """显示服务状态"""
        print("📊 服务状态:")
        
        try:
            cmd = ["docker", "compose", "-f", str(self.docker_compose_path),
                   "--env-file", str(self.env_file_path), "ps"]
            
            self.run_command(cmd, check=False)
        except Exception as e:
            print(f"获取状态时出错: {e}")
    
    def start_all(self):
        """启动所有服务"""
        try:
            self.start_infrastructure()
            self.start_ragflow()
        except KeyboardInterrupt:
            print("\n🛑 收到停止信号...")
        finally:
            self.stop_ragflow()
    
    def stop_all(self):
        """停止所有服务"""
        self.stop_ragflow()
        self.stop_infrastructure()
        print("✅ 所有服务已停止")
    
    def restart_all(self):
        """重启所有服务"""
        print("🔄 重启所有服务...")
        self.stop_all()
        time.sleep(2)
        self.start_all()

def signal_handler(signum, frame):
    """信号处理器"""
    print(f"\n收到信号 {signum}，正在停止...")
    sys.exit(0)

def main():
    parser = argparse.ArgumentParser(description="RAGFlow 本地部署管理工具")
    parser.add_argument("--stop", action="store_true", help="停止所有服务")
    parser.add_argument("--restart", action="store_true", help="重启所有服务")
    parser.add_argument("--status", action="store_true", help="查看服务状态")
    
    args = parser.parse_args()
    
    # 注册信号处理器
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    try:
        deployment = RAGFlowLocalDeployment()
        
        if args.stop:
            deployment.stop_all()
        elif args.restart:
            deployment.restart_all()
        elif args.status:
            deployment.show_status()
        else:
            print("🎯 RAGFlow 本地部署启动器")
            print("=" * 50)
            print(f"项目根目录: {deployment.project_root}")
            print(f"RAGFlow 端口: {RAGFLOW_PORT}")
            print(f"基础设施服务: {', '.join(SERVICES_TO_START)}")
            print("=" * 50)
            
            deployment.start_all()
            
    except FileNotFoundError as e:
        print(f"❌ 文件不存在: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
