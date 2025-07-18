<template>
  <div class="h-full flex flex-col bg-gray-50">
    <!-- 顶部状态栏 -->
    <div class="bg-white border-b border-gray-200 px-6 py-2">
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <h1 class="text-base font-medium text-gray-900 absolute top-3">
            聊天
          </h1>
        </div>
        <div
          class="flex items-center space-x-1"
          style="height: 32px;"
        >
          <!-- 选择模块 -->
          <div class="flex items-center">
            <ChatModel />
          </div>

          <!-- 模型选择器 -->
          <div class="flex items-center">
            <ChatModelServer />
          </div>

          <!-- MCP 选择器 -->
          <div class="flex items-center">
            <ChatMcp />
          </div>

          <div class="flex items-center">
            <a-button
              size="small"
              @click="showStats = !showStats"
            >
              统计信息
            </a-button>
          </div>
        </div>
      </div>

      <!-- 统计信息面板 -->
      <div
        v-if="showStats && serverStats"
        class="mt-4 p-4 bg-gray-50 rounded-lg"
      >
        <div class="grid grid-cols-4 gap-4 text-sm">
          <div>
            <span class="text-gray-600">连接数:</span>
            <span class="ml-2 font-medium">{{ serverStats.connectedClients }}</span>
          </div>
          <div>
            <span class="text-gray-600">对话数:</span>
            <span class="ml-2 font-medium">{{ serverStats.totalConversations }}</span>
          </div>
          <div>
            <span class="text-gray-600">消息数:</span>
            <span class="ml-2 font-medium">{{ serverStats.totalMessages }}</span>
          </div>
          <div>
            <span class="text-gray-600">端口:</span>
            <span class="ml-2 font-medium">{{ serverStats.port }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 聊天内容区域 -->
    <div class="flex-1 flex overflow-hidden">
      <!-- 左侧标签页区域 -->
      <ChatSidebar
        :conversations="conversations"
        :current-conversation-id="currentConversationId"
        @start-new-conversation="startNewConversation"
        @switch-conversation="switchConversation"
        @delete-conversation="deleteConversation"
      />

      <!-- 聊天区域 -->
      <div class="flex-1 flex flex-col">
        <!-- 消息列表 -->
        <div
          ref="messagesContainer"
          class="flex-1 overflow-y-auto px-4 py-4 space-y-3"
        >
          <!-- 欢迎消息 -->
          <div
            v-if="messages.length === 0 && !streamingMessage"
            class="flex items-center justify-center h-full"
          >
            <div class="text-center">
              <RobotOutlined class="text-6xl text-gray-400 mb-4" />
              <h3 class="text-lg font-medium text-gray-900 mb-2">
                {{ usePlanModeName }}
              </h3>
              <p class="text-gray-500">
                {{ usePlanModeName }}
              </p>
            </div>
          </div>

          <!-- 消息列表 -->
          <div
            v-for="message in messages"
            :key="message.id"
            class="flex"
            :class="message.role === 'user' ? 'justify-end' : 'justify-start'"
          >
            <div
              :class="[
                'max-w-[70%] rounded-2xl px-4 py-3',
                message.role === 'user'
                  ? 'bg-blue-500 text-white'
                  : 'bg-white text-gray-800 shadow-sm border border-gray-200'
              ]"
            >
              <div
                class="text-sm leading-relaxed whitespace-pre-wrap mb-2"
                v-html="formatMessage(message.content)"
              />
              <!-- MCP 工具调用显示 -->
              <MCPToolDisplay
                v-if="message.metadata?.toolCalls || message.metadata?.toolResults"
                :tool-calls="message.metadata?.toolCalls"
                :tool-results="message.metadata?.toolResults"
                class="mb-3"
              />
              <div
                :class="[
                  'text-xs mt-2 opacity-70',
                  message.role === 'user' ? 'text-right text-blue-100' : 'text-left text-gray-500'
                ]"
              >
                {{ formatTime(message.timestamp) }}
                <span
                  v-if="message.metadata?.model"
                  class="ml-2"
                >
                  · {{ message.metadata.model }}
                </span>
              </div>
            </div>
          </div>

          <!-- 流式消息 -->
          <div
            v-if="streamingMessage"
            class="flex justify-start"
          >
            <div class="max-w-[70%] bg-white text-gray-800 shadow-sm border border-gray-200 rounded-2xl px-4 py-3">
              <div
                class="text-sm leading-relaxed whitespace-pre-wrap mb-2"
                v-html="formatMessage(streamingMessage.content)"
              />
              <!-- MCP 工具调用显示 -->
              <MCPToolDisplay
                v-if="streamingMessage.metadata?.toolCalls || streamingMessage.metadata?.toolResults"
                :tool-calls="streamingMessage.metadata?.toolCalls"
                :tool-results="streamingMessage.metadata?.toolResults"
                class="mb-3"
              />
              <div class="text-xs mt-2 text-gray-500 flex items-center">
                <LoadingOutlined class="mr-1" />
                正在输入...
              </div>
            </div>
          </div>
        </div>

        <!-- 输入区域 -->
        <div class="border-t border-gray-200 bg-white px-4 py-3">
          <div class="bg-gray-50 rounded-xl p-3">
            <a-textarea
              v-model:value="inputMessage"
              :placeholder="usePlanModeName"
              :auto-size="{ minRows: 1, maxRows: 4 }"
              class="!border-none !bg-transparent !shadow-none !p-0 text-sm"
              :disabled="!isConnected || isSending"
              @keydown="handleKeyDown"
            />
            <div class="flex justify-between items-center mt-2">
              <div class="flex items-center gap-2">
                <div class="flex items-center gap-2">
                  <div
                    class="w-5 h-5 flex items-center justify-center text-gray-400 cursor-pointer hover:text-blue-500 transition-colors duration-200"
                    title="附件"
                  >
                    <PaperClipOutlined style="font-size: 16px;" />
                  </div>
                  <div
                    class="w-5 h-5 flex items-center justify-center text-gray-400 cursor-pointer hover:text-blue-500 transition-colors duration-200"
                    title="链接"
                  >
                    <LinkOutlined style="font-size: 16px;" />
                  </div>
                  <div
                    class="w-5 h-5 flex items-center justify-center text-gray-400 cursor-pointer hover:text-blue-500 transition-colors duration-200"
                    title="网络搜索"
                    @click="showWebSearchModal = true"
                  >
                    <GlobalOutlined style="font-size: 16px;" />
                  </div>
                </div>
                <!-- 执行环境组件 -->
                <div class="flex items-center">
                  <ExecutionEnvironment />
                </div>
              </div>
              <div class="flex items-center gap-2">
                <a-button
                  size="small"
                  :disabled="messages.length === 0"
                  @click="clearCurrentConversation"
                >
                  清空
                </a-button>
                <a-button
                  type="primary"
                  shape="circle"
                  :loading="isSending"
                  :disabled="!isConnected || !inputMessage.trim()"
                  @click="sendMessage"
                >
                  <template #icon>
                    <ArrowUpOutlined />
                  </template>
                </a-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 网络搜索模态框 -->
    <WebSearchModal
      v-model="showWebSearchModal"
      @search-result="handleSearchResult"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick, computed } from 'vue'
