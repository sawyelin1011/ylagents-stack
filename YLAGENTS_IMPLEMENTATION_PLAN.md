# YLAgents Implementation Plan

> Built on Kelivo v1.1.16+60
> Based on `CURRENT_STATE.md` audit findings

---

## Golden Rule

Every change classified as:
- **KEEP** — Preserve as-is, no modifications
- **ENHANCE** — Extend existing code minimally
- **MIGRATE** — Data/UX transformation with backward compat
- **REPLACE** — Build new, replace old
- **REMOVE** — Delete (with justification)

Priority: **Critical > High > Medium > Low**
Effort: **Small < 1 day, Medium 1-3 days, Large 3-7 days**

---

## Phase 0: Foundation & Architecture (Current)

> Status: **COMPLETE** — CURRENT_STATE.md delivered
> Output: Full architectural understanding, storage audit, model audit, classification

### Tasks

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 0.1 | Audit providers | — | Critical | Small | All `lib/core/providers/*` |
| 0.2 | Audit storage | — | Critical | Small | `ChatService`, `MemoryStore`, `DataSync` |
| 0.3 | Audit models | — | Critical | Small | `lib/core/models/*` |
| 0.4 | Audit navigation | — | Critical | Small | `main.dart`, `DesktopHomePage`, `HomePage` |
| 0.5 | Audit MCP system | — | Critical | Small | `McpProvider`, `McpToolService` |
| 0.6 | Document CURRENT_STATE.md | — | Critical | Medium | — |
| 0.7 | Create implementation plan | — | Critical | Medium | — |

**Acceptance**: Full architectural understanding achieved. ✅

---

## Phase 1: Foundation (Preserve & Migrate)

**Objective**: Preserve all existing Kelivo functionality. Prepare architecture foundation for agent system.

### 1.1 Introduce Workspace Model

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 1.1.1 | Create `Workspace` model (id, name, createdAt, settings) | REPLACE (new) | Critical | Small | `lib/core/models/workspace.dart` |
| 1.1.2 | Create `WorkspaceProvider` (CRUD, current workspace) | REPLACE (new) | Critical | Small | `lib/core/providers/workspace_provider.dart` |
| 1.1.3 | Register WorkspaceProvider in MultiProvider | ENHANCE | Critical | Small | `main.dart` |
| 1.1.4 | Seed default workspace on first launch | ENHANCE | Critical | Small | `WorkspaceProvider` |

### 1.2 Introduce Agent Model (Genome)

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 1.2.1 | Create `AgentGenome` model extending `Assistant` | ENHANCE | Critical | Medium | `lib/core/models/agent.dart` |
| 1.2.2 | Add genome fields: soul, role, goals, policies, schedules, channels | ENHANCE | Critical | Medium | `lib/core/models/agent_genome.dart` |
| 1.2.3 | Create backward-compatible migration from `Assistant` to `Agent` | MIGRATE | Critical | Large | `lib/core/services/agent_migration_service.dart` |
| 1.2.4 | Add `workspaceId` to Agent model | ENHANCE | Critical | Small | `agent.dart` |

### 1.3 Add workspaceId to Conversation

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 1.3.1 | Add HiveField for `workspaceId` to Conversation model | ENHANCE | Critical | Small | `conversation.dart`, run `build_runner` |
| 1.3.2 | Add `workspaceId` to Conversation.fromJson | ENHANCE | Critical | Small | `conversation.dart` |
| 1.3.3 | Update ChatService to filter by workspace | ENHANCE | High | Medium | `chat_service.dart` |

### 1.4 Workspace-First Provider Wrapping

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 1.4.1 | Wrap AssistantProvider to filter by workspace | ENHANCE | High | Medium | `assistant_provider.dart` |
| 1.4.2 | Create workspace-scoped settings getters in SettingsProvider | ENHANCE | Medium | Medium | `settings_provider.dart` |
| 1.4.3 | Add workspace-scoped memory storage | ENHANCE | Medium | Medium | `memory_provider.dart`, `memory_store.dart` |

---

## Phase 2: Assistant → Agent Migration

**Objective**: Existing assistants migrate safely to agent system.

