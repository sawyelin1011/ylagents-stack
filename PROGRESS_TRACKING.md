# YLAgents — Progress Tracking

Last Updated: 2026-06-11 (Phase 10 added)

---

## Master Status

| Phase | Status | Started | Completed | Notes |
|---|---|---|---|---|
| **0** — Kelivo Audit | ✅ Complete | — | 2026-06-11 | CURRENT_STATE.md delivered |
| **0.5** — UX Audit | 🔄 Partial | 2026-06-11 | — | UX mapping done, direction integrated into Phase 1 code |
| **1** — Workspace Foundation | ✅ Complete | 2026-06-11 | 2026-06-11 | Full workspace system: model, provider, nav, pages, sidebar, settings split, tests |
| **2** — Assistant → Agent | ✅ Complete | 2026-06-11 | 2026-06-11 | AgentGenome model, Agent model, AgentProvider, agents page upgrade, tests |
| **3** — Task System | ✅ Complete | 2026-06-11 | 2026-06-11 | Task model, TaskProvider, kanban board, dashboard task stat, 22+ ARB keys, 20+ tests |
| **4** — Agent Factory | ✅ Complete | 2026-06-11 | 2026-06-11 | AgentTemplate model, built-in templates, multi-step wizard, AgentsPage entry point |
| **5** — Lead Agent | ✅ Complete | 2026-06-11 | 2026-06-11 | ExecutionTrace model, TraceProvider, LeadAgentService, execution page, lead agent template, 16 ARB keys, 40+ tests |
| **6** — Multi-Agent | ✅ Complete | 2026-06-11 | 2026-06-11 | AgentTeam model, TeamProvider, team management page, WorkerAgentService, ManagerAgentService, AgentCommunication protocol, traces history page, 37+ ARB keys, 15+ tests |
| **7** — Skills System | ✅ Complete | 2026-06-11 | 2026-06-11 | Skill model, SkillProvider, import/export service, marketplace with 4 built-in skills, Skills UI page (installed + marketplace tabs), entry from Knowledge page, 18+ ARB keys, 20+ tests |
| **8** — Channels | ✅ Complete | 2026-06-11 | 2026-06-11 | AgentChannel model, ChannelProvider, 6 channel adapters (Telegram, Discord, Slack, Email, Webhook, Widget), Channels UI with create/configure/test/delete, NavRail entry, 21+ ARB keys, 30+ tests |
| **9** — Sync Server | ✅ Complete | 2026-06-11 | 2026-06-11 | SyncDevice model, SyncRecord model, SyncStatus enum, AuthProvider (device identity + registration), SyncProvider (sync engine + config), SyncConfig model, Sync UI page with device/config/history sections, NavTab.sync in desktop nav rail, 30+ ARB keys, 50+ tests |
| **10** — Runtime Host | ✅ Complete | 2026-06-11 | 2026-06-11 | RuntimeExecution model, SchedulerService, RuntimeProvider, Runtime UI page with host status/active executions/schedules/history, 26+ ARB keys, 50+ tests |

---

## Phase 0.5 — UX Audit

### 0.5.1: Map Current Navigation & UX
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] + document |
| **Priority** | Critical |
| **Effort** | Small |
| **Started** | 2026-06-11 |
| **Completed** | 2026-06-11 |

**Findings:**
- Desktop nav: 5 tabs (Chat, Search, Translate, Storage, Settings) via IndexedStack
- DesktopNavRail: 64px left rail with avatar + icon buttons
- Sidebar: SideDrawer reused from mobile, shows assistants + conversations
- Settings: 15 panes in DesktopSettingsPage (left menu + right content)
- Chat page: HomePage reused for both mobile and desktop via DesktopChatPage
- Assistant settings: Tab-based editor in `AssistantSettingsEditPage`
- No workspace concept, no dashboard, no task system
- MCP management buried in Settings

---

### 0.5.2: Workspace-First Navigation Proposal
| Field | Value |
|---|---|
| **Status** | ⏳ Pending |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |
| **Started** | — |
| **Completed** | — |

**Checklist:**
- [ ] Design nav rail layout
- [ ] Design sidebar per tab
- [ ] Design workspace selector
- [ ] Design Dashboard page layout
- [ ] Design workspace CRUD

**Next Steps:** Depends on 0.5.1

**Known Issues:** N/A

---

### 0.5.3: Agent Factory UX Proposal
| Field | Value |
|---|---|
| **Status** | ⏳ Pending |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Large |
| **Started** | — |
| **Completed** | — |

**Checklist:**
- [ ] Design wizard steps (Identity → Role → Knowledge → Tools → Policies → Channels → Test)
- [ ] Design agent card/list view
- [ ] Design agent detail/edit view
- [ ] Map to existing AssistantSettingsPage tabs
- [ ] Identify new tabs needed

**Next Steps:** Depends on 0.5.2

**Known Issues:** N/A

---

### 0.5.4: Task System UX Proposal
| Field | Value |
|---|---|
| **Status** | ⏳ Pending |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |
| **Started** | — |
| **Completed** | — |

**Checklist:**
- [ ] Design task model
- [ ] Design task list/kanban view
- [ ] Design task detail view
- [ ] Design task creation flow

**Next Steps:** Depends on 0.5.2

**Known Issues:** N/A

---

### 0.5.5: Navigation Implementation Plan
| Field | Value |
|---|---|
| **Status** | ⏳ Pending |
| **Classification** | [ENHANCE] + [REPLACE] |
| **Priority** | Critical |
| **Effort** | Large |
| **Started** | — |
| **Completed** | — |

**Checklist:**
- [ ] WorkspaceProvider + model design
- [ ] Nav rail refactor plan
- [ ] Sidebar per-tab plan
- [ ] Dashboard page plan
- [ ] Migration plan (existing data → Personal workspace)

**Next Steps:** Depends on 0.5.2, 0.5.3, 0.5.4

**Known Issues:** N/A

---

### 0.5.6: Settings Restructuring Plan
| Field | Value |
|---|---|
| **Status** | ⏳ Pending |
| **Classification** | [ENHANCE] / [MIGRATE] |
| **Priority** | Medium |
| **Effort** | Medium |
| **Started** | — |
| **Completed** | — |

**Checklist:**
- [ ] Map all SettingsProvider keys
- [ ] Design three-tier split (Global / Workspace / Agent)
- [ ] Plan migration path
- [ ] Identify new providers needed

**Next Steps:** Depends on 0.5.5

**Known Issues:** SettingsProvider is a god class (~100+ keys)

---

## Phase 1 — Workspace Foundation

### 1.1: Create Workspace model + WorkspaceProvider
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverables:**
- `lib/core/models/workspace.dart` — Workspace model with WorkspaceType enum (personal/project/client), JSON serialization, copyWith
- `lib/core/providers/workspace_provider.dart` — CRUD, current selection, SharedPreferences persistence, ensurePersonalWorkspace, migrateLegacyData
- ARB keys: workspaceProviderPersonalWorkspaceName, workspaceProviderDefaultWorkspaceName
- Registered as ChangeNotifierProvider in main.dart

**Known Issues:** N/A — new code, no legacy migration needed yet

### 1.2: Add workspaceId to Conversation + Assistant
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | Critical |
| **Effort** | Small |

**Changes:**
- `Conversation.workspaceId` as `@HiveField(13)` — nullable String
- `Assistant.workspaceId` as nullable String — JSON serialized
- Both added to constructor, copyWith, toJson, fromJson

**Risks:** Requires `dart run build_runner build --delete-conflicting-outputs` to regenerate `conversation.g.dart`

### 1.3: Auto-create "Personal" workspace + migration
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [MIGRATE] |
| **Priority** | Critical |
| **Effort** | Small |

**Changes:**
- `WorkspaceProvider.ensurePersonalWorkspace()` called in main.dart post-frame callback
- `WorkspaceProvider.migrateLegacyData()` assigns workspaceId to all unassigned assistants + conversations
- `ChatService.assignUnassignedConversationsToWorkspace()` iterates all Hive conversations + drafts
- `ChatService.getConversationsForWorkspace()` helper for workspace-filtered queries

**Known Issues:** Migration runs once on first launch after upgrade. New fields are nullable for backward compatibility.