import { message as antMessage } from 'ant-design-vue'
import {
  RobotOutlined,
  LoadingOutlined,
  PaperClipOutlined,
  LinkOutlined,
  GlobalOutlined,
  ArrowUpOutlined,
} from '@ant-design/icons-vue'
import ExecutionEnvironment from '../../components/ExecutionEnvironment.vue'
import { USE_PLAN_MODE, useChatStore, useMCPServiceStore  } from '@/store'
import type { MCPMessage, MCPServerStats } from './chat.type'
import type { SearchResult } from '@/types/webSearch'
import {PostChatSendApi, PostPlanCreateApi} from '@/api/chatApi.ts'
import ChatModel from '@/views/chat/components/chatModel.vue'
import ChatMcp from '@/views/chat/components/chatMcp.vue'
import ChatModelServer from '@/views/chat/components/chatModelServer.vue'
import ChatSidebar from '@/views/chat/components/ChatSidebar.vue'
import MCPToolDisplay from '@/views/chat/components/MCPToolDisplay.vue'
import WebSearchModal from '@/views/chat/components/WebSearchModal.vue'

const chatStore = useChatStore()
const mcpServiceStore = useMCPServiceStore()

// MCP 相关数据
const selectedMCPServers = computed(() => chatStore.selectedMCPServers)
const usePlanModeName = computed(() => chatStore.usePlanModeName)
const selectedModel = computed(() => chatStore.selectedModel)
const currentConversationId = computed(() => chatStore.currentConversationId)
// 响应式数据
const messages = computed(() => chatStore.messages)

const streamingMessage = ref<MCPMessage | null>(null)
const inputMessage = ref('')
const isSending = ref(false)
const conversations = computed(() => chatStore.sortedConversations)
const serverStats = ref<MCPServerStats | null>(null)
const showStats = ref(false)
const showWebSearchModal = ref(false)

// DOM 引用
const messagesContainer = ref<HTMLElement>()

// 计算属性
const isConnected = computed(() => true)

const usePlanMode = computed(() => chatStore.usePlanMode)

// 获取启用的MCP服务器
const enabledMCPServers = computed(() => mcpServiceStore.enabledMCPServers)

// 格式化时间
const formatTime = (timestamp: number) => {
  return new Date(timestamp).toLocaleTimeString('zh-CN', {
    hour: '2-digit',
    minute: '2-digit',
  })
}

// 格式化消息内容
const formatMessage = (content: string) => {
  return content
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code class="bg-gray-100 px-1 rounded">$1</code>')
}

// 滚动到底部
const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

