# YLAGENTS_PRD.md

# YLAgents

Local-First AI Workforce Operating System

Built by evolving the Kelivo codebase into a workspace-first, multi-agent platform.

---

# Product Mission

Transform Kelivo from a personal AI chat application into a local-first AI workforce platform capable of:

* Creating agents
* Managing agents
* Orchestrating agent teams
* Managing knowledge
* Managing tasks
* Connecting tools through MCP
* Deploying bot channels
* Running locally
* Synchronizing optionally

without requiring users to operate cloud infrastructure.

---

# Core Principle

Migration First.

Before implementing any feature:

1. Audit Existing
2. Reuse Existing
3. Enhance Existing
4. Replace Only When Necessary
5. Create Only When Missing

The objective is evolution, not rewrite.

---

# Existing Kelivo Assets

Expected Reuse Areas:

* Provider integrations
* MCP integrations
* Chat infrastructure
* Streaming
* Markdown rendering
* Attachments
* Voice
* Search
* Settings
* Themes
* Backup systems
* Local storage

These should be audited first.

---

# Product Philosophy

Workspace First

Not Chat First.

Current:

User → Chat → Assistant

Target:

Workspace
├─ Agents
├─ Tasks
├─ Knowledge
├─ Channels
├─ MCP
├─ Skills
└─ Chats

---

# User Types

Personal User

* Personal assistants
* Research
* Coding
* Daily productivity

Power User

* Multiple workspaces
* Automation
* Knowledge management

Business User

* Teams
* Shared knowledge
* Shared agents

Developer

* MCP
* Skills
* Agent templates

---

# Agent Architecture

Lead Agent

Responsibilities:

* Planning
* Delegation
* Review
* Orchestration

Manager Agent

Responsibilities:

* Team coordination
* Workflow supervision

Worker Agent

Responsibilities:

* Specialized execution

Worker agents should not communicate directly.

All communication flows through Lead Agent.

---

# Agent Genome

Every agent contains:

Identity
Soul
Role
Goals
Memory
Knowledge
Tools
Skills
Policies
Schedules
Channels

Advanced users may edit these directly.

Standard users use visual builders.

---

# Workspace Architecture

Workspace owns:

Agents
Chats
Tasks
Knowledge
Files
Skills
Channels
MCP Configurations
Memory
Settings

Workspace becomes the primary organizational unit.

---

# Agent Factory

Visual Builder

Capabilities:

* Create Agent
* Configure Identity
* Configure Role
* Configure Soul
* Configure Goals
* Attach Knowledge
* Select Tools
* Select MCP
* Configure Channels
* Configure Schedules

No markdown editing required.

Advanced mode available.

---

# Multi-Agent Orchestration

Capabilities:

* Agent hierarchy
* Delegation
* Task routing
* Execution tracing
* Approval checkpoints
* Shared workspace memory

---

# MCP Architecture

Reuse Kelivo MCP implementation.

Enhancements:

* MCP Profiles
* MCP Templates
* MCP Marketplace
* Agent Permissions
* Workspace MCP Management

Never replace MCP without audit findings.

---

# Skills System

Portable capabilities.

Skill contains:

Prompts
Workflows
Assets
Configurations

Install Sources:

Marketplace
Git Repository
Local File

---

# Memory Architecture

Working Memory

Current task context.

Session Memory

Conversation context.

Long-Term Memory

Persistent information.

Knowledge Memory

Imported documents.

Workspace Memory

Shared knowledge.

Agent Memory

Private knowledge.

---

# Bot Channels

Supported:

Telegram
Discord
Slack
Email
REST
Web Widget

Future:

WhatsApp
Teams

---

# Transport Modes

Local Gateway

Default.

No server required.

Local Agent Hub

Background service.

Server Relay

Optional infrastructure.

Hybrid

Delivery via server.
Execution via local runtime.

---

# Scheduling

Schedules belong to active runtime instances.

If no runtime exists:

Tasks remain pending.

No cloud execution occurs automatically.

---

# Runtime Philosophy

Runtime = Intelligence

Server = Infrastructure

The server must not become the source of intelligence.

---

# Minimal Server Mode

Responsibilities:

Authentication
Device Registration
Sync
Backup
Relay
Push Notifications

Not Responsible For:

Agent Execution
Workflow Execution
MCP Execution
Schedules
Automation

---

# Runtime Host Mode

Optional future capability.

Examples:

NAS
Mini PC
Docker
Raspberry Pi
VPS

Provides:

24/7 automation
Bot execution
Schedules
Workflows

Uses same application logic.

---

# Security

Every action passes through policy validation.

Checks:

Permissions
Tool Access
Network Access
Secrets
Workspace Boundaries

Modes:

Disabled
Read Only
Approval Required
Autonomous

---

# Storage

Reuse Kelivo storage.

Extend.

Avoid parallel storage systems.

Workspace aware.

Agent aware.

Multi-agent aware.

---

# Success Criteria

Phase 1

Kelivo functionality preserved.

Phase 2

Agent architecture introduced.

Phase 3

Agent Factory operational.

Phase 4

Multi-agent orchestration operational.

Phase 5

Bot channels operational.

Phase 6

Workspace-first UX operational.

Phase 7

Skills ecosystem operational.

Phase 8

Sync infrastructure operational.

Phase 9

Runtime host operational.