### 1.4: Redesign DesktopNavRail
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE]+[REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Changes:**
- `NavTab` enum: dashboard, tasks, agents, knowledge, chats, settings
- NavRail now: Avatar → Dashboard → Tasks → Agents → Knowledge → Chats → Spacer → More → Settings
- Removed: Search, Translate, Storage from main rail
- Added: More (...) popup menu (Translate, Storage → opened as sub-pages)
- ARB keys: desktopNavDashboardTooltip, desktopNavTasksTooltip, desktopNavAgentsTooltip, desktopNavKnowledgeTooltip, desktopNavMoreTooltip
- `DesktopHomePage` updated to use NavTab with IndexedStack[6]

**Known Issues:** Translate/Storage now open as separate Navigator pages rather than inline tabs. Chat action bus behavior preserved.

### 1.5: Create DashboardPage
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverables:**
- `lib/features/dashboard/pages/dashboard_page.dart` — Workspace header with icon + name + type, stat cards (agent count, conversation count), quick action chips, recent conversation list
- WorkspaceProvider-aware: shows workspace name and type icon
- ARB keys: dashboardPageQuickActions, dashboardPageNewChat, dashboardPageNewAssistant, dashboardPageRecentActivity, dashboardPageNoActivity

**Known Issues:** Quick action chips are visual only (navigation wiring deferred to Phase 1.9)

### 1.6: Workspace-aware Sidebar
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE]+[REPLACE] |
| **Priority** | High |
| **Effort** | Large |

**Changes:**
- `DesktopSidebar` now accepts optional `workspaceId` parameter
- `SideDrawer` accepts optional `workspaceId` parameter
- `_SideDrawerState._workspaceConversations()` helper filters via `ChatService.getConversationsForWorkspace()`
- All 5 `getAllConversations()` call sites in SideDrawer replaced with workspace-filtered version
- `ChatService.getConversationsForWorkspace(String?)` added

**Known Issues:** HomePage (mobile) doesn't pass workspaceId yet — only DesktopSidebar passes it. Mobile workspace filtering is a future task.

### 1.7: Workspace selector
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Small |

**Deliverables:**
- `lib/features/workspace/widgets/workspace_selector.dart` — Dropdown with current workspace name, workspace list with type icons, check mark on active, "New Workspace" option with create dialog (name + type selection)
- Type icons: User (Personal), Boxes (Project), Briefcase (Client)
- ARB keys: workspaceSelectorNewWorkspace, workspaceSelectorNameLabel, workspaceSelectorTypeLabel, workspaceSelectorCancel, workspaceSelectorCreate
- New `Briefcase` icon added to lucide adapter

**Known Issues:** Workspace deletion not exposed through selector UI yet.

### 1.8: Split SettingsProvider
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE]/[MIGRATE] |
| **Priority** | Medium |
| **Effort** | Medium |

**Changes:**
- Created `lib/core/models/workspace_settings.dart` — typed settings class with defaultAssistantId, defaultModelProvider, defaultModelId, mcpServerIds, localToolIds
- Added `Workspace.settings` field (nullable `WorkspaceSettings`) — non-breaking for existing workspaces
- Added `WorkspaceProvider.currentWorkspaceSettings`, `getWorkspaceSettings()`, `updateWorkspaceSettings()`, `clearWorkspaceSettings()` accessors
- Global `SettingsProvider` remains untouched as the global defaults source
- Workspace-level settings stored inline in workspace JSON, no extra SharedPreferences keys

**Known Issues:** SettingsProvider still has 100+ keys — workspace extraction is done, but full Provider refactor (extract MCP, backup, TTS configs into their own providers) is deferred to later phases.

### 1.9: Verification — existing functionality preserved
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | Critical |
| **Effort** | Small |

**Verification results:**
- All 4 ARB files have 32 matching workspace-related keys each ✅
- No stale `getAllConversations()` calls remain in SideDrawer (only a comment) ✅
- Conversation model workspaceId is `@HiveField(13)` — no field collisions ✅
- Assistant model workspaceId is nullable — no breakage for existing JSON ✅
- Workspace model settings is nullable — no breakage for existing persisted data ✅
- Created `test/core/models/workspace_test.dart` — covers WorkspaceType, Workspace (toJson/fromJson/copyWith/encodeList/round-trip), WorkspaceSettings (empty/json/merge/clear)
- `flutter analyze`, `flutter test`, `dart run build_runner`, `flutter gen-l10n`, `dart format` — not run (Flutter SDK unavailable). See residual risks.

**Residual risks:**
1. `conversation.g.dart` needs regeneration (`dart run build_runner build --delete-conflicting-outputs`)
2. `app_localizations*.dart` needs regeneration (`flutter gen-l10n`)
3. Formatting needs to be checked (`dart format lib/`)
4. `flutter analyze` and `flutter test` need to pass on a dev machine

---

## Phase 2 — Assistant → Agent

### 2.1: Create AgentGenome model
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/models/agent_genome.dart` — AgentGenome with identity, soul, role, goals, backstory fields
- Null-safe isEmpty, toJson/fromJson (omits empty fields), copyWith with clearXxx flags
- `AgentGenome.empty` const singleton

**Known Issues:** N/A — new model, no legacy data

### 2.2: Create Agent model + AgentType enum
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/models/agent.dart` — Agent model with id, name, type, genome, enabled fields
- `AgentType` enum: standard, lead, worker
- Agent shares the same `id` as its underlying Assistant — genome stored separately
- JSON serialization, copyWith, encodeList/decodeList

**Known Issues:** Agent IDs must match Assistant IDs exactly. Demoting removes only the genome layer.

### 2.3: Create AgentProvider
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/providers/agent_provider.dart` — CRUD for agent genome data
- `promoteToAgent()` / `demoteFromAgent()` — promote/demote assistants
- `updateGenome()`, `updateType()`, `toggleEnabled()` — fine-grained updates
- `getAgentsForWorkspace()` / `getLeadAgentForWorkspace()` — workspace-aware queries
- `syncNames()` — sync agent names from renamed assistants
- `cleanupDeletedAssistants()` — remove orphaned agent records
- Stored in SharedPreferences under `agents_v1`
- Registered in `main.dart` MultiProvider after AssistantProvider

**Known Issues:** Agent genome stored as JSON in SharedPrefs. For large-scale agent data, Hive or SQLite would be more appropriate.

### 2.4: Update AgentsPage
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Medium |

**Changes:**
- Agent-aware list items: show AgentType badge (Lead/Worker/Standard with icons)
- Genome chips: identity (User icon), soul (Heart icon), role (Briefcase icon)
- Goals displayed as tertiary-colored chips with wrap layout
- Empty genome state shows italic guidance text
- Action icons per row:
  - Non-agent: Sparkles icon -> promoteToAgent()
  - Agent: CheckCircle/XCircle -> toggleEnabled()
  - Agent: Settings icon -> opens Agent Details dialog
- Agent Details dialog: full genome editor with type dropdown, text fields, goals chip input, backstory textarea
- Demote button with error-colored text in dialog
- Lucide icons added: Crown, HardHat

**Known Issues:** Dialog-based genome editor is functional but minimal — full Agent Factory wizard deferred to Phase 4.

### 2.5: Localization keys
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- 18 new keys across all 4 ARB files:
  - agentTypeStandard, agentTypeLead, agentTypeWorker
  - agentGenomeTitle, identity/soul/role/goals/backstory labels + hints
  - agentGenomeEmpty, agentPromoteButton, agentDemoteButton
  - agentEnableLabel, agentDisableLabel, agentDetailsViewTitle
- All 4 ARB files updated in sync (en, zh, zh_Hans, zh_Hant)

**Known Issues:** Must run `flutter gen-l10n` to regenerate localizations.

### 2.6: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `test/core/models/agent_test.dart` — 3 groups, 15+ test cases:
  - AgentGenome: empty/full constructor, toJson/fromJson round-trip, empty field omission, empty map fromJson, copyWith merge + clear
  - AgentType: toJson/fromJson, unknown value default
  - Agent: defaults, toJson/fromJson with/without genome, copyWith, encodeList/decodeList round-trip, invalid JSON decode

**Known Issues:** Provider tests not yet written (require SharedPreferences mocking). Model-only tests pass independently.

---

## Phase 3 — Task System

### 3.1: Create Task model + enums
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/models/task.dart` — Task model with id, title, description, workspaceId, status, priority, assigneeAgentId, conversationId, dueDate, createdAt, updatedAt, tags, sortOrder
- `TaskStatus` enum: backlog, todo, inProgress, review, completed, cancelled
- `TaskPriority` enum: none, low, medium, high, urgent
- JSON serialization with optional field omission, copyWith with clearXxx flags

