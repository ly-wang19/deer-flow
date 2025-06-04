#!/bin/bash

# 系统服务安装脚本
# 让 DeerFlow 在系统重启后自动启动

set -e

echo "🔧 安装 DeerFlow 系统服务..."
echo "================================"

# 获取当前用户和项目路径
CURRENT_USER=$(whoami)
PROJECT_PATH=$(pwd)

# 检查是否在项目根目录
if [ ! -f "pyproject.toml" ] || [ ! -f "main.py" ]; then
    echo "❌ 请在项目根目录下运行此脚本"
    exit 1
fi

# 创建系统服务文件
echo "📝 创建 systemd 服务文件..."
sudo tee /etc/systemd/system/deer-flow.service > /dev/null << EOF
[Unit]
Description=DeerFlow Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_PATH
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
ExecReload=/usr/local/bin/docker-compose -f docker-compose.prod.yml restart
TimeoutStartSec=0
User=$CURRENT_USER
Group=docker

[Install]
WantedBy=multi-user.target
EOF

# 重载 systemd 配置
echo "🔄 重载 systemd 配置..."
sudo systemctl daemon-reload

# 启用服务
echo "✅ 启用 DeerFlow 服务..."
sudo systemctl enable deer-flow.service

# 启动服务
echo "🚀 启动 DeerFlow 服务..."
sudo systemctl start deer-flow.service

# 检查服务状态
echo "🔍 检查服务状态..."
sudo systemctl status deer-flow.service --no-pager

echo ""
echo "🎉 系统服务安装完成！"
echo "================================"
echo "服务管理命令："
echo "- 启动服务: sudo systemctl start deer-flow"
echo "- 停止服务: sudo systemctl stop deer-flow"
echo "- 重启服务: sudo systemctl restart deer-flow"
echo "- 查看状态: sudo systemctl status deer-flow"
echo "- 查看日志: sudo journalctl -u deer-flow -f"
echo "- 禁用自启: sudo systemctl disable deer-flow"
echo ""
echo "现在 DeerFlow 将在系统重启后自动启动！"
echo "================================" 