### 2.1 Data Migration

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 2.1.1 | Write one-time migration script: `Assistant` JSON -> `Agent` JSON | MIGRATE | Critical | Medium | `agent_migration_service.dart` |
| 2.1.2 | Preserve all existing Assistant fields (systemPrompt, model config, MCP bindings, etc.) | MIGRATE | Critical | Medium | `agent.dart` fromJson/toJson |
| 2.1.3 | Add migration guard: detect un-migrated data on load | MIGRATE | Critical | Small | `assistant_provider.dart` |
| 2.1.4 | Add rollback/backup before migration | ENHANCE | High | Small | `agent_migration_service.dart` |

### 2.2 Agent Profiles

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 2.2.1 | Create AgentProfile model (identity, avatar, name, description) | REPLACE (new) | High | Small | `lib/core/models/agent_profile.dart` |
| 2.2.2 | Link profile to Agent genome | ENHANCE | High | Small | `agent.dart` |
| 2.2.3 | Add profile editing UI tabs | REPLACE | High | Medium | `lib/features/agent/` |

### 2.3 Agent Memory Enhancement

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 2.3.1 | Extend AssistantMemory with memory level field (working, session, long-term, knowledge) | ENHANCE | High | Medium | `assistant_memory.dart` |
| 2.3.2 | Add workspace-scoped MemoryProvider | ENHANCE | High | Medium | `memory_provider.dart` |
| 2.3.3 | Create MemoryStore v2 migration | MIGRATE | High | Small | `memory_store.dart` |
| 2.3.4 | Wire memory into message generation pipeline | ENHANCE | High | Medium | `message_generation_service.dart` |

---

## Phase 3: Agent Factory

**Objective**: Users create agents without code via visual builder.

### 3.1 Visual Builder

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 3.1.1 | Create AgentFactory page (workspace-scoped) | REPLACE | Critical | Medium | `lib/features/agent_factory/pages/` |
| 3.1.2 | Identity configuration section (name, avatar, description) | REPLACE | Critical | Small | `agent_factory/` |
| 3.1.3 | Role configuration section (type: Lead/Manager/Worker) | REPLACE | Critical | Small | `agent_factory/` |
| 3.1.4 | Soul/personality configuration section (system prompt builder) | REPLACE | High | Medium | `agent_factory/` |
| 3.1.5 | Goals configuration section | REPLACE | High | Small | `agent_factory/` |
| 3.1.6 | Knowledge attachment section (link world books, files, memories) | REPLACE | High | Medium | `agent_factory/` |
| 3.1.7 | Tool selection section (choose MCP tools + local tools) | REPLACE | High | Medium | `agent_factory/` |
| 3.1.8 | MCP profile selector | ENHANCE | High | Small | `MCP profiles` |

### 3.2 Templates

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 3.2.1 | Create AgentTemplate model | REPLACE | Medium | Small | `lib/core/models/agent_template.dart` |
| 3.2.2 | Ship built-in templates (General Assistant, Code Helper, Writer, Researcher) | REPLACE | Medium | Small | `lib/core/services/agent_templates.dart` |
| 3.2.3 | Template browser UI | REPLACE | Medium | Medium | `agent_factory/` |

### 3.3 Testing Sandbox

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 3.3.1 | Create agent testing sandbox (instant preview conversation) | REPLACE | High | Medium | `lib/features/agent_factory/` |
| 3.3.2 | Wire sandbox to existing chat infrastructure | ENHANCE | High | Medium | Reuse `ChatService` |

---

## Phase 4: Multi-Agent Orchestration

**Objective**: Agent teams operate successfully.

### 4.1 Agent Hierarchy

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 4.1.1 | Create AgentTeam model (leadAgentId, memberAgentIds, workspaceId) | REPLACE | Critical | Medium | `lib/core/models/agent_team.dart` |
| 4.1.2 | Create TeamProvider | REPLACE | Critical | Medium | `lib/core/providers/team_provider.dart` |
| 4.1.3 | Add team creation/manage UI | REPLACE | Critical | Medium | `lib/features/team/` |

