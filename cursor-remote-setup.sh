#!/bin/bash

# Cursor 远程开发环境设置脚本
echo "🚀 设置 Cursor 远程开发环境..."

# 1. 安装基础开发工具
sudo apt update
sudo apt install -y git curl wget build-essential

# 2. 安装 Python 开发环境
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc || source ~/.profile

# 3. 安装 Node.js 开发环境
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 4. 安装 pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.bashrc || source ~/.profile

# 5. 克隆项目（如果不存在）
if [ ! -d "deer-flow" ]; then
    git clone https://github.com/ly-wang19/deer-flow.git
fi

cd deer-flow

# 6. 安装 Python 依赖
if command -v uv &> /dev/null; then
    uv sync
else
    echo "警告: uv 未安装，请手动安装项目依赖"
fi

# 7. 安装前端依赖
if [ -d "web" ]; then
    cd web
    if command -v pnpm &> /dev/null; then
        pnpm install
    else
        npm install
    fi
    cd ..
fi

# 8. 创建开发配置文件
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# 开发环境配置
SEARCH_API=duckduckgo
HOST=0.0.0.0
PORT=8000
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://47.122.147.17:8000
EOF
fi

if [ ! -f "conf.yaml" ] && [ -f "conf.yaml.example" ]; then
    cp conf.yaml.example conf.yaml
fi

# 9. 设置 Git 配置
git config --global user.name "DeerFlow Developer"
git config --global user.email "developer@deerflow.com"

echo "✅ Cursor 远程开发环境设置完成！"
echo ""
echo "📋 下一步操作："
echo "1. 在 Cursor 中打开远程文件夹: /root/deer-flow"
echo "2. 开始开发！"
echo ""
echo "🔧 开发命令："
echo "- 启动后端: uv run python server.py"
echo "- 启动前端: cd web && npm run dev"
echo "- 运行测试: uv run python main.py --interactive" 