#!/bin/bash

echo "🧹 清理残留进程和端口..."

# 杀死可能的 Electron 进程
echo "正在查找 Electron 进程..."
pkill -f "electron" 2>/dev/null || echo "没有找到 Electron 进程"

# 杀死可能占用端口的进程
echo "正在检查端口占用情况..."

# 检查并杀死占用 3001 端口的进程
PORT_3001=$(lsof -ti:3001 2>/dev/null)
if [ ! -z "$PORT_3001" ]; then
    echo "发现端口 3001 被进程 $PORT_3001 占用，正在终止..."
    kill -9 $PORT_3001 2>/dev/null || echo "无法终止进程 $PORT_3001"
else
    echo "端口 3001 未被占用"
fi

# 检查并杀死占用 3002 端口的进程
PORT_3002=$(lsof -ti:3002 2>/dev/null)
if [ ! -z "$PORT_3002" ]; then
    echo "发现端口 3002 被进程 $PORT_3002 占用，正在终止..."
    kill -9 $PORT_3002 2>/dev/null || echo "无法终止进程 $PORT_3002"
else
    echo "端口 3002 未被占用"
fi

# 检查并杀死占用 5173 端口的进程 (Vite dev server)
PORT_5173=$(lsof -ti:5173 2>/dev/null)
if [ ! -z "$PORT_5173" ]; then
    echo "发现端口 5173 被进程 $PORT_5173 占用，正在终止..."
    kill -9 $PORT_5173 2>/dev/null || echo "无法终止进程 $PORT_5173"
else
    echo "端口 5173 未被占用"
fi

# 检查并杀死占用 5174 端口的进程 (Vite dev server)
PORT_5174=$(lsof -ti:5174 2>/dev/null)
if [ ! -z "$PORT_5174" ]; then
    echo "发现端口 5174 被进程 $PORT_5174 占用，正在终止..."
    kill -9 $PORT_5174 2>/dev/null || echo "无法终止进程 $PORT_5174"
else
    echo "端口 5174 未被占用"
fi

# 检查并杀死占用 5858 端口的进程 (Electron debugger)
PORT_5858=$(lsof -ti:5858 2>/dev/null)
if [ ! -z "$PORT_5858" ]; then
    echo "发现端口 5858 被进程 $PORT_5858 占用，正在终止..."
    kill -9 $PORT_5858 2>/dev/null || echo "无法终止进程 $PORT_5858"
else
    echo "端口 5858 未被占用"
fi

# 检查并杀死占用 9222 端口的进程 (DevTools)
PORT_9222=$(lsof -ti:9222 2>/dev/null)
if [ ! -z "$PORT_9222" ]; then
    echo "发现端口 9222 被进程 $PORT_9222 占用，正在终止..."
    kill -9 $PORT_9222 2>/dev/null || echo "无法终止进程 $PORT_9222"
else
    echo "端口 9222 未被占用"
fi

# 清理可能的临时文件
echo "清理临时文件..."
rm -rf dist-electron 2>/dev/null || echo "没有找到 dist-electron 目录"

echo "✅ 清理完成！现在可以重新启动应用了。"
echo ""
echo "使用以下命令启动应用："
echo "yarn dev"
