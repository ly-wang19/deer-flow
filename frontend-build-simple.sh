#!/bin/bash

# 前端简化构建脚本

set -e

echo "开始构建 DeerFlow 前端应用..."

# 显示当前信息
echo "Node.js版本: $(node --version)"
echo "npm版本: $(npm --version)"
echo "当前目录: $(pwd)"
echo "文件列表:"
ls -la

# 检查package.json
if [ ! -f "package.json" ]; then
    echo "错误: package.json 不存在"
    exit 1
fi

# 清理并重新生成package-lock.json
echo "清理现有依赖..."
rm -rf node_modules package-lock.json

# 安装依赖
echo "安装依赖..."
npm install

# 验证安装
echo "验证安装..."
npm list --depth=0

# 构建应用
echo "构建应用..."
npm run build

echo "前端构建完成！" 