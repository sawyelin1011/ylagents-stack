# YLAGENTS_PHASE0_PLAN.md

## Phase 0 — Repository Audit & UX Audit

Based on: CURRENT_STATE.md audit findings
Product Direction Reference: user_prompt-1781191163108.md

---

## Golden Rule Applied

Every task is classified:

| Tag | Meaning |
|---|---|
| **[KEEP]** | Reuse as-is, no changes needed |
| **[ENHANCE]** | Extend existing code with workspace/agent awareness |
| **[MIGRATE]** | Move/adapt code to new location or storage |
| **[REPLACE]** | Build new from scratch (feature doesn't exist) |
| **[REMOVE]** | Delete obsolete code |

Plus priority and effort estimates.

---

## Phase 0 — Repository Audit (COMPLETE)

### Output: CURRENT_STATE.md ✅

The full architectural audit has been completed. See `CURRENT_STATE.md` for:
- Directory architecture mapping
- State management dependency graph
- Data model inventory
- MCP architecture analysis
- Chat/generation flow analysis
- Storage architecture
- Navigation structure
- Audit classification (KEEP/ENHANCE/MIGRATE/REPLACE/REMOVE)
- Critical architecture decisions

---

## YLAgents Product Vision (From Latest Direction)

### What YLAgents Is

**A Local-First Workspace-Centric AI Workforce Operating System** built by evolving Kelivo.

### What YLAgents Is NOT

- Another AI Chat App
- Another AI Assistant App
- Another Prompt Manager
- Another MCP Client

### Core Product Model

```
User
│
└── Workspace (Personal | Project | Client)
     │
     ├── Tasks (first-class entities)
     ├── Agents (evolved Assistants)
     ├── Knowledge (files, PDFs, URLs, World Books)
     ├── Files
     ├── MCP (profiles, bundles, templates)
     ├── Skills (reusable capabilities)
     ├── Channels (Telegram, Discord, Slack, Email)
     ├── Chats (conversations)
     └── Settings (workspace-scoped)
```

### Task-Centric Workflow

```
User → Task → Agent → Result
```

Not:
```
User → Chat
```

### Agent Types

- **Standard Agent** — single execution
- **Lead Agent** — planning, delegation, review
- **Worker Agent** — specialized execution
- **Agent Team** (future) — multi-agent collaboration

Workers never directly communicate. All flow goes through Lead Agent.

### UI Direction

Not ChatGPT. Not Claude. Closer to **Cursor, Manus, Linear** — workspace-first, task-driven.

### Target Navigation

```
Desktop Nav:
Workspace
├── Dashboard   ← default view
├── Tasks
├── Agents
├── Knowledge
├── MCP
├── Skills
├── Channels
├── Chats
└── Settings
```

---

## Phase 0.5 — UX Audit Tasks

### Task 0.5.1: Map Current Navigation & UX

| | |
|---|---|
| **Classification** | **[KEEP]** + document |
| **Priority** | Critical |
| **Effort** | Small |

**Description:**
Document the current UX flow across all screens to identify what changes.

**Current UX Flow:**
```
Desktop:
  Nav Rail [Chat | Search | Translate | Storage | Settings]
    └─ Chat tab: SideDrawer (Assistant list + Conversation list) → Message area
    └─ Settings: Providers → Models → MCP → Display → Backup → etc.

Mobile:
  Scaffold Drawer (Assistant + Conversations) → Chat page
```

**Key UX observations:**
1. Chat-first — no dashboard, no workspace
2. Assistants are secondary (sidebar), not primary nav
3. No task management anywhere
4. Settings is monolithic, no workspace/agent separation
5. MCP management buried in Settings
6. No knowledge management UI (World Books are the closest)
7. No concept of agent types (lead/worker) or teams

**Files to analyze:**
- `lib/desktop/desktop_home_page.dart`
- `lib/desktop/desktop_nav_rail.dart`
- `lib/desktop/desktop_chat_page.dart`
- `lib/features/home/widgets/side_drawer.dart`
- `lib/features/home/pages/home_page.dart`
- `lib/features/assistant/pages/assistant_settings_page.dart`
- `lib/desktop/setting/assistants_pane.dart`

---

### Task 0.5.2: Workspace-First Navigation Proposal

| | |
|---|---|
| **Classification** | **[REPLACE]** — New concept |
| **Priority** | Critical |
| **Effort** | Medium |

**Description:**
Design the workspace-first navigation structure following the Cursor/Manus/Linear direction.

**Proposed Desktop Nav Rail:**
```
[A vatar] [Dashboard] [Tasks] [Agents] [Knowledge] [MCP] [Chats] [Settings]
```

**Workspace selector (top-left of sidebar):**
```
[Current Workspace: "Personal" ▼]
├── Personal
├── Project: ylagents
├── Client: Acme
└── + New Workspace
```

**Sidebar per workspace tab:**

| Tab | Sidebar Content |
|---|---|
| **Dashboard** | Workspace stats, recent tasks, active agents, quick actions |
| **Tasks** | Task list (kanban/table) filtered by workspace |
| **Agents** | Agent list in workspace, agent cards, Create Agent button |
| **Knowledge** | Knowledge sources in workspace (files, URLs, World Books) |
| **MCP** | MCP profiles & servers in workspace |
| **Chats** | Conversations filtered by workspace → agent |
| **Skills** | Available skill packs |
| **Channels** | Bot channel configs |
| **Settings** | Workspace settings (name, type, members) |

**Key UX Principles:**
1. **Dashboard is default view** — not chat. Shows workspace overview
2. **Tasks are first-class** — kanban/table, assignable to agents
3. **Agents are primary entities** — listed with type badges (Lead, Worker)
4. **Chats are secondary** — accessible but not the main interaction model
5. **Workspace context** — everything filtered by active workspace
6. **Settings split** — global settings (providers, theme, backup) vs workspace settings

---

### Task 0.5.3: Agent Factory UX Proposal

| | |
|---|---|
| **Classification** | **[REPLACE]** — New concept |
| **Priority** | High |
| **Effort** | Large |

**Description:**
Design the visual agent builder (Agent Factory) following the new direction.

**Agent Factory Steps (wizard flow):**
```
1. Identity     → Name, avatar, description, personality
2. Role         → Standard | Lead Agent | Worker Agent
3. Knowledge    → Attach knowledge bases, files, URLs, World Books
4. Tools        → Select MCP profiles, enable/disable tools
5. Policies     → Permissions (Disabled, Read Only, Approval Required, Autonomous)
6. Channels     → Configure bot channels (Telegram, Discord, Slack, Email)
7. Test         → Chat preview sandbox, test execution
```

**Agent Model (from PRD):**
```
Agent:
├── Identity   (name, avatar, description)
├── Role       (standard, lead, worker)
├── Goals      (what the agent aims to accomplish)
├── Instructions (system prompt — evolved from Assistant)
├── Knowledge  (attached knowledge bases)
├── Memory     (working, session, agent, workspace)
├── Tools      (MCP servers + local tools)
├── Skills     (reusable capabilities)
├── Policies   (permission modes)
├── Channels   (bot channel configs)
├── Schedules  (daily, weekly, monthly, cron)
```

**Visual Builder Layout:**
- Step-by-step wizard for beginners (7 steps)
- Tab-based editor for power users (reuse `AssistantSettingsPage` tab pattern)
- "Advanced Mode" toggle for raw genome JSON editing
- Testing sandbox: preview agent behavior before saving

**Reuse from existing `AssistantSettingsPage`:**
- `AssistantSettingsEditBasicTab` → Identity tab
- `AssistantSettingsEditPromptTab` → Instructions tab
- `AssistantSettingsEditMemoryTab` → Memory tab
- `AssistantSettingsEditMCPTab` → Tools / MCP tab
- `AssistantSettingsEditLocalToolsTab` → Built-in tools
- `AssistantRegexTab` → Regex rules (keep)
- New: Role selector, Goals editor, Policies, Channels, Schedules

---

### Task 0.5.4: Task System UX Proposal

| | |
|---|---|
| **Classification** | **[REPLACE]** — New concept |
| **Priority** | High |
| **Effort** | Medium |

**Description:**
Design the task system UX following the task-centric workflow (User → Task → Agent → Result).

**Task Model:**
```
Task:
├── Title
├── Goal (description of desired outcome)
├── Context (additional background info)
├── Files (attachments)
├── Knowledge (attached knowledge sources)
├── Assigned Agent (agent ID or agent team)
├── Status (Pending | Running | Waiting | Blocked | Completed | Failed | Cancelled)
├── History (event log)
└── Results (output / artifacts)
```

**Task Dashboard UI:**
```
┌─────────────────────────────────────────────────────┐
│ Tasks                          [+ New Task] [Filter] │
├─────────────────────────────────────────────────────┤
│ ┌───────────┐ ┌──────────┐ ┌─────────┐ ┌─────────┐│
│ │  Pending  │ │ Running  │ │ Blocked │ │Completed││
│ │ Task A    │ │ Task C   │ │ Task D  │ │ Task B  ││
│ │ Task E    │ │          │ │         │ │ Task F  ││
│ └───────────┘ └──────────┘ └─────────┘ └─────────┘│
└─────────────────────────────────────────────────────┘
```

**Task Detail View:**
```
┌─────────────────────────────────────────────────┐
│ [← Back] Task: "Research competitor pricing"     │
│ Status: Running  |  Assigned: Lead Agent         │
├─────────────────────────────────────────────────┤
│ Goal: Analyze competitor pricing strategies...   │
│ Context: We're launching product X next quarter  │
│ Files: competitors.csv, pricing_data.pdf         │
│ Knowledge: market_research_kb                    │
├─────────────────────────────────────────────────┤
│ History                                           │
│ 10:30 — Task created                              │
│ 10:31 — Assigned to Lead Agent                    │
│ 10:32 — Lead Agent delegated research to Worker 1 │
│ 10:35 — Worker 1 completed initial analysis       │
│ ...                                               │
├─────────────────────────────────────────────────┤
│ Results                                           │
│ [View Report] [Download Artifacts]                │
└─────────────────────────────────────────────────┘
```

**Task Creation Flow:**
```
1. User defines: Title + Goal + Context
2. Optionally: attach files, knowledge, assign agent
3. User submits → task created with status "Pending"
4. Assigned agent picks up task → status "Running"
5. Agent processes → produces results
6. Status updates through lifecycle
```

---

### Task 0.5.5: Navigation Implementation Plan

| | |
|---|---|
| **Classification** | **[ENHANCE]** + **[REPLACE]** |
| **Priority** | Critical |
| **Effort** | Large |

**Description:**
Plan the complete navigation refactoring from chat-first to workspace-first with dashboard.

**Implementation Approach:**

1. **Create WorkspaceProvider** — new ChangeNotifier
   - Current workspace ID
   - Workspace CRUD (create, rename, delete)
   - Workspace list persistence (Hive or SharedPreferences)
   - Workspace type (Personal, Project, Client)

2. **Create Workspace model:**
   - `id`, `name`, `type` (Personal/Project/Client), `createdAt`, `updatedAt`
   - `description`
   - Persistence: Hive box `workspaces`

3. **Add workspaceId to existing models:**
   - `Conversation.workspaceId` (new Hive field)
   - `Assistant.workspaceId` (new JSON field)
   - Future: `Task.workspaceId`, `Knowledge.workspaceId`

4. **Redesign DesktopNavRail:**
   - Remove: Search, Translate, Storage (move to secondary)
   - Add: Dashboard, Tasks, Agents, Knowledge
   - Keep: Chats, Settings
   - Compact rail with icons + tooltips

5. **Create DashboardPage:**
   - Workspace overview (stats, recent tasks, active agents)
   - Quick action buttons (New Task, New Agent, New Chat)
   - Recent activity feed

6. **Create TasksPage:**
   - Task list with status columns (kanban)
   - Task detail view
   - Task creation dialog

7. **Create AgentsPage:**
   - Agent list in workspace
   - Agent cards with type badges
   - Agent Factory entry point

8. **Create KnowledgePage:**
   - List of knowledge sources
   - File upload, URL import, World Book integration

9. **Modify SideDrawer to be context-aware:**
   - Different sidebar content per tab
   - Filter conversations/agents by current workspace

10. **Migration Strategy:**
    - Auto-create "Personal" workspace on first launch
    - Migrate all existing assistants → agents in "Personal" workspace
    - Migrate all existing conversations → "Personal" workspace chats
    - Backward compatible: no data loss

---

### Task 0.5.6: Settings Restructuring Plan

| | |
|---|---|
| **Classification** | **[ENHANCE]** / **[MIGRATE]** |
| **Priority** | Medium |
| **Effort** | Medium |

**Description:**
Plan the settings split into three tiers.

**Three-Tier Settings:**
```
Global Settings (SettingsProvider — KEEP & SHRINK):
├── Providers & Models (API keys, provider configs)
├── Display & Theme (colors, fonts, dynamic color)
├── Network & Proxy
├── Backup & Sync (WebDAV, S3)
├── Hotkeys
├── About & Updates
└── Data Management

Workspace Settings (new — WorkspaceSettingsProvider):
├── Workspace Name & Description
├── Workspace Type (Personal/Project/Client)
├── MCP Profiles (sets of MCP servers)
├── Knowledge Bases
├── Shared Memory
└── Members (future)

Agent Settings (extend AssistantProvider):
├── Identity (name, avatar, description, soul)
├── Role (standard, lead, worker)
├── Goals
├── Instructions (system prompt — evolved)
├── Tools & MCP
├── Memory (working, session, agent memories)
├── Skills
├── Policies (permission mode)
├── Channels (bot channel configs)
├── Schedules (cron, daily, weekly)
└── Regex Rules (keep existing)
```

**Implementation:**
- `SettingsProvider` stays for global settings but remove workspace/agent configs
- New `WorkspaceSettingsProvider` wraps workspace-level config
- `AssistantProvider` extended with genome fields
- New `WorkspaceProvider` handles workspace CRUD
- Settings navigation restructured: "Global Settings" vs "{Workspace} Settings"

---

## V1 Success Criteria

From the product direction, V1 requires:

- [x] **Phase 0** — Audit COMPLETE
- [ ] **Phase 0.5** — UX Audit
- [ ] **Phase 1** — Workspace Foundation
- [ ] **Phase 2** — Assistant → Agent
- [ ] **Phase 3** — Task System
- [ ] **Phase 4** — Agent Factory
- [ ] **Phase 5** — Lead Agent

While preserving from Kelivo:
- [x] Providers
- [x] MCP
- [x] Storage
- [x] Search
- [x] Backup
- [x] Chat
- [x] Streaming

---

## Phase 0.5 — Task Summary

| # | Task | Classification | Priority | Effort | Status |
|---|---|---|---|---|---|
| 0.1 | Repository Architecture Audit | **[KEEP]** | Critical | Medium | ✅ Complete |
| 0.2 | Map Current Navigation & UX | **[KEEP]** | Critical | Small | ⬜ Pending |
| 0.3 | Workspace-First Navigation Proposal | **[REPLACE]** | Critical | Medium | ⬜ Pending |
| 0.4 | Agent Factory UX Proposal | **[REPLACE]** | High | Large | ⬜ Pending |
| 0.5 | Task System UX Proposal | **[REPLACE]** | High | Medium | ⬜ Pending |
| 0.6 | Navigation Implementation Plan | **[ENHANCE]+[REPLACE]** | Critical | Large | ⬜ Pending |
| 0.7 | Settings Restructuring Plan | **[ENHANCE]/[MIGRATE]** | Medium | Medium | ⬜ Pending |

---

## Full 10-Phase Roadmap

| Phase | Feature | Depends On |
|---|---|---|
| **0** | Kelivo Audit | — |
| **0.5** | UX Audit | Phase 0 |
| **1** | Workspace Foundation | Phase 0.5 |
| **2** | Assistant → Agent | Phase 1 |
| **3** | Task System | Phase 2 |
| **4** | Agent Factory | Phase 3 |
| **5** | Lead Agent | Phase 4 |
| **6** | Multi-Agent | Phase 5 |
| **7** | Skills System | Phase 6 |
| **8** | Channels | Phase 7 |
| **9** | Sync Server | Phase 8 |
| **10** | Runtime Host | Phase 9 |

---

## Phase 1 — Workspace Foundation (Detailed)

After Phase 0.5 approval:

| # | Task | Classification | Priority | Effort |
|---|---|---|---|---|
| 1.1 | Create Workspace model + WorkspaceProvider | **[REPLACE]** | Critical | Medium |
| 1.2 | Add workspaceId to Conversation + Assistant | **[ENHANCE]** | Critical | Small |
| 1.3 | Auto-create "Personal" workspace with data migration | **[MIGRATE]** | Critical | Small |
| 1.4 | Redesign DesktopNavRail (Dashboard, Tasks, Agents, Knowledge, Chats, Settings) | **[ENHANCE]+[REPLACE]** | Critical | Medium |
| 1.5 | Create DashboardPage (workspace overview, stats, quick actions) | **[REPLACE]** | Critical | Medium |
| 1.6 | Workspace-aware Sidebar (context-sensitive content per tab) | **[ENHANCE]+[REPLACE]** | High | Large |
| 1.7 | Workspace selector (dropdown/popover in sidebar header) | **[REPLACE]** | High | Small |
| 1.8 | Split SettingsProvider (extract workspace/agent settings) | **[ENHANCE]/[MIGRATE]** | Medium | Medium |
| 1.9 | Verification — existing Kelivo functionality preserved | **[KEEP]** | Critical | Small |

---

## Pre-Implementation Checklist

Before starting any implementation:

- [ ] Phase 0.5 UX proposals approved (Navigation, Agent Factory, Task System)
- [ ] Workspace model design finalized
- [ ] Navigation wireframes approved (dashboard-first)
- [ ] Settings split plan approved
- [ ] Task model design finalized
- [ ] Agent model extension plan approved
- [ ] V1 scope confirmed (Workspace + Tasks + Agents + Agent Factory + Lead Agent)