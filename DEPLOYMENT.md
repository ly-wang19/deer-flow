# 🦌 DeerFlow 阿里云部署指南

本指南将帮助你将 DeerFlow 项目部署到阿里云 Ubuntu 服务器上。

## 📋 服务器信息

- **实例ID**: 4666380dad034cdbb772f34f3d926846  
- **公网IP**: 47.122.147.17
- **私网IP**: 172.18.6.72
- **配置**: 2 vCPU / 2 GiB RAM / 40 GiB ESSD
- **操作系统**: Ubuntu-bynr
- **到期时间**: 2026年6月5日

## 🚀 快速部署

### 第一步：准备服务器环境

1. **SSH 连接到服务器**
```bash
ssh root@47.122.147.17
# 或使用你的用户名
ssh username@47.122.147.17
```

2. **创建非 root 用户（如果还没有）**
```bash
# 创建新用户
sudo adduser deerflow
sudo usermod -aG sudo deerflow

# 切换到新用户
su - deerflow
```

3. **运行环境安装脚本**
```bash
# 上传 deploy.sh 到服务器，然后执行
chmod +x deploy.sh
./deploy.sh
```

4. **重新登录以获取 Docker 权限**
```bash
# 退出当前会话并重新登录
exit
ssh deerflow@47.122.147.17
```

### 第二步：上传项目文件

1. **从本地上传项目到服务器**
```bash
# 在本地执行（压缩项目文件）
tar -czf deer-flow.tar.gz --exclude='.git' --exclude='__pycache__' --exclude='.venv' --exclude='node_modules' .

# 上传到服务器
scp deer-flow.tar.gz deerflow@47.122.147.17:~/

# 在服务器上解压
ssh deerflow@47.122.147.17
cd ~
tar -xzf deer-flow.tar.gz
cd deer-flow/
```

2. **或者使用 Git 克隆**
```bash
# 在服务器上执行
cd ~
git clone https://github.com/bytedance/deer-flow.git
cd deer-flow/
```

### 第三步：部署项目

1. **运行部署脚本**
```bash
chmod +x deploy-project.sh
./deploy-project.sh
```

2. **配置 API Keys**
```bash
# 编辑 .env 文件
nano .env

# 配置你的 API Keys：
# TAVILY_API_KEY=your-tavily-api-key
# BRAVE_SEARCH_API_KEY=your-brave-search-api-key
# 或者使用 DuckDuckGo（无需 API Key）
SEARCH_API=duckduckgo
```

3. **配置 LLM 模型**
```bash
# 编辑 conf.yaml 文件
nano conf.yaml

# 配置你的 LLM 模型设置
# 参考 docs/configuration_guide.md
```

### 第四步：配置安全组（重要！）

在阿里云控制台中，确保安全组规则允许以下端口：

- **22** (SSH)
- **80** (HTTP)  
- **443** (HTTPS)
- **3000** (前端)
- **8000** (后端)

### 第五步：验证部署

1. **检查服务状态**
```bash
docker-compose -f docker-compose.prod.yml ps
```

2. **访问应用**
- 前端：http://47.122.147.17:3000
- 后端API：http://47.122.147.17:8000

## ⚙️ 高级配置

### 系统服务配置（可选）

让服务在系统重启后自动启动：

```bash
chmod +x install-service.sh
./install-service.sh
```

### Nginx 反向代理（推荐）

配置 Nginx 反向代理以获得更好的性能：

```bash
chmod +x setup-nginx.sh
./setup-nginx.sh
```

配置完成后，你可以通过 http://47.122.147.17 直接访问应用。

## 🔧 常用管理命令

### Docker 服务管理
```bash
# 查看服务状态
docker-compose -f docker-compose.prod.yml ps

# 查看日志
docker-compose -f docker-compose.prod.yml logs -f

# 重启服务
docker-compose -f docker-compose.prod.yml restart

# 停止服务
docker-compose -f docker-compose.prod.yml down

# 更新代码后重新部署
git pull  # 如果使用 Git
docker-compose -f docker-compose.prod.yml up --build -d
```

### 系统服务管理（如果安装了系统服务）
```bash
# 启动服务
sudo systemctl start deer-flow

# 停止服务
sudo systemctl stop deer-flow

# 重启服务
sudo systemctl restart deer-flow

# 查看状态
sudo systemctl status deer-flow

# 查看日志
sudo journalctl -u deer-flow -f
```

## 🐛 故障排除

### 常见问题

1. **端口被占用**
```bash
# 检查端口使用情况
sudo netstat -tlnp | grep :8000
sudo netstat -tlnp | grep :3000

# 杀死占用端口的进程
sudo kill -9 <PID>
```

2. **Docker 权限问题**
```bash
# 确保用户在 docker 组中
sudo usermod -aG docker $USER
# 重新登录
```

3. **内存不足**
```bash
# 检查内存使用
free -h
# 清理 Docker 缓存
docker system prune -f
```

4. **查看详细错误日志**
```bash
# 查看容器日志
docker logs deer-flow-backend
docker logs deer-flow-frontend

# 查看系统日志
sudo journalctl -xe
```

### 性能优化

1. **启用 Swap（如果内存不足）**
```bash
# 创建 2GB swap 文件
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久启用
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

2. **Docker 资源限制**
```bash
# 在 docker-compose.prod.yml 中添加资源限制
services:
  backend:
    # ... 其他配置
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

## 📚 配置文件说明

### .env 文件
包含环境变量和 API Keys 配置。

### conf.yaml 文件  
包含 LLM 模型配置，详细说明请参考 `docs/configuration_guide.md`。

### docker-compose.prod.yml
生产环境的 Docker Compose 配置文件。

## 🔐 安全建议

1. **修改默认端口**（可选）
2. **配置防火墙规则**
3. **定期更新系统**
4. **使用强密码**
5. **考虑配置 SSL 证书**

## 📞 支持

如果遇到问题，请：

1. 检查日志文件
2. 参考 [项目文档](https://github.com/bytedance/deer-flow)
3. 提交 GitHub Issue

---

🎉 **部署完成后，享受你的 DeerFlow AI 研究助手吧！** 