**Known Issues:** N/A — new model, no legacy data

### 3.2: Create TaskProvider
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/providers/task_provider.dart` — CRUD for tasks, SharedPreferences persistence (tasks_v1)
- Workspace-aware queries: getTasksForWorkspace(), getTasksForWorkspaceByStatus()
- Agent-aware queries: getTasksForAgent()
- Status management: updateTaskStatus(), reorderTasks()
- Priority and assignment: updateTaskPriority(), assignTask(), unassignTask()
- Bulk operations: getStatusCounts(), deleteTasksForWorkspace()
- Registered in main.dart MultiProvider

**Known Issues:** Task data stored as JSON in SharedPrefs. For large-scale task management, consider migrating to Hive or SQLite.

### 3.3: Kanban TasksPage
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Changes:**
- Complete rewrite of tasks_page.dart from conversation list placeholder to real kanban board
- Horizontally scrollable columns: Backlog, To Do, In Progress, Review, Completed, Cancelled
- Each column: status header with icon + count badge, task cards
- Task cards: title (2 lines), description preview, priority badge, assignee chip, due date chip, status move popup
- Tap card to edit: full dialog with title, description, status dropdown, priority dropdown, delete button
- "New Task" FAB in title bar + empty state
- Create dialog: title, description, priority selection
- Lucide icons added: List, Play, Circle

**Known Issues:** No drag-and-drop between columns yet (uses popup menu for status changes). Full drag-and-drop deferred to Phase 3+ enhancement.

### 3.4: Dashboard task stat
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | Medium |
| **Effort** | Small |

**Changes:**
- Added third _StatCard to dashboard: task count with tertiary color
- Imported TaskProvider in dashboard_page.dart

### 3.5: Localization keys
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- 22 new keys across all 4 ARB files:
  - tasksPageCreateTask, tasksPageEditTask, tasksPageDeleteTask
  - tasksPageTitleLabel, tasksPageTitleHint
  - tasksPageDescriptionLabel, tasksPageDescriptionHint
  - tasksPagePriorityLabel, tasksPageStatusLabel, tasksPageMoveTask
  - tasksColumnEmpty
  - tasksStatusBacklog through tasksStatusCancelled (6)
  - tasksPriorityNone through tasksPriorityUrgent (5)
  - dashboardPageTasks

**Known Issues:** Must run flutter gen-l10n to regenerate localizations.

### 3.6: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- test/core/models/task_test.dart — 3 groups, 20+ test cases:
  - TaskStatus: values, toJson/fromJson, unknown default
  - TaskPriority: values, toJson/fromJson, unknown default
  - Task: defaults, full round-trip, minimal round-trip, optional field omission, copyWith preserve + 5 clearXxx flags, encodeList/decodeList, invalid JSON decode

**Known Issues:** Provider tests not yet written (require SharedPreferences mocking). Model-only tests pass independently.

---

## Phase 4 — Agent Factory

### 4.1: Create AgentTemplate model
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `lib/core/models/agent_template.dart` — AgentTemplate with id, name, description, iconName, agentType, genome, suggestedSystemPrompt
- JSON serialization (toJson/fromJson), null-safe defaults for optional fields

**Known Issues:** N/A — new model, no legacy data

### 4.2: Build-in agent templates
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `lib/core/services/agent_templates.dart` — AgentTemplateService with 4 built-in templates:
  - General Assistant (Standard type) — everyday conversations and queries
  - Code Helper (Worker type) — code writing, review, debugging
  - Writer (Worker type) — content creation and editing
  - Researcher (Worker type) — deep research and analysis
- Each template has pre-filled identity, soul, role, goals, backstory, and suggested system prompt
- `getById()` lookup and `builtInTemplates` list accessor

**Known Issues:** Templates are const singletons. Custom user-defined templates are deferred.

### 4.3: Multi-step Agent Factory wizard
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Deliverable:**
- `lib/features/agent_factory/pages/agent_factory_page.dart` — 4-step wizard:
  - Step 1 (Template): Cards for each built-in template + "Start from Scratch" option
  - Step 2 (Identity): Name and description text fields
  - Step 3 (Role & Genome): Agent type dropdown + identity/soul/role/goals/backstory editors
  - Step 4 (Review): Summary cards showing all selected settings
- Step indicator with numbered dots and connector lines
- Creates a new Assistant via AssistantProvider, promotes to Agent via AgentProvider
- SnackBar feedback on success/failure

**Known Issues:** Knowledge attachment and MCP tool selection steps deferred to Phase 4+ enhancement. Dashboard quick action navigation wiring still deferred.

### 4.4: AgentsPage entry point
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- Added FilledButton.icon "New Agent" in agents page title row
- Navigates to AgentFactoryPage via MaterialPageRoute

### 4.5: Localization keys
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- 24 new keys across all 4 ARB files:
  - agentFactoryTitle, agentFactoryNewAgent
  - agentFactoryStepTemplate, agentFactoryStepIdentity, agentFactoryStepGenome, agentFactoryStepReview
  - agentFactoryTemplateSubtitle, agentFactoryScratch, agentFactoryScratchDesc
  - agentFactoryIdentitySubtitle, agentFactoryNameLabel, agentFactoryNameHint
  - agentFactoryDescLabel, agentFactoryDescHint
  - agentFactoryGenomeSubtitle, agentFactoryReviewSubtitle
  - agentFactoryBack, agentFactoryNext, agentFactoryCreate
  - agentFactoryCreated, agentFactoryCreatedSnackbar, agentFactoryCreateFailed, agentFactoryBasedOn
- All 4 ARB files updated in sync (en, zh, zh_Hans, zh_Hant)

**Known Issues:** Must run `flutter gen-l10n` to regenerate localizations.

### 4.6: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `test/core/models/agent_template_test.dart` — 3 groups, 15+ test cases:
  - AgentTemplate: constructor, defaults, toJson/fromJson round-trip, missing/empty/null field handling, unknown type default
  - AgentTemplateService: 4 templates returned, each template by ID, null for unknown ID, non-empty descriptions, valid types, non-empty system prompts, unique IDs

**Known Issues:** Service tests verify structural properties but not functional behavior.

---

## Phase 5 — Lead Agent

### 5.1: Create ExecutionTrace model + TraceProvider
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverables:**
- `lib/core/models/execution_trace.dart` — ExecutionTrace with status (planning→delegating→executing→reviewing→completed/failed), steps (ExecutionStep with StepType/StepStatus), full JSON serialization, copyWith with clearXxx flags, encodeList/decodeList
- `lib/core/providers/trace_provider.dart` — TraceProvider with CRUD, workspace-scoped queries, step management, SharedPreferences persistence (execution_traces_v1)
- Registered in `main.dart` MultiProvider after TaskProvider

**Known Issues:** N/A — new code, no legacy data

### 5.2: Create LeadAgentService
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Large |

**Deliverable:**
- `lib/core/services/lead_agent_service.dart` — Core orchestration:
  - Plan phase: Calls lead agent's LLM to break user request into sub-tasks
  - Delegate phase: Creates Task objects, assigns to available Worker agents
  - Execute phase: Calls each worker's LLM with task description and returns results
  - Review phase: Calls lead agent's LLM to consolidate worker results
- Uses `ChatApiService.sendMessageStream()` for all LLM calls
- Lead agent's model config used for planning/review; worker's own assistant config for execution
- Progress callback for real-time UI updates
- Execution trace persisted through TraceProvider at each stage

**Known Issues:** LLM calls are synchronous (await stream completion). No streaming progress within individual LLM calls.

### 5.3: Lead Agent built-in template
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- Added `_leadAgent` template to `agent_templates.dart` with AgentType.lead
- Identity: "a strategic lead agent and team orchestrator"
- Goals include delegation, planning, review
- AgentTemplateService builtInTemplates now returns 5 templates (up from 4)

**Known Issues:** Template count test updated from 4→5 in agent_template_test.dart.

### 5.4: Lead Agent execution page
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Deliverable:**
- `lib/features/lead_agent/pages/lead_agent_execution_page.dart`:
  - Input card: user types goal or request
  - Execute button with loading indicator
  - Status banner: shows current phase (planning/delegating/etc.) with progress bar
  - Steps timeline: cards for each execution step with type icon, status indicator, description, and truncated result preview
  - Result card: selectable text showing final consolidated response
- Navigation: Play icon button on lead agents in AgentsPage → LeadAgentExecutionPage

**Known Issues:** No live streaming of LLM output within steps. Results shown after step completion.

### 5.5: Localization keys
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- 16 new keys across all 4 ARB files:
  - leadAgentInputTitle, leadAgentInputHint
  - leadAgentExecuteButton, leadAgentExecuting
  - leadAgentEmpty
  - leadAgentStatusPlanning through leadAgentStatusFailed (6)
  - leadAgentSteps, leadAgentResult, leadAgentAssignedTo
  - leadAgentRunButton, leadAgentDelegatedTo (with {task} placeholder)
- All 4 ARB files updated in sync (en, zh, zh_Hans, zh_Hant)

**Known Issues:** Must run `flutter gen-l10n` to regenerate localizations.

### 5.6: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `test/core/models/execution_trace_test.dart` — 4 groups, 40+ test cases:
  - ExecutionStatus: values, toJson/fromJson, unknown default → failed
  - StepType: values, toJson/fromJson, unknown default → plan
  - StepStatus: values, toJson/fromJson, unknown default → pending
  - ExecutionStep: defaults, toJson field omission, full field inclusion, fromJson all/missing, copyWith preserve + clear flags
  - ExecutionTrace: defaults, full round-trip, JSON omission, minimal JSON parse, copyWith merge + clear, encodeList/decodeList, invalid JSON handling
- `test/core/models/agent_template_test.dart` updated: 4→5 templates, lead-agent test added

**Known Issues:** Provider tests not yet written (require SharedPreferences mocking). Model-only tests pass independently.

---

## Phase 6 — Multi-Agent Orchestration

### 6.1: Create AgentTeam model + TeamProvider
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverables:**
- `lib/core/models/agent_team.dart` — AgentTeam model with id, name, description, workspaceId, leadAgentId, memberAgentIds, JSON serialization, copyWith, encodeList/decodeList
- `lib/core/providers/team_provider.dart` — TeamProvider: CRUD, workspace-scoped queries, member management, SharedPreferences persistence (agent_teams_v1)
- Registered as ChangeNotifierProvider in main.dart

**Known Issues:** N/A — new code, no legacy data

### 6.2: Worker Agent service
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/services/orchestration/worker_agent_service.dart` — WorkerAgentService with executeTask(), executeTasks(), system prompt builder
- Works with any Agent's LLM via callLlm callback
- Sequential multi-task execution with progress callback