### 4.2 Task System

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 4.2.1 | Create Task model (id, description, assignedAgentId, status, result) | REPLACE | Critical | Medium | `lib/core/models/task.dart` |
| 4.2.2 | Create TaskProvider | REPLACE | Critical | Medium | `lib/core/providers/task_provider.dart` |
| 4.2.3 | Create TaskQueue (state machine for task lifecycle) | REPLACE | Critical | Large | `lib/core/services/task_queue.dart` |
| 4.2.4 | Task management UI | REPLACE | High | Medium | `lib/features/tasks/` |

### 4.3 Delegation Engine

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 4.3.1 | Lead Agent logic: plan -> delegate -> review | REPLACE | Critical | Large | `lib/core/services/orchestration/lead_agent_service.dart` |
| 4.3.2 | Manager Agent logic: team coordination, supervision | REPLACE | Critical | Large | `lib/core/services/orchestration/manager_agent_service.dart` |
| 4.3.3 | Worker Agent logic: specialized execution | REPLACE | Critical | Large | `lib/core/services/orchestration/worker_agent_service.dart` |
| 4.3.4 | Communication channel (Lead -> Manager -> Worker, no cross-talk) | REPLACE | Critical | Medium | `lib/core/services/orchestration/agent_communication.dart` |

### 4.4 Execution Tracing

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 4.4.1 | Create ExecutionTrace model (taskId, agentId, action, timestamp) | REPLACE | High | Medium | `lib/core/models/execution_trace.dart` |
| 4.4.2 | Create TraceProvider | REPLACE | High | Medium | `lib/core/providers/trace_provider.dart` |
| 4.4.3 | Trace visualization UI | REPLACE | Medium | Large | `lib/features/traces/` |
| 4.4.4 | Approval checkpoint system (permission before tool execution) | ENHANCE | High | Medium | `tool_approval_service.dart` |

---

## Phase 5: Bot Channels

**Objective**: External communication operational.

### 5.1 Channel Infrastructure

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 5.1.1 | Create AgentChannel model (type, config, agentId) | REPLACE | Critical | Medium | `lib/core/models/agent_channel.dart` |
| 5.1.2 | Create ChannelProvider | REPLACE | Critical | Medium | `lib/core/providers/channel_provider.dart` |
| 5.1.3 | Create ChannelAdapter interface | REPLACE | Critical | Medium | `lib/core/services/channels/channel_adapter.dart` |

### 5.2 Channel Implementations

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 5.2.1 | Telegram bot adapter | REPLACE | Critical | Large | `lib/core/services/channels/telegram_adapter.dart` |
| 5.2.2 | Discord bot adapter | REPLACE | High | Large | `lib/core/services/channels/discord_adapter.dart` |
| 5.2.3 | Slack bot adapter | REPLACE | High | Large | `lib/core/services/channels/slack_adapter.dart` |
| 5.2.4 | Email bot adapter | REPLACE | Medium | Medium | `lib/core/services/channels/email_adapter.dart` |
| 5.2.5 | REST webhook adapter | REPLACE | Medium | Medium | `lib/core/services/channels/rest_adapter.dart` |
| 5.2.6 | Web widget adapter | REPLACE | Medium | Large | `lib/core/services/channels/web_widget_adapter.dart` |

### 5.3 Channel Configuration UI

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 5.3.1 | Channel management page | REPLACE | Critical | Medium | `lib/features/channels/` |
| 5.3.2 | Per-channel settings sheets | REPLACE | High | Medium | `lib/features/channels/` |
| 5.3.3 | Channel-to-agent binding UI | REPLACE | High | Small | `lib/features/channels/` |

---

## Phase 6: Workspace-First UX

**Objective**: Workspace-first navigation complete.

### 6.1 Workspace Navigation

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 6.1.1 | Redesign DesktopHomePage nav rail: Agents, Tasks, Knowledge, Channels, MCP, Skills, Chats tabs | REPLACE | Critical | Large | `desktop/desktop_home_page.dart` |
| 6.1.2 | Redesign mobile HomePage drawer to workspace-first | REPLACE | Critical | Large | `features/home/pages/home_mobile_layout.dart` |
| 6.1.3 | Add Workspace selector in top bar | REPLACE | Critical | Medium | `desktop/desktop_home_page.dart` |
| 6.1.4 | Workspace settings page | REPLACE | High | Medium | `lib/features/workspace/` |

