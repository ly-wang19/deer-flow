# 🦌 DeerFlow Render 部署指南

本指南将帮助你将 DeerFlow 项目部署到 Render 云平台。

## 📋 部署概览

DeerFlow 包含两个主要组件：
- **后端API服务**: Python FastAPI 应用
- **前端Web服务**: Next.js React 应用

## 🚀 方法一: 使用 Render Blueprint (推荐)

### 第一步：准备代码库

1. **将代码推送到Git仓库**
```bash
# 如果还没有Git仓库
git init
git add .
git commit -m "Initial commit for Render deployment"

# 推送到GitHub/GitLab等
git remote add origin https://github.com/your-username/deer-flow.git
git push -u origin main
```

2. **更新render.yaml文件**
编辑 `render.yaml` 文件，将仓库地址改为你的实际地址：
```yaml
repo: https://github.com/your-username/deer-flow.git  # 替换为你的仓库地址
```

### 第二步：在Render中创建Blueprint

1. 登录 [Render](https://render.com/)
2. 点击 "New +" → "Blueprint"
3. 连接你的Git仓库
4. 选择包含 `render.yaml` 的仓库
5. 点击 "Apply" 创建服务

### 第三步：配置环境变量

在Render控制台中为后端API服务设置环境变量：

**必需的环境变量：**
- `SEARCH_API`: `duckduckgo` (推荐，无需API密钥)
- `HOST`: `0.0.0.0`
- `PORT`: `8000`

**可选的环境变量：**
- `OPENAI_API_KEY`: 你的OpenAI API密钥
- `TAVILY_API_KEY`: Tavily搜索API密钥 (如果使用)
- `BRAVE_SEARCH_API_KEY`: Brave搜索API密钥 (如果使用)

### 第四步：验证部署

部署完成后，你将得到两个服务：
- 后端API: `https://deer-flow-api-xxx.onrender.com`
- 前端Web: `https://deer-flow-web-xxx.onrender.com`

## 🔧 方法二: 手动创建服务

### 部署后端API服务

1. 在Render控制台点击 "New +" → "Web Service"
2. 连接你的Git仓库
3. 配置服务：
   - **Name**: `deer-flow-api`
   - **Environment**: `Python 3`
   - **Build Command**: `./build.sh`
   - **Start Command**: `./start.sh`
   - **Branch**: `main`

4. 设置环境变量 (参考上述列表)

5. 点击 "Create Web Service"

### 部署前端Web服务

1. 在Render控制台点击 "New +" → "Web Service"
2. 连接你的Git仓库
3. 配置服务：
   - **Name**: `deer-flow-web`
   - **Environment**: `Node`
   - **Root Directory**: `web`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
   - **Branch**: `main`

4. 设置环境变量：
   - `NEXT_PUBLIC_API_URL`: 后端API服务的URL (如 `https://deer-flow-api-xxx.onrender.com`)

5. 点击 "Create Web Service"

## ⚙️ 高级配置

### 自定义域名

在Render控制台中，你可以为每个服务添加自定义域名：
1. 进入服务设置
2. 点击 "Custom Domains"
3. 添加你的域名并配置DNS

### 扩展配置

如果需要更高的性能，可以升级到付费计划：
- **Starter**: $7/月，更稳定的性能
- **Pro**: $25/月，自动扩展和更多资源

### SSL证书

Render自动为所有服务提供免费的SSL证书。

## 🔍 故障排除

### 常见问题

1. **构建失败**
   - 检查 `build.sh` 脚本是否有执行权限
   - 查看构建日志了解具体错误信息

2. **服务启动失败**
   - 检查 `start.sh` 脚本
   - 确认所有必需的环境变量已设置

3. **前端无法连接后端**
   - 确认 `NEXT_PUBLIC_API_URL` 设置正确
   - 检查后端服务的健康检查端点 `/health`

4. **内存不足**
   - Render免费版有512MB内存限制
   - 考虑升级到付费计划

### 查看日志

在Render控制台中查看服务日志：
1. 进入服务详情页
2. 点击 "Logs" 标签
3. 查看实时日志输出

### 健康检查

后端服务包含健康检查端点：
- URL: `https://your-api-service.onrender.com/health`
- 响应: `{"status": "healthy", "service": "deer-flow-api", "version": "0.1.0"}`

## 📊 监控和维护

### 服务监控

Render提供基本的服务监控：
- CPU和内存使用情况
- 响应时间统计
- 错误率监控

### 自动部署

当你推送代码到连接的Git分支时，Render会自动重新部署服务。

### 备份策略

- 定期备份你的Git仓库
- 导出重要的环境变量配置
- 保存自定义域名和SSL配置

## 💡 性能优化建议

1. **启用缓存**: 考虑使用Redis缓存频繁请求的数据
2. **CDN**: 对于静态资源使用CDN加速
3. **数据库**: 如果需要持久化存储，考虑添加PostgreSQL数据库
4. **负载均衡**: 对于高流量应用，考虑多实例部署

## 📞 支持

如果遇到问题：
1. 查看 [Render文档](https://render.com/docs)
2. 检查项目的GitHub Issues
3. 联系Render支持团队

---

🎉 恭喜！你的DeerFlow应用现在已经部署到Render平台了！ 