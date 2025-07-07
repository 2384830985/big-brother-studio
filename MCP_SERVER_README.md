# MCP 服务器 - Streamable HTTP 支持

本项目已成功集成了支持 Streamable HTTP 协议的 MCP (Model Context Protocol) 服务器。

## 🚀 功能特性

### 核心功能
- ✅ **Streamable HTTP 协议支持** - 完整的流式数据传输
- ✅ **OpenAI API 兼容** - 支持标准的 `/v1/chat/completions` 接口
- ✅ **实时消息流** - Server-Sent Events (SSE) 支持
- ✅ **多对话管理** - 支持多个并发对话会话
- ✅ **消息历史** - 完整的对话历史记录和检索
- ✅ **健康监控** - 服务器状态和统计信息

### 技术特性
- 🔄 **流式响应** - 支持字符级流式输出
- 📡 **CORS 支持** - 跨域资源共享
- 🔍 **调试友好** - 详细的日志和错误处理
- ⚡ **高性能** - 基于 Express.js 的轻量级实现
- 🛡️ **类型安全** - 完整的 TypeScript 类型定义

## 📋 API 接口

### 1. 健康检查
```http
GET /health
```

**响应示例:**
```json
{
  "status": "healthy",
  "timestamp": 1703123456789,
  "connections": 2,
  "conversations": 5
}
```

### 2. OpenAI 兼容接口

#### 非流式聊天
```http
POST /v1/chat/completions
Content-Type: application/json

{
  "model": "mcp-default",
  "messages": [
    {"role": "user", "content": "你好"}
  ],
  "stream": false
}
```

#### 流式聊天
```http
POST /v1/chat/completions
Content-Type: application/json

{
  "model": "mcp-default",
  "messages": [
    {"role": "user", "content": "你好"}
  ],
  "stream": true
}
```

### 3. MCP 特定接口

#### 连接到流式聊天
```http
GET /mcp/chat/stream/:conversationId?
```

#### 发送消息
```http
POST /mcp/chat/send
Content-Type: application/json

{
  "content": "你好，世界！",
  "conversationId": "optional-conversation-id",
  "metadata": {
    "model": "mcp-default",
    "stream": true
  }
}
```

#### 获取对话历史
```http
GET /mcp/conversations/:conversationId
```

#### 获取所有对话
```http
GET /mcp/conversations
```

#### 清空对话
```http
DELETE /mcp/conversations/:conversationId
```

## 🛠️ 使用方法

### 1. 启动应用
```bash
# 开发模式
npm run dev

# 或者手动编译并启动
npm run compile:electron
npm run electron:serve
```

### 2. 访问 MCP 聊天界面
1. 启动应用后，点击左侧导航栏的 **MCP 聊天** 图标 (🔗)
2. 系统会自动连接到 MCP 服务器 (端口 3002)
3. 开始与 MCP 助手对话

### 3. 服务器配置
MCP 服务器默认配置：
- **端口**: 3002
- **CORS**: 启用
- **流式传输**: 启用
- **最大连接数**: 100

## 🧪 测试

### 运行测试脚本
```bash
# 确保应用正在运行，然后执行测试
node scripts/test-mcp-server.js
```

测试脚本会验证以下功能：
- ✅ 健康检查
- ✅ 消息发送
- ✅ 对话历史获取
- ✅ 对话列表获取
- ✅ OpenAI 兼容接口
- ✅ 流式响应

### 手动测试
你也可以使用 curl 或 Postman 进行手动测试：

```bash
# 健康检查
curl http://localhost:3002/health

# 发送消息
curl -X POST http://localhost:3002/mcp/chat/send \
  -H "Content-Type: application/json" \
  -d '{"content": "你好，MCP！"}'

# OpenAI 兼容接口
curl -X POST http://localhost:3002/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mcp-default",
    "messages": [{"role": "user", "content": "介绍一下 MCP 协议"}],
    "stream": false
  }'
```

## 🏗️ 架构说明

### 文件结构
```
electron/main/
├── mcp-server.ts          # MCP 服务器核心实现
└── index.ts              # 主进程，集成 MCP 服务器

src/views/mcp/
└── MCPChatView.vue       # MCP 聊天界面组件

scripts/
└── test-mcp-server.js    # 测试脚本
```

### 核心组件

#### MCPServer 类
- **职责**: MCP 协议服务器实现
- **特性**:
  - Express.js 基础
  - SSE 流式传输
  - OpenAI API 兼容
  - 对话管理
  - 统计监控

#### MCPChatView 组件
- **职责**: 前端聊天界面
- **特性**:
  - 实时消息显示
  - 流式输入效果
  - 对话历史管理
  - 服务器状态监控

## 🔧 配置选项

### MCP 服务器配置
```typescript
interface MCPServerConfig {
  port: number              // 服务器端口
  enableCors?: boolean      // 是否启用 CORS
  maxConnections?: number   // 最大连接数
  streamingEnabled?: boolean // 是否启用流式传输
}
```

### 消息格式
```typescript
interface MCPMessage {
  id: string                // 消息唯一标识
  role: 'user' | 'assistant' | 'system'
  content: string           // 消息内容
  timestamp: number         // 时间戳
  metadata?: {              // 元数据
    model?: string
    temperature?: number
    maxTokens?: number
    stream?: boolean
  }
}
```

## 🚨 注意事项

1. **端口冲突**: 确保端口 3002 未被其他应用占用
2. **防火墙**: 如需外部访问，请配置防火墙规则
3. **性能**: 大量并发连接时注意服务器性能
4. **安全**: 生产环境请添加适当的认证和授权机制

## 🔍 故障排除

### 常见问题

#### 1. 连接失败
- 检查 MCP 服务器是否正常启动
- 确认端口 3002 可访问
- 查看控制台错误日志

#### 2. 消息发送失败
- 检查请求格式是否正确
- 确认服务器健康状态
- 查看网络连接

#### 3. 流式响应异常
- 检查 SSE 连接状态
- 确认浏览器支持 EventSource
- 查看服务器日志

### 调试技巧
1. 打开浏览器开发者工具查看网络请求
2. 查看 Electron 主进程控制台日志
3. 使用测试脚本验证服务器功能
4. 检查服务器统计信息面板

## 🎯 下一步计划

- [ ] 添加用户认证和授权
- [ ] 支持更多 AI 模型集成
- [ ] 实现消息搜索功能
- [ ] 添加文件上传支持
- [ ] 优化性能和内存使用
- [ ] 添加更多测试用例

## 📞 支持

如果遇到问题或有建议，请：
1. 查看本文档的故障排除部分
2. 运行测试脚本诊断问题
3. 检查控制台日志获取详细错误信息

---

🎉 **恭喜！** 你已经成功集成了支持 Streamable HTTP 的 MCP 服务器！
