#!/bin/bash

# DeerFlow 阿里云服务器部署脚本
# 适用于 Ubuntu 系统

set -e  # 遇到错误时停止执行

echo "🦌 DeerFlow 阿里云部署脚本启动..."
echo "================================"

# 检查是否为 root 用户
if [[ $EUID -eq 0 ]]; then
   echo "❌ 请不要使用 root 用户运行此脚本"
   exit 1
fi

# 更新系统包
echo "📦 更新系统包..."
sudo apt update && sudo apt upgrade -y

# 安装必需的系统包
echo "🔧 安装必需的系统包..."
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    vim \
    htop

# 安装 Docker
echo "🐳 安装 Docker..."
if ! command -v docker &> /dev/null; then
    # 添加 Docker 官方 GPG 密钥
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # 添加 Docker 仓库
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装 Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # 将当前用户添加到 docker 组
    sudo usermod -aG docker $USER
    
    echo "✅ Docker 安装完成"
else
    echo "✅ Docker 已安装"
fi

# 安装 Docker Compose
echo "🐳 安装 Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose 安装完成"
else
    echo "✅ Docker Compose 已安装"
fi

# 安装 Node.js (使用 NodeSource 仓库)
echo "📦 安装 Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
    echo "✅ Node.js 安装完成"
else
    echo "✅ Node.js 已安装"
fi

# 安装 pnpm
echo "📦 安装 pnpm..."
if ! command -v pnpm &> /dev/null; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    source ~/.bashrc
    echo "✅ pnpm 安装完成"
else
    echo "✅ pnpm 已安装"
fi

# 安装 Python 和 uv
echo "🐍 安装 Python 和 uv..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source ~/.bashrc
    echo "✅ uv 安装完成"
else
    echo "✅ uv 已安装"
fi

# 配置防火墙
echo "🔒 配置防火墙..."
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS
sudo ufw allow 3000/tcp   # Frontend
sudo ufw allow 8000/tcp   # Backend
sudo ufw --force enable

echo "✅ 防火墙配置完成"

# 创建项目目录
PROJECT_DIR="/home/$USER/deer-flow"
echo "📁 创建项目目录: $PROJECT_DIR"

if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
fi

echo ""
echo "🎉 环境安装完成！"
echo "================================"
echo "下一步操作："
echo "1. 重新登录以使 Docker 组权限生效: sudo su - $USER"
echo "2. 将项目文件上传到服务器: $PROJECT_DIR"
echo "3. 运行项目部署脚本: ./deploy-project.sh"
echo ""
echo "服务器信息："
echo "- 公网IP: 47.122.147.17"
echo "- 前端访问地址: http://47.122.147.17:3000"
echo "- 后端API地址: http://47.122.147.17:8000"
echo "================================" 