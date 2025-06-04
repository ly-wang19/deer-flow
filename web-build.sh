#!/bin/bash

# 前端构建脚本 - 确保在正确目录中构建

set -e  # 在任何命令失败时退出

echo "开始构建 DeerFlow 前端应用..."

# 确保我们在web目录中
cd /opt/render/project/src/web || cd ./web || { echo "无法找到web目录"; exit 1; }

echo "当前目录: $(pwd)"
echo "Node.js版本: $(node --version)"
echo "npm版本: $(npm --version)"

# 检查package.json是否存在
if [ ! -f "package.json" ]; then
    echo "错误: package.json 不存在"
    ls -la
    exit 1
fi

# 清理并安装依赖
echo "清理现有依赖..."
rm -rf node_modules package-lock.json

echo "安装依赖..."
npm install

echo "构建应用..."
npm run build

echo "前端构建完成！" 