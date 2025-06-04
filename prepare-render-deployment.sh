#!/bin/bash

# DeerFlow Render 部署准备脚本

set -e

echo "🦌 DeerFlow Render 部署准备脚本"
echo "=================================="

# 检查必要文件
echo "📋 检查部署文件..."

required_files=(
    "render.yaml"
    "build.sh"
    "start.sh"
    "pyproject.toml"
    "server.py"
    "web/package.json"
    "web/next.config.js"
)

missing_files=()

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    echo "❌ 缺少以下必要文件:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
    exit 1
else
    echo "✅ 所有必要文件都存在"
fi

# 检查脚本权限
echo "🔧 检查脚本权限..."
if [ ! -x "build.sh" ]; then
    echo "📝 为 build.sh 添加执行权限..."
    chmod +x build.sh
fi

if [ ! -x "start.sh" ]; then
    echo "📝 为 start.sh 添加执行权限..."
    chmod +x start.sh
fi

echo "✅ 脚本权限设置完成"

# 检查配置文件
echo "⚙️ 检查配置文件..."
if [ ! -f "conf.yaml" ]; then
    if [ -f "conf.yaml.example" ]; then
        echo "📋 复制配置文件模板..."
        cp conf.yaml.example conf.yaml
        echo "✅ 已创建 conf.yaml"
    else
        echo "⚠️ 警告: 未找到 conf.yaml 或 conf.yaml.example"
    fi
else
    echo "✅ conf.yaml 存在"
fi

# 检查Git状态
echo "📦 检查Git状态..."
if [ ! -d ".git" ]; then
    echo "⚠️ 警告: 当前目录不是Git仓库"
    echo "   请运行以下命令初始化Git仓库:"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial commit for Render deployment'"
    echo "   git remote add origin https://github.com/your-username/deer-flow.git"
    echo "   git push -u origin main"
else
    echo "✅ Git仓库已初始化"
    
    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️ 有未提交的更改，建议先提交:"
        echo "   git add ."
        echo "   git commit -m 'Prepare for Render deployment'"
        echo "   git push"
    else
        echo "✅ 工作目录干净"
    fi
fi

# 显示环境变量提醒
echo ""
echo "🔑 环境变量配置提醒"
echo "==================="
echo "在Render控制台中需要设置以下环境变量:"
echo ""
echo "必需变量:"
echo "  SEARCH_API=duckduckgo"
echo "  HOST=0.0.0.0"
echo "  PORT=8000"
echo ""
echo "可选变量 (根据需要设置):"
echo "  OPENAI_API_KEY=your-openai-api-key"
echo "  TAVILY_API_KEY=your-tavily-api-key"
echo "  BRAVE_SEARCH_API_KEY=your-brave-search-api-key"
echo ""

# 显示后续步骤
echo "📋 后续步骤"
echo "==========="
echo "1. 确保代码已推送到Git仓库"
echo "2. 登录 https://render.com/"
echo "3. 点击 'New +' → 'Blueprint'"
echo "4. 连接你的Git仓库"
echo "5. 选择包含 render.yaml 的仓库"
echo "6. 在服务创建后设置环境变量"
echo "7. 等待部署完成"
echo ""
echo "📖 详细说明请参考: RENDER_DEPLOYMENT.md"
echo ""
echo "🎉 准备完成！现在可以开始部署到Render了！" 