### 6.2 Knowledge Base UI

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 6.2.1 | Workspace knowledge management page | REPLACE | Critical | Large | `lib/features/knowledge/` |
| 6.2.2 | File attachment to knowledge base | REPLACE | High | Medium | `lib/features/knowledge/` |
| 6.2.3 | Knowledge binding to agents | ENHANCE | High | Medium | link WorldBook + knowledge |

### 6.3 Dashboard

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 6.3.1 | Workspace dashboard (agent status, task summary, recent activity) | REPLACE | High | Large | `lib/features/dashboard/` |
| 6.3.2 | Agent health/status indicators | REPLACE | Medium | Medium | `lib/shared/widgets/agent_status.dart` |

---

## Phase 7: Skills Ecosystem

**Objective**: Reusable skills operational.

### 7.1 Skill Packaging

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 7.1.1 | Create Skill model (id, name, prompts, workflows, assets, config) | REPLACE | Critical | Medium | `lib/core/models/skill.dart` |
| 7.1.2 | Create SkillProvider | REPLACE | Critical | Medium | `lib/core/providers/skill_provider.dart` |
| 7.1.3 | Skill import/export (zip + manifest) | REPLACE | High | Medium | `lib/core/services/skill_import_export.dart` |

### 7.2 Skill Installation

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 7.2.1 | Install from marketplace (URL) | REPLACE | High | Medium | `skill_provider.dart` |
| 7.2.2 | Install from git repository | REPLACE | High | Medium | `skill_provider.dart` |
| 7.2.3 | Install from local file | REPLACE | High | Small | `skill_provider.dart` |
| 7.2.4 | Skill management UI | REPLACE | High | Medium | `lib/features/skills/` |

### 7.3 Marketplace Foundation

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 7.3.1 | Skill marketplace browser UI | REPLACE | Medium | Medium | `lib/features/marketplace/` |
| 7.3.2 | Simple skill listing (local or JSON-based to start) | REPLACE | Medium | Medium | `marketplace_service.dart` |

---

## Phase 8: Sync Infrastructure

**Objective**: Multi-device synchronization operational.

### 8.1 Authentication

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 8.1.1 | Create AuthProvider (JWT-based device registration) | REPLACE | Critical | Medium | `lib/core/providers/auth_provider.dart` |
| 8.1.2 | Device registration flow | REPLACE | Critical | Medium | `lib/features/auth/` |
| 8.1.3 | Token management (jose package already in deps) | ENHANCE | High | Small | Reuse existing `jose` dependency |

### 8.2 Sync Engine

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 8.2.1 | DataSyncProvider (incremental sync, conflict resolution) | REPLACE | Critical | Large | `lib/core/providers/sync_provider.dart` |
| 8.2.2 | Workspace-level sync scoping | ENHANCE | Critical | Medium | `sync_provider.dart` |
| 8.2.3 | Sync status UI | REPLACE | High | Medium | `lib/features/sync/` |

### 8.3 Relay & Push

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 8.3.1 | Minimal relay server (can reuse existing Kelivo server) | ENHANCE | High | Medium | Server-side |
| 8.3.2 | Push notification forwarding | ENHANCE | High | Medium | `notification_service.dart` |
| 8.3.3 | Backup integration (WebDAV/S3 as sync backends) | ENHANCE | High | Small | `backup_provider.dart` |

---

## Phase 9: Runtime Host

**Objective**: Runtime can execute independently from user devices.

### 9.1 Background Runtime

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 9.1.1 | Create RuntimeHostService (background agent execution) | REPLACE | Critical | Large | `lib/core/services/runtime_host_service.dart` |
| 9.1.2 | Schedule execution engine | REPLACE | Critical | Large | `lib/core/services/scheduler_service.dart` |
| 9.1.3 | Task persistence across restarts | ENHANCE | Critical | Medium | `task_queue.dart` + Hive |

### 9.2 Deployment Targets

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 9.2.1 | Docker packaging support | REPLACE | High | Medium | Root + `Dockerfile` |
| 9.2.2 | Environment variables for headless config | REPLACE | High | Small | `runtime_host_service.dart` |
| 9.2.3 | Health check API | REPLACE | High | Medium | REST endpoint for runtime |