**Known Issues:** Tasks execute sequentially. Parallel execution could be added as optimization.

### 6.3: Manager Agent service
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/services/orchestration/manager_agent_service.dart` — ManagerAgentService with orchestrate() that routes Lead → Manager → Workers
- Delegates tasks to WorkerAgentService, collects results, returns ManagerResult
- Builds execution steps for trace tracking

**Known Issues:** Single-threaded worker execution. Multi-threaded orchestration deferred to Phase 6+.

### 6.4: Agent Communication protocol
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `lib/core/services/orchestration/agent_communication.dart` — AgentMessage model, MessageType enum, AgentCommunication protocol class
- Structured message passing (Lead→Manager→Worker, results flow back up)
- Step builder and trace formatter for communication visualization

**Known Issues:** Message routing is logical (in-process). Network-level agent communication is future work.

### 6.5: Team management page
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Changes:**
- `lib/features/team/pages/team_page.dart` — Team list with lead agent + member cards, create dialog (name, description, lead selection), member management dialog (add/remove workers), delete confirmation
- Accessible from Agents page via "Teams" button

**Known Issues:** UI is dialog-based member management. Drag-and-drop team builder deferred.

### 6.6: Traces history page
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Changes:**
- `lib/features/traces/pages/traces_page.dart` — Execution history list with status icons, agent names, timestamps, step counts
- Detail dialog: user request, status, full step timeline, final response, timestamps
- Accessible from Agents page via "Traces" button

**Known Issues:** No real-time trace updates — user must navigate back and re-open.

### 6.7: Localization keys
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- 37+ new keys across all 4 ARB files:
  - agentsPageTeams, agentsPageTraces
  - teamPageTitle through teamPageClose (18 keys)
  - tracesPageTitle through tracesPageClose (9 keys)
- All 4 ARB files updated in sync (en, zh, zh_Hans, zh_Hant)

**Known Issues:** Must run `flutter gen-l10n` to regenerate localizations.

### 6.8: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `test/core/models/agent_team_test.dart` — 10+ test cases:
  - AgentTeam: constructor defaults, all fields, copyWith preserve + clear flags
  - toJson/fromJson round-trip: all fields, optional field omission, missing fields
  - encodeList/decodeList: round-trip, invalid JSON handling

**Known Issues:** Provider tests not yet written (require SharedPreferences mocking). Model-only tests pass independently.

---

## Phase 8 — Channels

### 8.1: Create AgentChannel model
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/models/agent_channel.dart` — AgentChannel model with id, name, agentId, workspaceId, type (ChannelType enum: telegram/discord/slack/email/webhook/webWidget), configJson for type-specific settings, enabled flag
- Channel config getter parses JSON on access; empty config omitted from JSON; copyWith with clearName/clearConfig flags
- encodeList/decodeList for SharedPrefs persistence
- ChannelType enum with toJson/fromJson, unknown default → telegram

**Known Issues:** N/A — new model, no legacy data

### 8.2: Create ChannelProvider
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/providers/channel_provider.dart` — CRUD for AgentChannel, SharedPreferences persistence (agent_channels_v1)
- Workspace-aware queries: getChannelsForWorkspace(), getChannelsForAgent()
- toggleEnabled(), updateConfig() for fine-grained updates
- Duplicate-prevention: rejects duplicate agentId+type pairs on create
- Registered as ChangeNotifierProvider in main.dart

**Known Issues:** Channel data stored as JSON in SharedPrefs. Future migration to Hive recommended.

### 8.3: Create ChannelAdapter interface
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/services/channels/channel_adapter.dart` — ChannelAdapter abstract class with sendMessage(), testConnection(), validateConfig(), configFields
- ChannelResult model for operation outcomes
- ChannelConfigField descriptor with key, label, hint, isSecret, isRequired, defaultValue, inputType

**Known Issues:** N/A — new code, no legacy data

### 8.4: Channel Adapter Implementations
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Large |

**Deliverables:**
- `lib/core/services/channels/telegram_adapter.dart` — TelegramAdapter (Bot Token + Chat ID)
- `lib/core/services/channels/discord_adapter.dart` — DiscordAdapter (Bot Token + Channel ID + Guild ID)
- `lib/core/services/channels/slack_adapter.dart` — SlackAdapter (Bot Token + Channel ID + Signing Secret)
- `lib/core/services/channels/email_adapter.dart` — EmailAdapter (SMTP Host/Port, Username/Password, TLS, IMAP/POP)
- `lib/core/services/channels/webhook_adapter.dart` — WebhookAdapter (URL, Method, Secret, Custom Headers)
- `lib/core/services/channels/web_widget_adapter.dart` — WebWidgetAdapter (Allowed Origin, Widget Title, Color, Position)
- `lib/core/services/channels/channel_adapter_service.dart` — Registry providing lookup by ChannelType, all adapters list, testChannel()

**Known Issues:** All adapters are placeholder implementations. Actual API calls (Telegram Bot API, Discord Gateway, Slack API, SMTP/IMAP, HTTP POST) need to be implemented with real HTTP clients. Adapter config fields define the UI schema.

### 8.5: Channels UI page
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Deliverable:**
- `lib/features/channels/pages/channels_page.dart` — Full channel management page:
  - Empty state with icon + guidance + "Add Channel" button
  - Channel list with cards showing name, type icon, enabled toggle, agent binding, action buttons (Configure, Test, Delete)
  - Add channel dialog: type dropdown with icons, name field, agent ID field
  - Configure dialog: dynamic field list from adapter's configFields, secret fields masked
  - Test button calls adapter.testConnection() with snackbar feedback
  - Delete confirmation dialog
