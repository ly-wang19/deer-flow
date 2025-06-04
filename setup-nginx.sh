#!/bin/bash

# Nginx 反向代理配置脚本
# 可选：为更好的生产环境体验

set -e

echo "🌐 配置 Nginx 反向代理..."
echo "================================"

# 安装 Nginx
echo "📦 安装 Nginx..."
sudo apt update
sudo apt install -y nginx

# 创建 Nginx 配置文件
echo "📝 创建 Nginx 配置..."
sudo tee /etc/nginx/sites-available/deer-flow << 'EOF'
server {
    listen 80;
    server_name 47.122.147.17;

    # 前端
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # 后端 API
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # 健康检查
    location /health {
        proxy_pass http://localhost:8000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 启用站点
echo "✅ 启用 Nginx 站点..."
sudo ln -sf /etc/nginx/sites-available/deer-flow /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 测试 Nginx 配置
echo "🔍 测试 Nginx 配置..."
sudo nginx -t

# 启动并启用 Nginx
echo "🚀 启动 Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# 重载 Nginx 配置
sudo systemctl reload nginx

echo ""
echo "🎉 Nginx 配置完成！"
echo "================================"
echo "现在你可以通过以下地址访问："
echo "- 主站点: http://47.122.147.17"
echo "- API 接口: http://47.122.147.17/api/"
echo "- 健康检查: http://47.122.147.17/health"
echo ""
echo "Nginx 管理命令："
echo "- 重启 Nginx: sudo systemctl restart nginx"
echo "- 重载配置: sudo systemctl reload nginx"
echo "- 查看状态: sudo systemctl status nginx"
echo "- 查看日志: sudo tail -f /var/log/nginx/access.log"
echo "================================" 