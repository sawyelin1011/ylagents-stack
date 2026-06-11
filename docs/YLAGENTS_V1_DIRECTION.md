YLAgents v1 Final Product Direction
What YLAgents Actually Is

YLAgents is not:

Another AI Chat App
Another AI Assistant App
Another Prompt Manager
Another MCP Client

YLAgents is:

A Local-First Workspace-Centric AI Workforce Operating System built by evolving Kelivo.

Foundation

Base Project:

Kelivo

Migration Strategy:

Audit
→ Reuse
→ Enhance
→ Replace if Required
→ Create if Missing

Never rewrite working Kelivo systems.

What Kelivo Already Solves

Keep and Extend:

AI Providers
OpenAI
Anthropic
Gemini
OpenRouter
Ollama
Existing providers
MCP
Existing MCP client
Existing MCP execution
Chat
Streaming
Markdown
Attachments
Code rendering
Knowledge
World Books
Files
Search
Storage
Existing database
Existing local storage
Backup
Existing export/import
UI
Existing navigation patterns
Existing design system
Core Product Model

Everything revolves around Workspaces.

User

└── Workspace

     ├── Tasks
     ├── Agents
     ├── Knowledge
     ├── Files
     ├── MCP
     ├── Skills
     ├── Channels
     ├── Chats
     └── Settings

Workspace becomes the primary entity.

Not Agent.

Not Chat.

Workspace Types
Personal
Personal AI workforce
Project
Software project
Client
Client-specific environment
Team

Future.

Task-Centric Workflow

Instead of:

User
↓
Chat

Use:

User
↓
Task
↓
Agent
↓
Result

Tasks become first-class entities.

Task Model

Task:

Title
Goal
Context
Files
Knowledge
Assigned Agent
Status
History
Results

Statuses:

Pending
Running
Waiting
Blocked
Completed
Failed
Cancelled
Agent Model

Assistant becomes Agent.

Agent contains:

Identity
Role
Goals
Instructions
Knowledge
Memory
Tools
Skills
Policies
Channels
Schedules
Agent Types
Standard Agent

Single execution.

Lead Agent

Planning.

Delegation.

Review.

Worker Agent

Specialized execution.

Agent Team

Future.

Agent Communication Rules

Workers never directly communicate.

Flow:

User
↓
Lead Agent
↓
Worker Agent
↓
Lead Agent
↓
User

Simplifies orchestration.

Agent Factory

Most important feature.

Visual builder.

No markdown required.

Steps:

Identity
↓
Role
↓
Knowledge
↓
Tools
↓
Policies
↓
Channels
↓
Test

Advanced mode available.

Knowledge System

Reuse Kelivo.

Knowledge Sources:

Files
PDFs
Images
URLs
World Books
Collections
Notes

Attach to:

Workspace
Agent
Task
MCP Strategy

Do not create another tool system.

Reuse MCP.

Enhance with:

Profiles
Bundles
Templates
Marketplace
Permissions
Skills System

Skills are reusable capabilities.

Skill contains:

Prompts
Policies
Workflows
Knowledge Links
MCP Profiles
Templates

Examples:

Research
Code Review
Customer Support
SEO
Marketing
Memory System
Working Memory

Current task.

Session Memory

Current conversation.

Agent Memory

Agent-specific.

Workspace Memory

Shared workspace.

Knowledge Memory

Imported content.

Channels

Phase Later.

Supported:

Telegram
Discord
Slack
Email
REST
Web Widget
Transport Modes
Local Gateway

Default.

No server.

Local Agent Hub

Future.

Server Relay

Future.

Hybrid

Future.

Scheduling

Schedules belong to runtime.

Examples:

Daily
Weekly
Monthly
Cron

Execution requires active runtime.

No runtime:

Task waits.
Runtime Philosophy
Runtime = Intelligence

Server = Infrastructure

Never mix them.

Sync Server

Very late phase.

Responsibilities:

Authentication
Device Registration
Workspace Sync
Backup
Relay
Notifications

Never:

Execute Agents
Execute Workflows
Execute MCP
Run Schedules
Runtime Host

Optional future.

Examples:

Docker
NAS
Mini PC
Raspberry Pi
VPS

Provides:

24/7 Automation
Bots
Schedules
Workflows
Security

Every action:

Request
↓
Policy Check
↓
Permission Check
↓
Execute

Modes:

Disabled
Read Only
Approval Required
Autonomous
UI Direction

Not ChatGPT.

Not Claude.

Closer to:

Cursor
Manus
Linear

Workspace-first.

Navigation

Desktop

Workspace

├ Dashboard
├ Tasks
├ Agents
├ Knowledge
├ MCP
├ Skills
├ Channels
├ Chats
└ Settings

Mobile

Dashboard
Tasks
Agents
Chats
More
Development Roadmap
Phase 0

Kelivo Audit

Phase 0.5

UX Audit

Phase 1

Workspace Foundation

Phase 2

Assistant → Agent

Phase 3

Task System

Phase 4

Agent Factory

Phase 5

Lead Agent

Phase 6

Multi-Agent

Phase 7

Skills System

Phase 8

Channels

Phase 9

Sync Server

Phase 10

Runtime Host

Success Criteria

V1 Success:

Workspace
Tasks
Agents
Agent Factory
Lead Agent

while preserving:

Providers
MCP
Storage
Search
Backup
Chat
Streaming

from Kelivo.