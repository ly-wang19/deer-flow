#!/bin/bash

# 前端启动脚本

set -e

echo "启动 DeerFlow 前端应用..."

# 确保我们在web目录中
cd /opt/render/project/src/web || cd ./web || { echo "无法找到web目录"; exit 1; }

echo "当前目录: $(pwd)"
echo "启动Next.js应用..."

# 启动应用
npm start 