### 9.3 Monitoring

| # | Task | Classification | Priority | Effort | Files |
|---|---|---|---|---|---|
| 9.3.1 | Runtime status dashboard | REPLACE | Medium | Medium | `lib/features/runtime/` |
| 9.3.2 | Agent execution logs | REPLACE | Medium | Medium | `lib/features/runtime/` |
| 9.3.3 | Bot uptime monitoring | REPLACE | Low | Medium | `lib/features/runtime/` |

---

## Development Rules (Enforcement)

### Never Rebuild
1. Existing provider integrations (OpenAI, Claude, Gemini, Vertex)
2. MCP client infrastructure (McpProvider, McpToolService)
3. Chat storage (ChatService, Hive boxes)
4. Backup/restore systems (WebDAV, S3)
5. Markdown/math rendering
6. Search providers
7. Theme system
8. TTS system

### Always Extend
1. Assistant model -> Agent genome (add fields, never remove)
2. Memory system (add levels, never remove existing)
3. Settings (add workspace prefix, never remove global keys)
4. Conversation (add workspaceId, never remove existing fields)
5. MCP (add profiles, never remove server-level management)

### Architecture Validation Checklist
Ask for every feature:
- [ ] Can this become Workspace Aware?
- [ ] Can this become Agent Aware?
- [ ] Can this become Multi-Agent Aware?
- If yes -> ENHANCE. If no -> REPLACE.

---

## Dependency Graph

```
Phase 1 (Foundation)
├─> Phase 2 (Agent Migration)
│    ├─> Phase 3 (Agent Factory)
│    │    └─> Phase 4 (Multi-Agent)
│    │         └─> Phase 5 (Bot Channels)
│    └─> Phase 6 (Workspace UX)
│         ├─> Phase 7 (Skills)
│         └─> Phase 8 (Sync)
│              └─> Phase 9 (Runtime Host)
```

- Phase 1 MUST complete before Phase 2
- Phase 2 MUST complete before Phase 3
- Phase 3 MUST complete before Phase 4
- Phase 2 and Phase 6 can partially overlap (workspace UX depends on workspace model from Phase 1)
- Phase 5 depends on Phase 4 (agents exist) and Phase 1 (workspace model)
- Phase 7 depends on Phase 6 (workspace UX) and Phase 2 (agent system)
- Phase 8 depends on Phase 1 (workspace model)
- Phase 9 depends on Phase 4 (multi-agent), Phase 5 (channels), Phase 8 (sync)

---

## Success Criteria Summary

| Phase | Criteria | Verification |
|---|---|---|
| 1 | Kelivo functionality preserved + workspace model introduced | All existing tests pass; workspace CRUD works |
| 2 | Agent architecture introduced; existing assistants migrate | Migration produces identical behavior; no data loss |
| 3 | Agent Factory operational | Create agents without code; wire to chat |
| 4 | Multi-agent orchestration operational | Lead+Manager+Worker team completes task |
| 5 | Bot channels operational | Telegram/Discord/Slack messages relayed to agent |
| 6 | Workspace-first UX operational | Navigation shows workspace-first layout |
| 7 | Skills ecosystem operational | Install and run a packaged skill |
| 8 | Sync infrastructure operational | Two devices sync via relay |
| 9 | Runtime host operational | Agent executes on schedule without user device |

---

## Risk Register

| Risk | Phase | Impact | Mitigation |
|---|---|---|---|
| Hive schema migration breaks existing data | 1 | Critical | Backup before migration; extensive testing |
| SharedPreferences data model migration | 2 | High | Rollback-eligible migration with version tracking |
| Workspace-first UX may frustrate existing users | 6 | Medium | Gradual reveal; keep "classic mode" fallback |
| MCP profiles may break existing bindings | 3 | Medium | Backward-compatible default profile |
| Multi-agent orchestration LLM costs | 4 | Medium | Configurable agent depth; local model support |
| Bot channels require server infrastructure | 5 | High | Local gateway mode for development |
| Sync conflict resolution is complex | 8 | High | Last-write-wins initially; CRDT later |
| Runtime host on Raspberry Pi may have performance issues | 9 | Medium | Recommend minimum specs; lightweight mode |

---

## End of Implementation Plan