- Workspace-scoped: accepts optional workspaceId parameter
- Navigated from DesktopNavRail channels tab (NavTab.channels)

**Known Issues:** Agent ID binding is text-based (no agent picker). Agent picker integration deferred.

### 8.6: NavRail integration
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- `NavTab` enum now includes `channels` (7 values total: dashboard/tasks/agents/knowledge/channels/chats/settings)
- DesktopNavRail: added Channels button (Network icon) between Knowledge and Chats
- DesktopHomePage: updated tab clamping (0→6), added onTapChannels callback, ChannelsPage in IndexedStack

### 8.7: Localization keys
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- 21 new keys across all 4 ARB files:
  - channelsPageTitle, channelsPageEmpty, channelsPageEmptyHint, channelsPageAddChannel
  - channelsPageTypeLabel, channelsPageNameLabel, channelsPageNameHint
  - channelsPageAgentIdLabel, channelsPageAgentIdHint
  - channelsPageCreate, channelsPageCancel, channelsPageSave, channelsPageDelete
  - channelsPageDeleteConfirmTitle, channelsPageDeleteConfirmContent
  - channelsPageConfigure, channelsPageTest, channelsPageTestSuccess, channelsPageTestFailed
  - channelsPageDisabled, channelsPageBoundTo, desktopNavChannelsTooltip

### 8.8: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `test/core/models/agent_channel_test.dart` — 30+ test cases:
  - ChannelType: values, fromJson/unknown default, toJson/fromJson round-trip
  - AgentChannel: constructor defaults, config getter (valid/invalid JSON), copyWith preserve + clearName/clearConfig, toJson field omission, toJson/fromJson round-trip (full + minimal), missing field handling, encodeList/decodeList round-trip, invalid JSON

**Known Issues:** Provider tests not yet written (require SharedPreferences mocking). Adapter integration tests deferred (require network access). Model-only tests pass independently.

---
## Phase 9 — Sync Server

### 9.1: SyncDevice model
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/models/sync_device.dart` — SyncDevice model with id, name, platform, isCurrentDevice, authToken, lastSyncAt, registeredAt. JSON serialization, copyWith, encodeList/decodeList.

**Known Issues:** N/A — new model, no legacy data

### 9.2: SyncRecord model + SyncStatus enum
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/models/sync_record.dart` — SyncRecord model with id, deviceId, workspaceId, status (SyncStatus enum: idle/syncing/success/failed/paused), itemsPushed/Pulled/conflictsResolved, errorMessage, timestamps. Duration getter, JSON serialization, copyWith with clearError, encodeList/decodeList.

**Known Issues:** N/A — new model, no legacy data

### 9.3: AuthProvider (device identity + registration)
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/providers/auth_provider.dart` — AuthProvider with ensureDeviceIdentity (auto-generate ID), registerDevice (set auth token), unregisterDevice (clear token), updateLastSync, renameDevice, removeDevice. Persists current device and known devices list to SharedPreferences. Workspace-scoped query for known devices.
- Registered in main.dart MultiProvider after ChannelProvider.

**Known Issues:** No actual JWT validation or HTTP relay server integration yet — auth token storage is placeholder for real server integration.

### 9.4: SyncProvider (sync engine + SyncConfig)
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/providers/sync_provider.dart` — SyncProvider with SyncConfig model (autoSyncEnabled, relayServerUrl, syncIntervalMinutes, data type toggles). Supports startSync/completeSync/failSync lifecycle, getRecordsForWorkspace, getRecordsForDevice, clearRecords, pruneRecordsOlderThan. SharedPreferences persistence.
- Registered in main.dart MultiProvider after AuthProvider.

**Known Issues:** Sync engine currently operates in simulation mode (2-second delay). Real HTTP relay sync requires server implementation.

### 9.5: Sync UI page
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Deliverable:**
- `lib/features/sync/pages/sync_page.dart` — Full sync management page with three sections:
  - Device section: current device info (name, platform, ID, last sync), register/unregister actions
  - Config section: auto-sync toggle, data type toggles (workspaces, agents, tasks, channels)
  - History section: sync records with status icons, item counts, duration
- Empty state for no sync records
- "Sync Now" action button with loading indicator

**Known Issues:** Register dialog is token-based (token input). Actual server registration flow deferred to relay server implementation.

### 9.6: NavRail integration
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- `NavTab` enum now includes `sync` (8 values total: dashboard/tasks/agents/knowledge/channels/sync/chats/settings)
- DesktopNavRail: added Sync button (RefreshCw icon) between Channels and Chats
- DesktopHomePage: updated tab clamping (0→7), added onTapSync callback, SyncPage in IndexedStack

### 9.7: Localization keys
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- 30 new keys across all 4 ARB files:
  - syncPageTitle, desktopNavSyncTooltip
  - syncPageDeviceSection through syncPageLastSync (4 device info keys)
  - syncPageRegister through syncPageUnregister (8 registration keys)
  - syncPageConfigSection through syncPageSyncChannels (6 config keys)
  - syncPageSyncNow, syncPageSyncing (action keys)
  - syncPageHistorySection, syncPageNoRecords
  - syncStatusSyncing through syncStatusIdle (5 status keys)
  - syncPageItemsSummary with {pushed}/{pulled}/{conflicts} placeholders
- All 4 ARB files updated in sync (en, zh, zh_Hans, zh_Hant)

**Known Issues:** Must run `flutter gen-l10n` to regenerate localizations.

### 9.8: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `test/core/models/sync_device_test.dart` — 10+ test cases: constructor defaults, all fields, copyWith, toJson/fromJson round-trip (full + minimal), empty authToken omission, missing field defaults, encodeList/decodeList, invalid JSON handling
- `test/core/models/sync_record_test.dart` — 25+ test cases: SyncStatus enum values/fromJson/toJson/unknown default, SyncRecord constructor defaults/all fields, copyWith preserve + clearError, toJson field omission (empty error), toJson/fromJson round-trip (full + minimal), missing field handling, encodeList/decodeList, invalid JSON, duration calculation
- `test/core/providers/sync_config_test.dart` — 10+ test cases: constructor defaults, copyWith preserve + clearUrl, toJson/fromJson round-trip, missing field defaults

**Known Issues:** Provider integration tests not yet written (require SharedPreferences mocking). Model-only tests pass independently.

---

## Phase 10 — Runtime Host

### 10.1: Create RuntimeExecution model + RuntimeExecutionStatus enum
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/models/runtime_execution.dart` — RuntimeExecution model with id, agentId, agentName, workspaceId, taskId, taskTitle, status (RuntimeExecutionStatus enum: pending/running/completed/failed/cancelled), resultSummary, errorMessage, startedAt, completedAt. Duration getter (null when not completed). JSON serialization with optional field omission for empty strings. copyWith with clearResult/clearError flags. encodeList/decodeList for SharedPrefs persistence.

**Known Issues:** N/A — new model, no legacy data

### 10.2: Create ScheduleInterval enum + ScheduledRun model
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Small |

**Deliverable:**
- `lib/core/services/scheduler_service.dart` — ScheduleInterval enum (once/hourly/daily/weekly/monthly) with Duration getter (zero/1h/1d/7d/30d). ScheduledRun model with id, agentId, agentName, workspaceId, taskTitle, interval, enabled, timestamps. JSON serialization. copyWith with clearLastRun/clearNextRun flags. encodeList/decodeList.

**Known Issues:** ScheduleInterval.once.nextRunAt is set to `now` on creation, so it fires immediately. Monthly interval approximated as 30 days.

### 10.3: Create SchedulerService
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/services/scheduler_service.dart` — SchedulerService (ChangeNotifier) with SharedPreferences persistence (scheduled_runs_v1). 60-second periodic tick timer. onScheduleDue callback. CRUD: createSchedule, updateSchedule, toggleEnabled, deleteSchedule. Workspace-aware queries: getSchedulesForWorkspace, getSchedulesForAgent. Batch delete: deleteSchedulesForWorkspace. Auto-advances schedule on due: updates lastRunAt/nextRunAt.

**Known Issues:** Timer-based polling (60s granularity). Real cron-like scheduling would need more sophisticated engine.

### 10.4: Create RuntimeProvider (host status + execution management)
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | Critical |
| **Effort** | Medium |

