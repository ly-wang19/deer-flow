#!/bin/bash

# 启动脚本 - 启动DeerFlow后端API服务器

set -e  # 在任何命令失败时退出

echo "启动 DeerFlow API 服务器..."

# 设置默认环境变量
export HOST=${HOST:-"0.0.0.0"}
export PORT=${PORT:-"8000"}
export LOG_LEVEL=${LOG_LEVEL:-"info"}

# 显示环境信息
echo "Python版本: $(python --version)"
echo "服务器地址: ${HOST}:${PORT}"
echo "日志级别: ${LOG_LEVEL}"

# 启动服务器
echo "正在启动服务器..."
uv run python server.py --host ${HOST} --port ${PORT} --log-level ${LOG_LEVEL} 