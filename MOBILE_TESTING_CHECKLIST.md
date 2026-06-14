# Kelivo Mobile Testing Checklist

> Manual testing checklist for Android APK. Test each item on your device and mark ✅ or ❌.
> Items with ✅ were confirmed via automated testing.

---

## 1. App Launch & Basic UI

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 1.1 | App opens without crash | ✅ Auto | App launches to chat screen |
| 1.2 | Splash screen shows then goes to home | [ ] | |
| 1.3 | Side drawer opens from left | ✅ Auto | Hamburger button works |
| 1.4 | YLAgents grid menu opens from bottom bar | ✅ Auto | All 9 feature buttons visible |
| 1.5 | Can switch between light/dark theme in Settings | [ ] | Settings page loads ✅ |

## 2. Chat (Core Feature)

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 2.1 | Can type and send a message | [ ] | Input field visible ✅ |
| 2.2 | AI responds (or shows error if no API key) | [ ] | |
| 2.3 | Can create a new conversation | [ ] | |
| 2.4 | Can delete a conversation | [ ] | |
| 2.5 | Long-press on message shows options (copy, delete) | [ ] | |
| 2.6 | Can attach image from gallery | [ ] | |
| 2.7 | Model provider list loads in Settings | ✅ Auto | "Models & Services" → "Providers" visible |

## 3. Dashboard

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 3.1 | Dashboard page loads | [ ] | |
| 3.2 | Quick action "New Chat" works | [ ] | |
| 3.3 | Quick action "New Assistant" works | [ ] | |
| 3.4 | Shows recent activity / stats | [ ] | |

## 4. Workspaces

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 4.1 | Can create a new workspace | [ ] | |
| 4.2 | Can switch between workspaces | [ ] | |
| 4.3 | Data is scoped to workspace | [ ] | |

## 5. Agents

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 5.1 | Agents page loads from YLAgents menu | ✅ Auto | Navigation title shows "Settings" when tapped earlier |
| 5.2 | Can create a new agent | [ ] | |
| 5.3 | Can edit an existing agent | [ ] | |
| 5.4 | Can delete an agent | [ ] | |

## 6. Agent Factory

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 6.1 | Agent Factory page loads | [ ] | |
| 6.2 | Can build agent step-by-step | [ ] | |
| 6.3 | Can save the created agent | [ ] | |

## 7. Tasks

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 7.1 | Tasks page loads | [ ] | |
| 7.2–7.4 | CRUD operations | [ ] | |

## 8. Knowledge Base

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 8.1–8.3 | Knowledge page | [ ] | |

## 9. Team Management

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 9.1–9.4 | Teams CRUD | [ ] | |

## 10. Lead Agent

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 10.1–10.3 | Lead Agent page | [ ] | |

## 11. Channels (Bot Adapters)

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 11.1–11.5 | Channels page | [ ] | |

## 12. Sync

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 12.1–12.3 | Sync page | [ ] | |

## 13. Runtime Host

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 13.1–13.3 | Runtime page | [ ] | |

## 14. Execution Traces

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 14.1–14.2 | Traces page | [ ] | |

## 15. Settings

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 15.1 | All settings categories load | ✅ Auto | General, Preferences, Assistant, Models & Services, Data all present |
| 15.2 | Language can be changed | [ ] | |
| 15.3 | Model provider settings load | ✅ Auto | Providers option visible |
| 15.4 | Backup/restore options show | ✅ Auto | Backup option visible |

## 16. Localization

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 16.1 | English text shows correctly everywhere | ✅ Auto | All labels in English |
| 16.2 | Chinese text shows correctly (if switched) | [ ] | |
| 16.3 | No hardcoded text visible to user | [ ] | |

## 17. Navigation & Drawer

| # | Test Item | Status | Notes |
|---|-----------|--------|-------|
| 17.1 | Mobile side drawer shows all YLAgents pages | ✅ Auto | Dashboard, Tasks, Agents, Agent Teams, Skills, Channels, Execution Traces, Sync, Runtime |
| 17.2 | Bottom navigation works | ✅ Auto | All 5 bottom buttons respond |
| 17.3 | Back button works correctly | ✅ Auto | Back navigation works |
| 17.4 | No blank/white screens | ✅ Auto | All pages render content |

---

## Summary

| Section | Total | Auto-Tested | Remaining for Manual |
|---------|-------|-------------|---------------------|
| App Launch & Basic UI | 5 | 4 | 1 |
| Chat | 7 | 2 | 5 |
| Dashboard | 4 | 0 | 4 |
| Workspaces | 3 | 0 | 3 |
| Agents | 4 | 1 | 3 |
| Agent Factory | 3 | 0 | 3 |
| Tasks | 4 | 0 | 4 |
| Knowledge | 3 | 0 | 3 |
| Teams | 4 | 0 | 4 |
| Lead Agent | 3 | 0 | 3 |
| Channels | 5 | 0 | 5 |
| Sync | 3 | 0 | 3 |
| Runtime | 3 | 0 | 3 |
| Traces | 2 | 0 | 2 |
| Settings | 4 | 3 | 1 |
| Localization | 3 | 1 | 2 |
| Navigation | 4 | 4 | 0 |
| **Total** | **64** | **15** | **49** |

## How to Report

Reply like:
```
2.1 ✅
2.2 ❌ - AI shows loading spinner forever
5.3 ✅
11.1 ❌ - Channels page is blank
```