// 连接到 MCP 服务器
const connectToMCPServer = async () => {

  try {
    // 监听主进程的回复
    window.ipcRenderer.on('streaming', (_event, message) => {
      streamingMessage.value = {
        id: message.messageId,
        role: message.role,
        content: message.content,
        timestamp: message.timestamp,
      }
      scrollToBottom()
    })
    // 监听主进程的回复
    window.ipcRenderer.on('message', (_event, message) => {
      if (message.message) {
        chatStore.spliceMessages(message.message)
        streamingMessage.value = null
        scrollToBottom()
      }
    })
  } catch (error) {
    console.error('[MCP Chat] Failed to connect:', error)
    antMessage.error('无法连接到 MCP 服务器')
  }
}

// 发送消息
const sendMessage = async () => {
  if (!inputMessage.value.trim() || !isConnected.value || isSending.value) {
    return
  }

  const content = inputMessage.value.trim()
  isSending.value = true

  try {
    // 构建请求元数据，包含选中的模型信息
    const metadata: any = {
      stream: true,
    }

    if (selectedModel.value) {
      metadata.model = selectedModel.value.model.name
      metadata.service = {
        id: selectedModel.value.service.id,
        name: selectedModel.value.service.name,
        apiUrl: selectedModel.value.service.apiUrl,
        apiKey: selectedModel.value.service.apiKey,
      }
    } else {
      metadata.model = 'mcp-default'
    }

    // 根据模式选择不同的 API 端点
    const apiEndpoint = usePlanMode.value === USE_PLAN_MODE.QUEST_ANSWERS
      ? PostChatSendApi
      : PostPlanCreateApi

    const selectedMCPServersObj: { [key: string]: boolean } = {}
    selectedMCPServers.value.map(item => {
      selectedMCPServersObj[item] = true
    })

    const response = await apiEndpoint({
      content,
      conversationId: currentConversationId.value,
      metadata,
      enabledMCPServers: enabledMCPServers.value.map(item => {
        return {...item}
      }).filter(item => selectedMCPServersObj[item.id]),
    })

    if (!response.conversationId) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    // 请求成功后清空输入框
    inputMessage.value = ''

  } catch (error) {
    console.error('[MCP Chat] Failed to send message:', error)
    antMessage.error('发送消息失败')
  } finally {
    isSending.value = false
  }
}

// 处理键盘事件
const handleKeyDown = (event: KeyboardEvent) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    sendMessage()
  }
}

// 开始新对话
const startNewConversation = () => {
  chatStore.createNewConversation()
  streamingMessage.value = null
  connectToMCPServer()
}

// 切换对话
const switchConversation = (conversationId: string) => {
  if (conversationId === currentConversationId.value) {
    return
  }

  chatStore.switchToConversation(conversationId)
  streamingMessage.value = null
  connectToMCPServer()
}

const deleteConversation = async (conversationId: string) => {
  try {
    if (!conversationId) {
      return
    }
    chatStore.deleteConversation(conversationId)
    console.log('[MCP Chat] Conversation deleted')
  } catch (error) {
    console.error('[MCP Chat] Failed to delete conversation:', error)
    antMessage.error('删除对话失败')
  }
}

// 清空当前对话
const clearCurrentConversation = async () => {
  if (!currentConversationId.value) {
    return
  }

  try {
    chatStore.clearCurrentConversation()
    console.log('[MCP Chat] Conversation cleared')
  } catch (error) {
    console.error('[MCP Chat] Failed to clear conversation:', error)
    antMessage.error('清空对话失败')
  }
}

// 处理网络搜索结果
const handleSearchResult = (result: SearchResult) => {
  // 将搜索结果插入到输入框中
  const searchInfo = `[网络搜索结果]\n标题: ${result.title}\n链接: ${result.url}\n摘要: ${result.snippet}\n\n`
  inputMessage.value = searchInfo + inputMessage.value
}

// 加载服务器统计信息
const loadServerStats = async () => {
  try {
    if (window.electronAPI && (window.electronAPI as any).invoke) {
      const stats = await (window.electronAPI as any).invoke('get-mcp-server-stats')
      serverStats.value = stats
    }
  } catch (error) {
    console.error('[MCP Chat] Failed to load server stats:', error)
  }
}


// 定期更新统计信息
const statsInterval: NodeJS.Timeout | null = null

onMounted(() => {
  // 初始化store，确保有默认对话
  chatStore.initializeStore()

  connectToMCPServer()
  loadServerStats()

  // 每5秒更新一次统计信息
  // statsInterval = setInterval(() => {
  //   if (showStats.value) {
  //     loadServerStats()
  //   }
  //   loadConversations()
  // }, 5000)
})

onUnmounted(() => {
  if (statsInterval) {
    clearInterval(statsInterval)
  }
})
</script>

<style scoped>
/* 自定义滚动条 */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* 统一顶部按钮样式 */
:deep(.ant-btn-sm) {
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

:deep(.ant-btn-sm .ant-btn-icon) {
  display: flex;
  align-items: center;
  justify-content: center;
}

:deep(.ant-btn-sm .anticon) {
  display: flex;
  align-items: center;
  justify-content: center;
  vertical-align: middle;
}
</style>
