# CURRENT_STATE.md

## YLAgents — Phase 0 Audit Output

Audit date: 2026-06-11
Base codebase: **Kelivo** (v1.1.16, Flutter LLM chat client)

---

## 1. Repository Overview

| Property | Value |
|---|---|
| Platform | Flutter (Dart 3.12+, Flutter 3.44+) |
| State Management | Provider (`ChangeNotifierProvider`) |
| Local Storage | Hive (conversations, messages, tool events) + SharedPreferences (settings, configs) |
| Package Name | `Kelivo` (imports use `package:Kelivo/...`) |
| Platforms | Android, iOS, macOS, Windows, Linux (no web target) |
| Localization | Flutter ARB (English, Chinese) — 4 files |
| Test Status | `flutter test` available |

---

## 2. Directory Architecture

```
lib/
├── main.dart                          # App entry, DI wiring, theme
├── core/
│   ├── models/                        # Data models (immutable with copyWith)
│   │   ├── assistant.dart             # Assistant model (agent-like)
│   │   ├── conversation.dart          # Hive Conversation (chat session)
│   │   ├── chat_message.dart          # Hive ChatMessage
│   │   ├── chat_item.dart             # Lightweight chat summary
│   │   ├── provider_group.dart        # Provider grouping
│   │   ├── backup.dart                # Backup config
│   │   └── ...                        # quick_phrase, world_book, etc.
│   ├── providers/                     # ChangeNotifier state holders
│   │   ├── assistant_provider.dart    # CRUD for assistants
│   │   ├── chat_provider.dart         # Chat list state (pinned, titles)
│   │   ├── mcp_provider.dart          # MCP server management & connections
│   │   ├── settings_provider.dart     # All user settings (huge)
│   │   ├── backup_provider.dart       # Backup/restore
│   │   ├── memory_provider.dart       # Assistant memory
│   │   ├── tag_provider.dart          # Assistant tags
│   │   └── ...                        # TTS, world_book, hotkey, etc.
│   └── services/                      # Business logic & integrations
│       ├── api/                       # LLM provider API clients
│       │   ├── chat_api_service.dart  # Central API routing
│       │   ├── providers/             # OpenAI, Gemini, Claude, etc.
│       │   └── builtin_tools.dart     # Built-in tool definitions
│       ├── chat/
│       │   ├── chat_service.dart      # Conversation & message CRUD (Hive)
│       │   └── prompt_transformer.dart
│       ├── mcp/
│       │   ├── mcp_tool_service.dart  # MCP tool execution routing
│       │   └── kelivo_fetch/          # Built-in @kelivo/fetch MCP server
│       ├── search/                    # Web search providers (Bing, Brave, etc.)
│       ├── backup/                    # Backup/restore/sync
│       ├── tts/                       # Text-to-speech
│       ├── network/                   # HTTP client, logging
│       └── storage/                   # Storage usage service
├── desktop/                           # Desktop-specific UI
│   ├── desktop_home_page.dart         # Desktop shell (nav rail + IndexedStack)
│   ├── desktop_nav_rail.dart          # Left rail: avatar, chat, search, translate, storage, settings
│   ├── desktop_sidebar.dart           # Wraps SideDrawer for desktop
│   ├── desktop_chat_page.dart         # Desktop chat entry
│   ├── desktop_settings_page.dart     # Settings page shell
│   ├── window_title_bar.dart          # Custom title bar (Windows)
│   ├── setting/                       # Individual settings panes
│   └── hotkeys/                       # Keyboard shortcuts
├── features/
│   ├── home/                          # Main chat page (shared mobile/desktop)
│   │   ├── controllers/               # HomePageController, ChatController, StreamController, etc.
│   │   ├── pages/                     # home_page.dart, layouts
│   │   ├── widgets/                   # Chat input bar, message list, side drawer
│   │   └── services/                  # Generation, message builder, OCR, translation, file upload
│   ├── assistant/                     # Assistant settings UI
│   ├── chat/                          # Chat widgets, message rendering
│   ├── settings/                      # Settings pages
│   ├── mcp/                           # MCP management UI
│   ├── backup/                        # Backup UI
│   ├── model/                         # Model selection UI
│   ├── provider/                      # Provider config UI
│   ├── search/                        # Search UI
│   ├── translate/                     # Translate page
│   └── world_book/                    # World book UI
├── shared/                            # Shared widgets, dialogs, animations
├── theme/                             # Theme factory, palettes
├── l10n/                              # Localization ARB files
└── utils/                             # Utility functions
```

---

## 3. State Management Architecture

**Pattern:** Provider (ChangeNotifier) + Event Bus (hotkeys, sidebar tabs, settings navigation)

### Provider Dependency Graph