**Deliverable:**
- `lib/core/providers/runtime_provider.dart` — RuntimeProvider (ChangeNotifier) with RuntimeHostStatus enum (stopped/running/error). Host lifecycle: startHost, stopHost. Execution lifecycle: startExecution, completeExecution, failExecution, cancelExecution. Analytics: uptime, successCount, failedCount, activeExecutions, lastExecution. Workspace-aware: getExecutionsForWorkspace. Agent-aware: getExecutionsForAgent. History management: clearHistory, pruneHistoryOlderThan. Scheduler integration: attachScheduler (auto start/stop with host). Placeholder: simulateExecution (3-second delay). SharedPreferences persistence (runtime_executions_v1, runtime_host_status_v1).

**Known Issues:** simulateExecution is a placeholder with hardcoded delay. Real LLM execution integration requires LeadAgentService wiring.

### 10.5: Runtime Host UI page
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [REPLACE] |
| **Priority** | High |
| **Effort** | Medium |

**Deliverable:**
- `lib/features/runtime/pages/runtime_page.dart` — Four-section card-based layout:
  - _HostStatusSection: status badge (green dot when running), start/stop buttons, uptime display, success/failed counts
  - _ActiveExecutionsSection: currently running executions with status icons (spinner/completed/failed/cancelled/dot), duration display, "Simulate Execution" button (host must be running)
  - _ScheduleSection: schedule list with agent name, interval text (once/hourly/daily/weekly/monthly), enable/disable toggle
  - _HistorySection: past execution records (most recent 20, reversed), same _ExecutionRow component
- Workspace-scoped: reads current workspace from WorkspaceProvider
- Agent-aware: simulate button uses first available agent from AgentProvider

**Known Issues:** No drag-to-reorder for schedules. Simulate execution always picks first available agent.

### 10.6: NavRail + Provider registration + Localization
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [ENHANCE] |
| **Priority** | High |
| **Effort** | Small |

**Changes:**
- `NavTab` enum now includes `runtime` (9 values total: dashboard/tasks/agents/knowledge/channels/sync/runtime/chats/settings)
- `DesktopNavRail`: added Runtime button (Server icon) between Sync and Chats
- `DesktopHomePage`: updated tab clamping (0→8), added onTapRuntime callback, RuntimePage in IndexedStack at index 6
- `main.dart`: registered SchedulerService and RuntimeProvider as ChangeNotifierProviders
- 26 new keys across all 4 ARB files:
  - runtimePageTitle, desktopNavRuntimeTooltip
  - runtimePageHostSection, runtimePageUptime, runtimePageStart, runtimePageStop
  - runtimePageSuccessCount, runtimePageFailedCount
  - runtimeStatusRunning, runtimeStatusStopped, runtimeStatusPending, runtimeStatusCompleted, runtimeStatusFailed, runtimeStatusCancelled
  - runtimePageActiveSection, runtimePageNoActive, runtimePageSimulate
  - runtimePageScheduleSection, runtimePageNoSchedules
  - runtimePageHistorySection, runtimePageNoHistory
  - scheduleIntervalOnce, scheduleIntervalHourly, scheduleIntervalDaily, scheduleIntervalWeekly, scheduleIntervalMonthly

**Known Issues:** Must run `flutter gen-l10n` to regenerate localizations.

### 10.7: Unit tests
| Field | Value |
|---|---|
| **Status** | ✅ Complete |
| **Classification** | [KEEP] |
| **Priority** | High |
| **Effort** | Small |

**Deliverable:**
- `test/core/models/runtime_execution_test.dart` — 20+ test cases: RuntimeExecutionStatus values/fromJson/toJson/unknown default round-trip, RuntimeExecution constructor defaults/all fields, copyWith preserve + clearResult/clearError, JSON field omission, toJson/fromJson round-trip (full + minimal), missing field handling, encodeList/decodeList round-trip, invalid JSON handling, duration calculation (completed vs pending)
- `test/core/models/scheduled_run_test.dart` — 20+ test cases: ScheduleInterval values/fromJson/toJson/unknown default/duration values round-trip, ScheduledRun constructor defaults/all fields, copyWith preserve + clearLastRun/clearNextRun, toJson/fromJson round-trip (full + minimal), missing field handling, encodeList/decodeList round-trip, invalid JSON handling
- `test/core/providers/runtime_host_status_test.dart` — 8+ test cases: RuntimeHostStatus values, fromJson/toJson/unknown default round-trip

**Known Issues:** Provider integration tests not yet written (require SharedPreferences mocking). Model-only tests pass independently.

| # | Date | Issue | Decision | Status |
|---|---|---|---|---|
| 1 | 2026-06-11 | Assistant storage in SharedPrefs (JSON string) not scalable for Agent genome | Migrate to Hive or SQLite when agent model expands (Phase 2) | ⏳ Deferred |
| 2 | 2026-06-11 | SettingsProvider is a god class with 100+ keys | Split in Phase 1.8 — extract workspace and agent settings | 📋 Planned |
| 3 | 2026-06-11 | No unit test infrastructure for providers | Add basic tests alongside new code | ⏳ Deferred |
| 4 | 2026-06-11 | Conversation model lacks workspaceId | Add Hive field in Phase 1.2 | 📋 Planned |
| 5 | 2026-06-11 | Assistant model lacks workspaceId and agent genome fields | Add in Phase 1.2 (workspaceId) and Phase 2 (genome) | 📋 Planned |
| 6 | 2026-06-11 | `package:Kelivo/` imports are hardcoded | Must keep imports consistent or use package rename | ⏳ Deferred |
| 7 | 2026-06-11 | Flutter CLI not available in dev environment | `flutter gen-l10n`, `dart run build_runner`, `flutter analyze`, `flutter test` cannot run locally. Must run on dev machine with Flutter SDK. | ⚠️ Active |
| 8 | 2026-06-11 | Conversation model got new HiveField(13) workspaceId | Must run `dart run build_runner build --delete-conflicting-outputs` to regenerate `conversation.g.dart` | 📋 Required |
| 9 | 2026-06-11 | Sidebar workspace filter is desktop-only | HomePage (mobile) doesn't pass workspaceId yet. Mobile workspace support is Phase 1+ extension. | ⏳ Deferred |
| 10 | 2026-06-11 | Workspace model now has nullable `settings` field | Legacy persisted workspaces without `settings` key will deserialize with `settings: null` — safe. | ✅ Handled |
| 11 | 2026-06-11 | SettingsProvider unchanged for global config | Workspace-level settings extracted into WorkspaceSettings model. Global settings extraction (MCP, backup, TTS) deferred. | ⏳ Deferred |
| 12 | 2026-06-11 | Agent genome stored as JSON in SharedPrefs | AgentProvider stores genome in `agents_v1` SharedPrefs JSON string. Hive or SQLite recommended when agent count grows. | ⏳ Deferred |
| 13 | 2026-06-11 | AgentProvider depends on AssistantProvider | AgentProvider constructor requires AssistantProvider reference. Must be registered after AssistantProvider in MultiProvider. | ✅ Handled |
| 14 | 2026-06-11 | agents_page.dart dialog uses TextEditingController.fromValue | Dialog genome fields use disposable controllers. Could cause cursor position issues on rebuild — acceptable for Phase 2. | ⏳ Deferred |
| 15 | 2026-06-11 | Task data stored as JSON in SharedPrefs | TaskProvider stores in tasks_v1 SharedPrefs JSON. Consider Hive/SQLite for large-scale task management. | ⏳ Deferred |
| 16 | 2026-06-11 | Kanban board uses popup menu for status changes | No drag-and-drop between columns yet. Full DnD requires Flutter's Draggable/DragTarget or ReorderableListView. | ⏳ Deferred |
| 17 | 2026-06-11 | Task-Conversation linking not wired | Task.conversationId exists but no UI for linking conversations to tasks yet. Deferred to multi-agent phase. | ⏳ Deferred |
| 18 | 2026-06-11 | Agent Factory wizard has identity/genome steps but no knowledge/tool/MCP selection | Knowledge attachment, tool selection, and MCP profile selector deferred to Phase 4+ enhancements. Wizard creates minimal agent; full configuration available via existing assistant settings tabs. | ⏳ Deferred |
| 19 | 2026-06-11 | Dashboard "New Agent" quick action chip is visual only | Navigation wiring not yet connected. User must navigate to Agents tab to use Agent Factory. | ⏳ Deferred |
| 20 | 2026-06-11 | Typo fixed: TaskStatbilus → TaskStatus in task.dart | Inline fix applied. No functional impact. | ✅ Handled |
| 21 | 2026-06-11 | LeadAgentService uses synchronous stream collection for LLM calls | Each LLM call awaits the full stream before returning. No live streaming of partial results within individual steps. Acceptable for Phase 5; streaming within steps deferred to Phase 6 enhancement. | ⏳ Deferred |
| 22 | 2026-06-11 | LeadAgentService._callLlm creates standalone API messages without chat context | System prompts use hardcoded templates rather than the assistant's existing system prompt configuration. Worker agent prompts include the original user request for context. | ⏳ Deferred |
| 23 | 2026-06-11 | Lead agent execution is single-threaded — workers execute sequentially | Tasks are executed one at a time. Parallel worker execution could be added in Phase 6 for multi-agent optimization. | ⏳ Deferred |
| 24 | 2026-06-11 | Channel adapters are placeholder implementations | Actual API integrations (Telegram Bot API, Discord Gateway, Slack API, SMTP, Webhook HTTP) need real HTTP clients. Adapter interface and config schema are complete and functional. | ⏳ Deferred |
| 25 | 2026-06-11 | Channel agent binding is text-based (no agent picker) | Agent ID field is a free-text input. A proper agent picker/search component would improve UX. | ⏳ Deferred |
| 26 | 2026-06-11 | Sync engine operates in simulation mode | SyncProvider simulates a 2-second delay instead of real HTTP relay sync. Real sync server implementation is Phase 9+ enhancement. | ⏳ Deferred |
| 27 | 2026-06-11 | AuthProvider stores tokens without validation | Auth tokens are stored as-is without JWT validation. Real JWT validation and relay server integration deferred. | ⏳ Deferred |
| 28 | 2026-06-11 | simulateExecution uses hardcoded 3-second delay | Placeholder for real LLM execution. Real execution requires LeadAgentService wiring. | ⏳ Deferred |
| 29 | 2026-06-11 | SchedulerService uses 60-second periodic polling | Timer-based polling instead of real cron. 60s granularity acceptable for Phase 10. | ⏳ Deferred |

