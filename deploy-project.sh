#!/bin/bash

# DeerFlow 项目部署脚本
# 在完成环境安装后运行此脚本

set -e

echo "🦌 DeerFlow 项目部署开始..."
echo "================================"

# 检查当前目录是否为项目根目录
if [ ! -f "pyproject.toml" ] || [ ! -f "main.py" ]; then
    echo "❌ 请在项目根目录下运行此脚本"
    exit 1
fi

# 创建必要的配置文件
echo "📝 配置项目文件..."

# 创建 .env 文件（如果不存在）
if [ ! -f ".env" ]; then
    echo "创建 .env 配置文件..."
    cat > .env << 'EOF'
# API Keys - 请根据你的需求配置
TAVILY_API_KEY=your-tavily-api-key-here
BRAVE_SEARCH_API_KEY=your-brave-search-api-key-here

# Search Engine Configuration
SEARCH_API=duckduckgo

# Server Configuration
HOST=0.0.0.0
PORT=8000
FRONTEND_PORT=3000

# Next.js Configuration
NEXT_PUBLIC_API_URL=http://47.122.147.17:8000

# TTS Configuration (Optional)
# VOLCENGINE_ACCESS_KEY=your-volcengine-access-key
# VOLCENGINE_SECRET_KEY=your-volcengine-secret-key

# RAG Configuration (Optional)
# RAG_PROVIDER=ragflow
# RAGFLOW_API_URL=http://localhost:9388
# RAGFLOW_API_KEY=ragflow-xxx
EOF
    echo "✅ .env 文件已创建，请根据需要修改配置"
else
    echo "✅ .env 文件已存在"
fi

# 创建 conf.yaml 文件（如果不存在）
if [ ! -f "conf.yaml" ]; then
    echo "创建 conf.yaml 配置文件..."
    cp conf.yaml.example conf.yaml
    echo "✅ conf.yaml 文件已创建，请根据需要修改LLM配置"
else
    echo "✅ conf.yaml 文件已存在"
fi

# 更新 docker-compose.yml 以适应生产环境
echo "📝 更新 Docker Compose 配置..."
cat > docker-compose.prod.yml << 'EOF'
services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: deer-flow-backend
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - ./conf.yaml:/app/conf.yaml
      - ./assets:/app/assets
    restart: unless-stopped
    networks:
      - deer-flow-network
    environment:
      - HOST=0.0.0.0
      - PORT=8000

  frontend:
    build:
      context: ./web
      dockerfile: Dockerfile
      args:
        - NEXT_PUBLIC_API_URL=http://47.122.147.17:8000
    container_name: deer-flow-frontend
    ports:
      - "3000:3000"
    env_file:
      - .env
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - deer-flow-network

networks:
  deer-flow-network:
    driver: bridge
EOF

# 创建生产环境的 Dockerfile for frontend
echo "📝 创建前端 Dockerfile..."
mkdir -p web
cat > web/Dockerfile << 'EOF'
FROM node:22-alpine AS base

# Install dependencies only when needed
FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json pnpm-lock.yaml* ./
RUN corepack enable pnpm && pnpm i --frozen-lockfile

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
ENV NEXT_TELEMETRY_DISABLED 1

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN corepack enable pnpm && pnpm build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
# Uncomment the following line in case you want to disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
CMD HOSTNAME="0.0.0.0" node server.js
EOF

# 停止现有容器（如果存在）
echo "🛑 停止现有容器..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# 清理旧镜像（可选）
echo "🧹 清理旧镜像..."
docker system prune -f 2>/dev/null || true

# 构建并启动服务
echo "🚀 构建并启动服务..."
docker-compose -f docker-compose.prod.yml up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose -f docker-compose.prod.yml ps

# 检查后端健康状态
echo "🔍 检查后端服务..."
if curl -f http://localhost:8000/health 2>/dev/null; then
    echo "✅ 后端服务运行正常"
else
    echo "⚠️  后端服务可能未完全启动，请检查日志"
fi

# 显示日志
echo "📋 显示最近的日志..."
docker-compose -f docker-compose.prod.yml logs --tail=20

echo ""
echo "🎉 部署完成！"
echo "================================"
echo "服务访问地址："
echo "- 前端 Web UI: http://47.122.147.17:3000"
echo "- 后端 API: http://47.122.147.17:8000"
echo ""
echo "常用命令："
echo "- 查看日志: docker-compose -f docker-compose.prod.yml logs -f"
echo "- 重启服务: docker-compose -f docker-compose.prod.yml restart"
echo "- 停止服务: docker-compose -f docker-compose.prod.yml down"
echo "- 更新代码后重新部署: docker-compose -f docker-compose.prod.yml up --build -d"
echo ""
echo "⚠️  重要提醒："
echo "1. 请编辑 .env 文件配置你的 API Keys"
echo "2. 请编辑 conf.yaml 文件配置你的 LLM 模型"
echo "3. 确保阿里云安全组开放了 3000 和 8000 端口"
echo "================================" 