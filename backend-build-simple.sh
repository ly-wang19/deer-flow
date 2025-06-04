#!/bin/bash

# 后端简化构建脚本

set -e

echo "开始构建 DeerFlow 后端应用..."

# 显示当前信息
echo "Python版本: $(python --version)"
echo "当前目录: $(pwd)"
echo "文件列表:"
ls -la

# 安装uv
echo "安装uv包管理器..."
pip install uv

# 检查uv.lock文件
if [ -f "uv.lock" ]; then
    echo "找到uv.lock文件，使用锁定版本安装..."
    uv sync --locked
else
    echo "未找到uv.lock文件，进行常规安装..."
    uv sync
fi

# 创建必要目录
echo "创建必要目录..."
mkdir -p logs tmp

# 复制配置文件
if [ -f "conf.yaml.example" ]; then
    echo "复制配置文件..."
    cp conf.yaml.example conf.yaml
else
    echo "警告: conf.yaml.example 不存在"
fi

echo "后端构建完成！" 