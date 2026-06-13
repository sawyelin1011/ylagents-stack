# Kelivo Mobile Testing Checklist

> Manual testing checklist for Android APK. Test each item on your device and mark ✅ or ❌.

---

## 1. App Launch & Basic UI

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 1.1 | App opens without crash | [ ] | |
| 1.2 | Splash screen shows then goes to home | [ ] | |
| 1.3 | Side drawer opens from left | [ ] | |
| 1.4 | YLAgents grid menu opens from bottom bar | [ ] | |
| 1.5 | Can switch between light/dark theme in Settings | [ ] | |

---

## 2. Chat (Core Feature)

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 2.1 | Can type and send a message | [ ] | |
| 2.2 | AI responds (or shows error if no API key) | [ ] | |
| 2.3 | Can create a new conversation | [ ] | |
| 2.4 | Can delete a conversation | [ ] | |
| 2.5 | Long-press on message shows options (copy, delete) | [ ] | |
| 2.6 | Can attach image from gallery | [ ] | |
| 2.7 | Settings page shows model provider list | [ ] | |

---

## 3. Dashboard

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 3.1 | Dashboard page loads | [ ] | |
| 3.2 | Quick action "New Chat" works | [ ] | |
| 3.3 | Quick action "New Assistant" works | [ ] | |
| 3.4 | Shows recent activity / stats | [ ] | |

---

## 4. Workspaces

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 4.1 | Can create a new workspace | [ ] | |
| 4.2 | Can switch between workspaces | [ ] | |
| 4.3 | Data is scoped to workspace (agents, chats, tasks) | [ ] | |

---

## 5. Agents

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 5.1 | Agents list page loads | [ ] | |
| 5.2 | Can create a new agent | [ ] | |
| 5.3 | Can edit an existing agent | [ ] | |
| 5.4 | Can delete an agent | [ ] | |
| 5.5 | Agent type "Standard" works | [ ] | |
| 5.6 | Agent type "Worker" works | [ ] | |
| 5.7 | Agent type "Lead" works | [ ] | |

---

## 6. Agent Factory (Visual Builder)

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 6.1 | Agent Factory page opens | [ ] | |
| 6.2 | Can build agent step-by-step | [ ] | |
| 6.3 | Can save the created agent | [ ] | |

---

## 7. Tasks

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 7.1 | Tasks page loads | [ ] | |
| 7.2 | Can create a new task | [ ] | |
| 7.3 | Can mark task as completed | [ ] | |
| 7.4 | Task shows status correctly | [ ] | |

---

## 8. Knowledge Base

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 8.1 | Knowledge page loads | [ ] | |
| 8.2 | Can add knowledge entry | [ ] | |
| 8.3 | Can search knowledge | [ ] | |

---

## 9. Team Management

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 9.1 | Team page loads | [ ] | |
| 9.2 | Can create a team | [ ] | |
| 9.3 | Can assign lead agent | [ ] | |
| 9.4 | Can add/remove members | [ ] | |

---

## 10. Lead Agent

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 10.1 | Lead Agent page loads | [ ] | |
| 10.2 | Can enter a request and execute | [ ] | |
| 10.3 | Execution trace shows steps | [ ] | |

---

## 11. Channels (Bot Adapters)

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 11.1 | Channels page loads | [ ] | |
| 11.2 | Can add Telegram channel config | [ ] | |
| 11.3 | Can add Discord channel config | [ ] | |
| 11.4 | Can add Slack channel config | [ ] | |
| 11.5 | Can add Web Widget channel | [ ] | |

---

## 12. Sync

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 12.1 | Sync page loads | [ ] | |
| 12.2 | Shows device info | [ ] | |
| 12.3 | Shows sync status | [ ] | |

---

## 13. Runtime Host

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 13.1 | Runtime page loads | [ ] | |
| 13.2 | Can toggle host start/stop | [ ] | |
| 13.3 | Shows execution history | [ ] | |

---

## 14. Execution Traces

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 14.1 | Traces page loads | [ ] | |
| 14.2 | Shows past execution traces | [ ] | |

---

## 15. Settings

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 15.1 | All settings categories load | [ ] | |
| 15.2 | Language can be changed | [ ] | |
| 15.3 | Model provider settings load | [ ] | |
| 15.4 | Backup/restore options show | [ ] | |

---

## 16. Localization

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 16.1 | English text shows correctly everywhere | [ ] | |
| 16.2 | Chinese text shows correctly (if switched) | [ ] | |
| 16.3 | No hardcoded text visible to user | [ ] | |

---

## 17. Navigation & Drawer

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 17.1 | Mobile side drawer shows all YLAgents pages | [ ] | |
| 17.2 | Bottom navigation works | [ ] | |
| 17.3 | Back button works correctly | [ ] | |
| 17.4 | No blank/white screens | [ ] | |

---

## How to Report

Reply with results like this:

```
2.1 ✅
2.2 ❌ - AI shows loading spinner forever, no response
5.3 ✅
11.1 ❌ - Channels page shows blank white screen
```

I will fix any ❌ items you report.