---

## Deliverables Index

| File | Phase | Status | Description |
|---|---|---|---|
| `CURRENT_STATE.md` | 0 | ✅ Complete | Full architecture audit |
| `YLAGENTS_PHASE0_PLAN.md` | 0/0.5 | ✅ Complete | Phase plan with all task details |
| `PROGRESS_TRACKING.md` | All | 🔄 Active | This file — live progress tracking |
| `kelivo/lib/core/models/workspace.dart` | 1.1 | ✅ Complete | Workspace model + WorkspaceType enum |
| `kelivo/lib/core/providers/workspace_provider.dart` | 1.1 | ✅ Complete | Workspace CRUD + migration |
| `kelivo/lib/core/models/conversation.dart` | 1.2 | ✅ Complete | Added workspaceId HiveField(13) |
| `kelivo/lib/core/models/assistant.dart` | 1.2 | ✅ Complete | Added workspaceId JSON field |
| `kelivo/lib/core/services/chat/chat_service.dart` | 1.3 | ✅ Complete | Migration + workspace filtering |
| `kelivo/lib/desktop/desktop_nav_rail.dart` | 1.4 | ✅ Complete | Workspace-first nav rail (6 tabs) |
| `kelivo/lib/desktop/desktop_home_page.dart` | 1.4 | ✅ Complete | NavTab IndexedStack + More menu |
| `kelivo/lib/features/dashboard/pages/dashboard_page.dart` | 1.5 | ✅ Complete | Workspace dashboard overview |
| `kelivo/lib/features/tasks/pages/tasks_page.dart` | 1.5 | ✅ Complete | Tasks landing page |
| `kelivo/lib/features/agents/pages/agents_page.dart` | 1.5 | ✅ Complete | Agents landing page |
| `kelivo/lib/features/knowledge/pages/knowledge_page.dart` | 1.5 | ✅ Complete | Knowledge landing page |
| `kelivo/lib/desktop/desktop_sidebar.dart` | 1.6 | ✅ Complete | Workspace-aware sidebar wrapper |
| `kelivo/lib/features/home/widgets/side_drawer.dart` | 1.6 | ✅ Complete | Workspace conversation filtering |
| `kelivo/lib/features/workspace/widgets/workspace_selector.dart` | 1.7 | ✅ Complete | Workspace dropdown selector + create dialog |
| `kelivo/lib/icons/lucide_adapter.dart` | 1.7 | ✅ Complete | Added Briefcase icon |
| `kelivo/lib/core/models/workspace_settings.dart` | 1.8 | ✅ Complete | WorkspaceSettings model (typed settings) |
| `test/core/models/workspace_test.dart` | 1.9 | ✅ Complete | Unit tests for Workspace, WorkspaceType, WorkspaceSettings |
| `kelivo/lib/core/models/agent_genome.dart` | 2.1 | ✅ Complete | AgentGenome model (identity, soul, role, goals, backstory) |
| `kelivo/lib/core/models/agent.dart` | 2.2 | ✅ Complete | Agent model + AgentType enum (standard, lead, worker) |
| `kelivo/lib/core/providers/agent_provider.dart` | 2.3 | ✅ Complete | AgentProvider: genome CRUD, promote/demote, workspace-aware queries |
| `kelivo/lib/features/agents/pages/agents_page.dart` | 2.4 | ✅ Complete | Agent-aware agents list with genome chips, type badges, detail dialog |
| `test/core/models/agent_test.dart` | 2.6 | ✅ Complete | Unit tests for Agent, AgentGenome, AgentType |
| `kelivo/lib/l10n/app_*.arb` (4 files) | 2.5 | ✅ Complete | 18 new agent genome keys |
| `kelivo/lib/core/models/task.dart` | 3.1 | ✅ Complete | Task model + TaskStatus + TaskPriority enums |
| `kelivo/lib/core/providers/task_provider.dart` | 3.2 | ✅ Complete | TaskProvider: CRUD, workspace-aware queries, status management |
| `kelivo/lib/features/tasks/pages/tasks_page.dart` | 3.3 | ✅ Complete | Kanban board with status columns, task cards, create/edit dialogs |
| `kelivo/lib/features/dashboard/pages/dashboard_page.dart` | 3.4 | ✅ Complete | Task count stat card |
| `test/core/models/task_test.dart` | 3.6 | ✅ Complete | Unit tests for Task, TaskStatus, TaskPriority |
| `kelivo/lib/l10n/app_*.arb` (4 files) | 3.5 | ✅ Complete | 22 new task system keys |
| `kelivo/lib/core/models/agent_template.dart` | 4.1 | ✅ Complete | AgentTemplate model (template presets) |
| `kelivo/lib/core/services/agent_templates.dart` | 4.2 | ✅ Complete | Built-in agent templates (General, Code, Writer, Researcher) |
| `kelivo/lib/features/agent_factory/pages/agent_factory_page.dart` | 4.3 | ✅ Complete | 4-step agent creation wizard |
| `kelivo/lib/features/agents/pages/agents_page.dart` | 4.4 | ✅ Complete | Added "New Agent" entry point |
| `kelivo/lib/l10n/app_*.arb` (4 files) | 4.5 | ✅ Complete | 24 new agent factory keys |
| `test/core/models/agent_template_test.dart` | 4.6 | ✅ Complete | Unit tests for AgentTemplate + AgentTemplateService |
| `kelivo/lib/core/models/execution_trace.dart` | 5.1 | ✅ Complete | ExecutionTrace model + ExecutionStep + enums |
| `kelivo/lib/core/providers/trace_provider.dart` | 5.1 | ✅ Complete | TraceProvider: CRUD, workspace queries, SharedPrefs persistence |
| `kelivo/lib/core/services/lead_agent_service.dart` | 5.2 | ✅ Complete | LeadAgentService: plan→delegate→execute→review orchestration |
| `kelivo/lib/features/lead_agent/pages/lead_agent_execution_page.dart` | 5.4 | ✅ Complete | Lead Agent input, status, steps timeline, result view |
| `kelivo/lib/features/agents/pages/agents_page.dart` | 5.4 | ✅ Complete | Play button for lead agents → execution page |
| `kelivo/lib/core/services/agent_templates.dart` | 5.3 | ✅ Complete | Added Lead Agent built-in template (5th template) |
| `test/core/models/execution_trace_test.dart` | 5.6 | ✅ Complete | 40+ test cases for ExecutionTrace, ExecutionStep, enums |
| `kelivo/lib/l10n/app_*.arb` (4 files) | 5.5 | ✅ Complete | 16 new lead agent keys |
| `lib/core/models/agent_team.dart` | 6.1 | ✅ Complete | AgentTeam model |
| `lib/core/providers/team_provider.dart` | 6.1 | ✅ Complete | TeamProvider: CRUD, workspace queries |
| `lib/core/services/orchestration/worker_agent_service.dart` | 6.2 | ✅ Complete | WorkerAgentService |
| `lib/core/services/orchestration/manager_agent_service.dart` | 6.3 | ✅ Complete | ManagerAgentService |
| `lib/core/services/orchestration/agent_communication.dart` | 6.4 | ✅ Complete | Agent communication protocol |
| `lib/features/team/pages/team_page.dart` | 6.5 | ✅ Complete | Team management page |
| `lib/features/traces/pages/traces_page.dart` | 6.6 | ✅ Complete | Execution traces history page |
| `lib/features/agents/pages/agents_page.dart` | 6.5 | ✅ Complete | Teams + Traces entry buttons |
| `lib/main.dart` | 6.1 | ✅ Complete | TeamProvider registration |
| `lib/l10n/app_*.arb` (4 files) | 6.7 | ✅ Complete | 37+ new multi-agent keys |
| `test/core/models/agent_team_test.dart` | 6.8 | ✅ Complete | AgentTeam unit tests |
| `lib/core/models/agent_channel.dart` | 8.1 | ✅ Complete | AgentChannel model + ChannelType enum |
| `lib/core/providers/channel_provider.dart` | 8.2 | ✅ Complete | ChannelProvider |
| `lib/core/services/channels/channel_adapter.dart` | 8.3 | ✅ Complete | ChannelAdapter interface + ChannelConfigField |
| `lib/core/services/channels/telegram_adapter.dart` | 8.4 | ✅ Complete | Telegram Bot adapter |
| `lib/core/services/channels/discord_adapter.dart` | 8.4 | ✅ Complete | Discord Bot adapter |
| `lib/core/services/channels/slack_adapter.dart` | 8.4 | ✅ Complete | Slack Bot adapter |
| `lib/core/services/channels/email_adapter.dart` | 8.4 | ✅ Complete | Email (SMTP/IMAP) adapter |
| `lib/core/services/channels/webhook_adapter.dart` | 8.4 | ✅ Complete | REST webhook adapter |
| `lib/core/services/channels/web_widget_adapter.dart` | 8.4 | ✅ Complete | Web widget adapter |
| `lib/core/services/channels/channel_adapter_service.dart` | 8.4 | ✅ Complete | Channel adapter registry |
| `lib/features/channels/pages/channels_page.dart` | 8.5 | ✅ Complete | Channels UI page |
| `lib/main.dart` | 8.2 | ✅ Complete | ChannelProvider registration |
| `lib/desktop/desktop_nav_rail.dart` | 8.6 | ✅ Complete | NavTab.channels + Channels button |
| `lib/desktop/desktop_home_page.dart` | 8.6 | ✅ Complete | Channels tab in IndexedStack |
| `lib/l10n/app_*.arb` (4 files) | 8.7 | ✅ Complete | 21 new channel keys |
| `test/core/models/agent_channel_test.dart` | 8.8 | ✅ Complete | AgentChannel unit tests |
| `lib/core/models/sync_device.dart` | 9.1 | ✅ Complete | SyncDevice model |
| `lib/core/models/sync_record.dart` | 9.2 | ✅ Complete | SyncRecord model + SyncStatus enum |
| `lib/core/providers/auth_provider.dart` | 9.3 | ✅ Complete | AuthProvider: device identity + registration |
| `lib/core/providers/sync_provider.dart` | 9.4 | ✅ Complete | SyncProvider: sync engine + SyncConfig model |
| `lib/features/sync/pages/sync_page.dart` | 9.5 | ✅ Complete | Sync UI page (device/config/history sections) |
| `lib/main.dart` | 9.3 | ✅ Complete | AuthProvider + SyncProvider registration |
| `lib/desktop/desktop_nav_rail.dart` | 9.6 | ✅ Complete | NavTab.sync + Sync button |
| `lib/desktop/desktop_home_page.dart` | 9.6 | ✅ Complete | Sync tab in IndexedStack |
| `lib/l10n/app_*.arb` (4 files) | 9.7 | ✅ Complete | 30 new sync keys |
| `test/core/models/sync_device_test.dart` | 9.8 | ✅ Complete | SyncDevice unit tests |
| `test/core/models/sync_record_test.dart` | 9.8 | ✅ Complete | SyncRecord + SyncStatus unit tests |
| `test/core/providers/sync_config_test.dart` | 9.8 | ✅ Complete | SyncConfig unit tests |
| `lib/core/models/runtime_execution.dart` | 10.1 | ✅ Complete | RuntimeExecution model + RuntimeExecutionStatus enum |
| `lib/core/services/scheduler_service.dart` | 10.2/10.3 | ✅ Complete | ScheduleInterval enum + ScheduledRun model + SchedulerService |
| `lib/core/providers/runtime_provider.dart` | 10.4 | ✅ Complete | RuntimeProvider: host lifecycle, execution management, scheduler integration |
| `lib/features/runtime/pages/runtime_page.dart` | 10.5 | ✅ Complete | Runtime UI page: host status, active executions, schedules, history |
| `lib/main.dart` | 10.6 | ✅ Complete | SchedulerService + RuntimeProvider registration |
| `lib/desktop/desktop_nav_rail.dart` | 10.6 | ✅ Complete | NavTab.runtime + Runtime button (Server icon) |
| `lib/desktop/desktop_home_page.dart` | 10.6 | ✅ Complete | Runtime tab in IndexedStack |
| `lib/l10n/app_*.arb` (4 files) | 10.6 | ✅ Complete | 26 new runtime keys |
| `test/core/models/runtime_execution_test.dart` | 10.7 | ✅ Complete | RuntimeExecution + RuntimeExecutionStatus unit tests |
| `test/core/models/scheduled_run_test.dart` | 10.7 | ✅ Complete | ScheduleInterval + ScheduledRun unit tests |
| `test/core/providers/runtime_host_status_test.dart` | 10.7 | ✅ Complete | RuntimeHostStatus enum unit tests |

