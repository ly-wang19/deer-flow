#!/bin/bash

# DeerFlow 一键部署脚本
# 适用于阿里云 Ubuntu 服务器

set -e

echo "🦌 DeerFlow 一键部署脚本启动..."
echo "服务器IP: 47.122.147.17"
echo "================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查系统
echo -e "${YELLOW}📋 检查系统信息...${NC}"
uname -a
lsb_release -a 2>/dev/null || echo "无法获取发行版信息"

# 更新系统
echo -e "${YELLOW}📦 更新系统包...${NC}"
sudo apt update && sudo apt upgrade -y

# 安装基础包
echo -e "${YELLOW}🔧 安装基础包...${NC}"
sudo apt install -y curl wget git build-essential software-properties-common \
    apt-transport-https ca-certificates gnupg lsb-release unzip vim htop

# 安装 Docker
echo -e "${YELLOW}🐳 安装 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo -e "${GREEN}✅ Docker 安装完成${NC}"
else
    echo -e "${GREEN}✅ Docker 已安装${NC}"
fi

# 安装 Docker Compose
echo -e "${YELLOW}🐳 安装 Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose 安装完成${NC}"
else
    echo -e "${GREEN}✅ Docker Compose 已安装${NC}"
fi

# 安装 Node.js
echo -e "${YELLOW}📦 安装 Node.js...${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
    echo -e "${GREEN}✅ Node.js 安装完成${NC}"
else
    echo -e "${GREEN}✅ Node.js 已安装${NC}"
fi

# 配置防火墙
echo -e "${YELLOW}🔒 配置防火墙...${NC}"
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 8000/tcp
sudo ufw --force enable
echo -e "${GREEN}✅ 防火墙配置完成${NC}"

# 克隆项目
echo -e "${YELLOW}📂 克隆 DeerFlow 项目...${NC}"
if [ -d "deer-flow" ]; then
    echo "项目目录已存在，删除并重新克隆..."
    rm -rf deer-flow
fi

git clone https://github.com/bytedance/deer-flow.git
cd deer-flow

# 创建配置文件
echo -e "${YELLOW}📝 创建配置文件...${NC}"

# 创建 .env 文件
cat > .env << 'EOF'
# API Keys - 请根据你的需求配置
TAVILY_API_KEY=your-tavily-api-key-here
BRAVE_SEARCH_API_KEY=your-brave-search-api-key-here

# Search Engine Configuration (DuckDuckGo 无需 API Key)
SEARCH_API=duckduckgo

# Server Configuration
HOST=0.0.0.0
PORT=8000
FRONTEND_PORT=3000

# Next.js Configuration
NEXT_PUBLIC_API_URL=http://47.122.147.17:8000

# TTS Configuration (Optional)
# VOLCENGINE_ACCESS_KEY=your-volcengine-access-key
# VOLCENGINE_SECRET_KEY=your-volcengine-secret-key

# RAG Configuration (Optional)
# RAG_PROVIDER=ragflow
# RAGFLOW_API_URL=http://localhost:9388
# RAGFLOW_API_KEY=ragflow-xxx
EOF

# 创建 conf.yaml
if [ -f "conf.yaml.example" ]; then
    cp conf.yaml.example conf.yaml
else
    cat > conf.yaml << 'EOF'
# DeerFlow Configuration
# 请根据你的需求配置 LLM 模型

models:
  - name: "gpt-4"
    provider: "openai"
    # 在这里配置你的模型设置
EOF
fi

# 创建生产环境 Docker Compose 配置
cat > docker-compose.prod.yml << 'EOF'
services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: deer-flow-backend
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - ./conf.yaml:/app/conf.yaml
      - ./assets:/app/assets
    restart: unless-stopped
    networks:
      - deer-flow-network
    environment:
      - HOST=0.0.0.0
      - PORT=8000

  frontend:
    build:
      context: ./web
      dockerfile: Dockerfile
      args:
        - NEXT_PUBLIC_API_URL=http://47.122.147.17:8000
    container_name: deer-flow-frontend
    ports:
      - "3000:3000"
    env_file:
      - .env
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - deer-flow-network

networks:
  deer-flow-network:
    driver: bridge
EOF

# 构建并启动服务
echo -e "${YELLOW}🚀 构建并启动服务...${NC}"
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker system prune -f 2>/dev/null || true
docker-compose -f docker-compose.prod.yml up --build -d

# 等待服务启动
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 30

# 检查服务状态
echo -e "${YELLOW}🔍 检查服务状态...${NC}"
docker-compose -f docker-compose.prod.yml ps

# 显示最终信息
echo ""
echo -e "${GREEN}🎉 DeerFlow 部署完成！${NC}"
echo "================================"
echo -e "${GREEN}服务访问地址：${NC}"
echo -e "• 前端 Web UI: ${YELLOW}http://47.122.147.17:3000${NC}"
echo -e "• 后端 API: ${YELLOW}http://47.122.147.17:8000${NC}"
echo ""
echo -e "${YELLOW}⚠️  重要提醒：${NC}"
echo "1. 请编辑 .env 文件配置你的 API Keys"
echo "2. 请编辑 conf.yaml 文件配置你的 LLM 模型"
echo "3. 确保阿里云安全组开放了 3000 和 8000 端口"
echo ""
echo -e "${GREEN}常用管理命令：${NC}"
echo "• 查看日志: docker-compose -f docker-compose.prod.yml logs -f"
echo "• 重启服务: docker-compose -f docker-compose.prod.yml restart"
echo "• 停止服务: docker-compose -f docker-compose.prod.yml down"
echo "================================"

# 显示日志（最后几行）
echo -e "${YELLOW}📋 最近的服务日志：${NC}"
docker-compose -f docker-compose.prod.yml logs --tail=10 