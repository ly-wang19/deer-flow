#!/bin/bash

# 构建脚本 - 为Render部署准备后端应用

set -e  # 在任何命令失败时退出

echo "开始构建 DeerFlow 后端应用..."

# 确保使用正确的Python版本
python --version

# 安装系统级依赖（如果需要）
# apt-get update && apt-get install -y some-package

# 安装uv包管理器（如果没有安装）
if ! command -v uv &> /dev/null; then
    echo "安装 uv 包管理器..."
    pip install uv
fi

# 安装Python依赖
echo "安装Python依赖..."
uv sync --locked

# 创建必要的目录
mkdir -p logs
mkdir -p tmp

# 复制配置文件模板（如果不存在）
if [ ! -f "conf.yaml" ]; then
    echo "复制配置文件模板..."
    cp conf.yaml.example conf.yaml
fi

echo "构建完成！" 