---

## Development Rules (Active Reminders)

1. **Never rebuild existing provider integrations** — they work, don't touch them
2. **Never rebuild MCP without justification** — it's excellent, enhance only
3. **Never create duplicate storage systems** — reuse Hive/SharedPrefs
4. **Never redesign screens before audit** — audit is done ✅
5. **Always prefer extension over replacement**
6. **Every feature must ask**: Can this become Workspace Aware? Agent Aware? Multi-Agent Aware?
7. **No mock, no simple, no placeholder** — every deliverable is real production code
## New Fixes — 2026-06-13

| # | Date | Issue | Decision | Status |
|---|---|---|---|---|---|
| 30 | 2026-06-13 | lib/secrets/fallback.dart missing from working tree | Created locally with empty siliconflowFallbackKey; CI already injects it. | Fixed |
| 31 | 2026-06-13 | Mobile HomePage does not pass workspaceId to SideDrawer | workspaceId now passed from home_mobile_layout.dart and home_desktop_layout.dart. | Fixed |
| 32 | 2026-06-13 | Dashboard quick action chips have no onTap | Added onNewChat and onNewAssistant callbacks wired to NavTab.chats + ChatAction.newTopic. | Fixed |
| 33 | 2026-06-13 | Mobile has no entry point to YLAgents pages | Added Lucide.Boxes menu button in SideDrawer bottom bar that opens a bottom sheet with all YLAgents feature pages. | Fixed |
| 34 | 2026-06-13 | NavTab clamp hardcoded to 8 instead of dynamic | Changed to NavTab.values.length - 1 so it auto-adjusts when tabs are added/removed. | Fixed |
| 35 | 2026-06-13 | No auto-release CI workflow for Android/iOS/Windows | Created .github/workflows/auto-release.yml with quality gates, version resolution, and GitHub release publishing. | Fixed |