```
main.dart (MultiProvider)
├── ChatProvider          — UI chat list state (pinned, titles)
├── UserProvider          — User profile (name, avatar)
├── SettingsProvider      — ALL settings (providers, models, theme, TTS, search, MCP timeout, etc.)
├── ChatService           — Hive CRUD for conversations & messages (central data layer)
├── McpToolService        — MCP tool routing
├── McpProvider           — MCP server configs, connections (SSE/HTTP/STDIO/InMemory)
├── ToolApprovalService   — MCP tool approval workflow
├── AskUserInteractionService — User interaction for tool approval
├── AssistantProvider     — Assistant CRUD (flat list, shared prefs persistence)
├── TagProvider           — Assistant tagging
├── TtsProvider           — Text-to-speech playback
├── UpdateProvider        — App update check
├── QuickPhraseProvider   — Quick phrases
├── InstructionInjectionProvider — Instruction injection
├── InstructionInjectionGroupProvider
├── WorldBookProvider     — World book entries
├── MemoryProvider        — Assistant memory
├── BackupReminderProvider
├── HotkeyProvider        — Desktop keyboard shortcuts
├── BackupProvider        — WebDAV backup
└── S3BackupProvider      — S3 backup
```

### Key Observations

1. **No router/navigation system** — uses `IndexedStack` for tabs on desktop, scaffold drawer for mobile
2. **SettingsProvider is a god class** — handles ALL settings including providers, models, theme, proxy, fonts, TTS, search, and more
3. **ChatService** is the actual data layer — wraps Hive for conversations/messages/tool events
4. **Streaming** handled via custom StreamController within `features/home/controllers/`
5. **Event buses** for cross-component communication (hotkeys, sidebar tabs, settings navigation)

---

## 4. Data Models

### Assistant (the current "agent" equivalent)
- `id`, `name`, `avatar`, `useAssistantAvatar`, `useAssistantName`
- `chatModelProvider`, `chatModelId`, `temperature`, `topP`
- `contextMessageSize`, `limitContextMessages`, `streamOutput`
- `thinkingBudget`, `maxTokens`, `systemPrompt`, `messageTemplate`
- `searchEnabled`, `mcpServerIds`, `localToolIds`
- `background`, `customHeaders`, `customBody`
- `enableMemory`, `enableRecentChatsReference`, `recentChatsSummaryMessageCount`
- `presetMessages`, `regexRules`
- **Persistence:** JSON string in SharedPreferences (`assistants_v1` key)

### Conversation (Hive typeId: 1)
- `id`, `title`, `createdAt`, `updatedAt`, `messageIds`, `isPinned`
- `mcpServerIds`, `assistantId`
- `truncateIndex`, `versionSelections`, `summary`, `lastSummarizedMessageCount`, `chatSuggestions`

### ChatMessage (Hive typeId: 0)
- `id`, `role`, `content`, `timestamp`, `conversationId`
- `modelId`, `providerId`, `totalTokens`, `isStreaming`
- `reasoningText`, `reasoningStartAt`, `reasoningFinishedAt`
- `translation`, `reasoningSegmentsJson`, `groupId`, `version`
- `promptTokens`, `completionTokens`, `cachedTokens`, `durationMs`

---

## 5. MCP Architecture

**KEEP / ENHANCE** — This is one of the strongest parts of Kelivo.

### McpProvider
- Manages MCP server configs (list loaded from SharedPreferences `mcp_servers_v1`)
- Connection management: SSE, HTTP (Streamable), STDIO (desktop-only), InMemory (built-in @kelivo/fetch)
- Heartbeat health checks with auto-reconnect (exponential backoff)
- Tool discovery via `listTools()`, enabled/disabled per tool, `needsApproval` flag
- Tool argument normalization via JSON schema introspection
- Export/import from JSON format

### McpToolService
- Routes tool calls to appropriate MCP server
- Coordinates with ToolApprovalService for approval workflows

### Built-in MCP Servers
- `@kelivo/fetch` — in-memory fetch tool, always available by default

---

## 6. Chat / Generation Flow

```
User Input → ChatInputBar
  → HomePageController.sendMessage()
    → HomeViewModel.sendMessage()
      → MessageGenerationService.generateFromStream()
        → ChatApiService.sendChatRequest() ═══> Provider API (OpenAI/Gemini/Claude...)
          ← Streaming response via StreamController
            ← ChatController manages messages
              ← ChatMessageWidget renders output
```

### Services involved:
- **MessageBuilderService** — builds API request payloads
- **MessageGenerationService** — orchestrates generation with tool support
- **GenerationController** — manages generation lifecycle
- **StreamController** (custom) — handles streaming content, reasoning, tool parts
- **ChatApiService** — routes to correct provider API, handles auth, headers, model overrides

### Provider Integrations:
- OpenAI Chat Completions
- OpenAI Responses API
- OpenAI Images API
- Google Gemini (via SDK and HTTP)
- Google Vertex AI
- Claude Official API
- Plus 13+ built-in provider templates (SiliconFlow, DeepSeek, Aliyun, etc.)

---

## 7. Storage Architecture

| Data | Storage | Key |
|---|---|---|
| Conversations | Hive Box | `conversations` |
| Messages | Hive Box | `messages` |
| Tool Events | Hive Box | `tool_events_v1` |
| Assistants | SharedPreferences | `assistants_v1` |
| MCP Servers | SharedPreferences | `mcp_servers_v1` |
| Settings | SharedPreferences | Various keys |
| Provider Configs | SharedPreferences | `provider_configs_v1` |
| User Profile | SharedPreferences | Various keys |
| Upload Files | Filesystem | `AppDirectories.getUploadDirectory()` |
| Avatars | Filesystem | `AppDirectories.getAvatarsDirectory()` |

**Key Finding:** Assistants stored as JSON string in SharedPreferences — not suitable for complex agent data at scale. Hive used only for conversations/messages/tool events.

---

## 8. Navigation Structure

### Desktop (`DesktopHomePage`)
```
DesktopNavRail (left rail, 64px)
  ├── [0] Chat (DesktopChatPage → reuses HomePage)
  ├── [1] Translate (DesktopTranslatePage)
  ├── [2] Storage (StorageSpacePage)
  └── [3] Settings (DesktopSettingsPage → panes)
```

### Mobile (`HomePage`)
```
Scaffold with Drawer
  └── SideDrawer
        ├── Assistants list
        ├── Conversations list
        └── Global search
```

### Assistant Settings (`AssistantSettingsPage`)
Multiple tabs: Basic, Prompt, Tools (Local/MCP), Memory, Quick Phrases, Regex, Custom Request

---

## 9. Audit Classification (KEEP / ENHANCE / MIGRATE / REPLACE / REMOVE)

### KEEP (fully reuse as-is)

| Component | Reasoning |
|---|---|
| **Provider integrations** (all API clients) | Mature, battle-tested, support multiple providers |
| **Streaming infrastructure** | Custom StreamController works perfectly |
| **MCP implementation** (McpProvider, McpToolService, MCP client) | Excellent, supports SSE/HTTP/STDIO/InMemory |
| **Chat rendering** (ChatMessageWidget, Markdown) | Sophisticated with versioning, reasoning, tool UI |
| **Attachment system** | Images, files, OCR, inline sanitization |
| **Voice/TTS** | Network TTS + platform TTS |
| **Search providers** | 15+ web search integrations |
| **Backup/restore** | WebDAV, S3, local file |
| **Theme system** | Dynamic color, palettes, font selection |
| **Localization infrastructure** | 4 ARB files, well-organized |

### ENHANCE (extend with workspace/agent awareness)

| Component | Enhancement Needed |
|---|---|
| **Assistant model** → **Agent model** | Add identity, soul, role, goals, genome fields |
| **AssistantProvider** → **AgentProvider** | Workspace-aware CRUD, agent factory, genome editing |
| **ChatService** → **Workspace-aware** | Conversations belong to workspaces & agent teams |
| **McpProvider** → **MCP Profiles** | Per-workspace, per-agent MCP profiles & templates |
| **SettingsProvider** | Needs splitting — too monolithic |
| **SideDrawer** → **Workspace nav** | Needs workspace selector, agent list, task list |
| **DesktopNavRail** | Needs workspace-first nav (agents, tasks, knowledge) |
| **Chat API routing** | Needs multi-agent orchestration awareness |

### MIGRATE (move with adaptation)

| Component | Migration Target |
|---|---|
| **Assistant storage** (SharedPrefs JSON) | Hive or SQLite for agent schema |
| **SettingsProvider** monolithic state | Split into domain-specific providers |
| **HomePageController** logic | Extract workspace-level orchestration |

### REPLACE (build new)

| Component | Reason |
|---|---|
| **Workspace system** | Does not exist — brand new concept |
| **Agent Factory (UI)** | Does not exist — visual agent builder |
| **Multi-agent orchestration** | Does not exist — lead/manager/worker hierarchy |
| **Bot channels** | Does not exist — Telegram, Discord, Slack, Email |
| **Skills system** | Does not exist — portable capabilities |
| **Task system** | Does not exist — task management |
| **Knowledge management** | Basic memory exists, no structured knowledge |
| **Sync infrastructure** | Does not exist — minimal backup only |

### REMOVE (no longer needed)

| Component | Reason |
|---|---|
| None identified yet | All existing Kelivo features remain useful |

---

## 10. Critical Architecture Decisions for YLAgents

1. **Workspace is the primary unit** — not chat. Refactor navigation to show workspace-first.
2. **Agent = evolved Assistant** — Assistant model provides 70%+ of what an agent needs. Extend, don't rewrite.
3. **Chat becomes a workspace feature** — Conversations belong to workspace-agent pairs.
4. **MCP is the tool layer** — Already excellent. Add profiles/templates/marketplace on top.
5. **Provider integrations stay untouched** — They work. Don't touch them.
6. **Storage split**: Assistants need better storage (Hive or SQLite) for complex agent genome.
7. **SettingsProvider must be split** — It's too large for workspace/agent/multi-agent configs.
8. **No cloud dependency** — Everything runs locally. Server is optional infrastructure.

---

*End of CURRENT_STATE.md — Phase 0 Audit Complete*