# YLAgents Implementation Plan — Android / iOS / Windows Build Ready

> Target: Android, iOS, Windows
> Goal: Code compiles, builds cleanly, basic mobile parity, CI/CD auto-release
> Based on: YLAGENTS_CODE_REVIEW.md, YLAGENTS_IMPLEMENTATION_PLAN.md, PROGRESS_TRACKING.md

---

## Phase A: Build Foundation (Fix Now — No Flutter SDK Required)

### A.1 Compilation & Critical Fixes

| # | Task | File | Status | Why |
|---|---|---|---|---|
| A.1.1 | Create `lib/secrets/fallback.dart` | `lib/secrets/fallback.dart` | ✅ Done | Compilation blocker |
| A.1.2 | Regenerate l10n files | `lib/l10n/app_localizations*.dart` | 🔄 Next | All ARB files updated, generated files may be stale |
| A.1.3 | Regenerate Hive models | `lib/core/models/*.g.dart` | 🔄 Next | Conversation has new `@HiveField(13)` |
| A.1.4 | Format all changed files | All new/modified `.dart` | 🔄 Next | CI format check will fail otherwise |
| A.1.5 | Verify all imports resolve | `lib/main.dart` + new files | 🔄 Next | Check for missing imports from new providers |

### A.2 Import Audit for New Files

New files added across all phases need to be checked for:
- Missing imports
- Circular imports
- `package:Kelivo/` imports vs relative imports
- Platform-conditional imports (desktop-only files on mobile)

**Platform-conditional imports to check:**
- `window_manager` → only on desktop (`desktop/desktop_home_page.dart`, `desktop/desktop_window_controller.dart`)
- `desktop_drop` → desktop only
- `hotkey_manager` → desktop only
- `tray_manager` → desktop only
- `bitsdojo_window` → Windows only

All these are already guarded by `if (defaultTargetPlatform == TargetPlatform.windows)` or `if (!kIsWeb && isDesktop)` in `main.dart`. No mobile breakage expected.

---

## Phase B: Mobile Parity (Android / iOS)

### B.1 Strategy: Add Workspace to Mobile Home

**Primary Setpoint:** Mobile home page must be workspace-aware.
**Acceptance:** `HomePage` renders with `WorkspaceProvider` context, `SideDrawer` shows workspace-scoped conversations.
**Guardrails:** Do not break existing chat behavior. Desktop behavior unchanged.
**Boundary:** `lib/features/home/`, `lib/features/settings/`
**Risks:**
1. `SideDrawer` performance — filtering conversations adds an O(n) pass
2. Mobile settings bloat — adding workspace settings to existing settings page

### B.2 Implementation Steps

| # | Task | File | Effort | Notes |
|---|---|---|---|---|
| B.2.1 | Import `WorkspaceProvider` in `HomePage` | `home_page.dart` | Small | Add to `context.watch` |
| B.2.2 | Pass `workspaceId` to `SideDrawer` from mobile layout | `home_mobile_layout.dart` | Small | Read from `WorkspaceProvider` |
| B.2.3 | Add workspace selector UI to mobile AppBar | `home_mobile_layout.dart` | Medium | Dropdown or sheet |
| B.2.4 | Add workspace settings to mobile Settings | `settings_page.dart` | Medium | New section in existing settings |
| B.2.5 | Add workspace entry to `HomePage` post-frame | `home_page.dart` | Small | Ensure `ensurePersonalWorkspace()` runs on mobile too |
| B.2.6 | Make `DashboardPage` responsive | `dashboard_page.dart` | Medium | Currently desktop-only padding; adapt for mobile |

### B.3 Mobile Feature Pages (Minimum Viable)

Not all desktop features need mobile pages for v1. Priority:

| Feature | Mobile Page | Priority | Approach |
|---|---|---|---|
| Dashboard | ✅ Must have | High | Make responsive, add to mobile nav |
| Tasks | ✅ Must have | High | Kanban doesn't fit mobile. Convert to list view. |
| Agents | ✅ Must have | High | List view with cards, filter by workspace |
| Agent Factory | ✅ Must have | High | Scrollable page instead of wizard steps |
| Lead Agent Execution | ✅ Must have | Medium | Reuse execution page, make responsive |
| Team | ✅ Must have | Medium | List view with expand/collapse |
| Traces | ✅ Must have | Medium | List view with detail bottom sheet |
| Skills | ✅ Must have | Medium | Two tabs work on mobile as-is |
| Channels | ✅ Must have | Medium | List view with detail bottom sheet |
| Sync | ✅ Must have | Low | Settings-like page, responsive |
| Runtime | ✅ Must have | Low | Status page, responsive |
| Knowledge | ✅ Must have | Low | Placeholder, make responsive |

**Mobile Navigation Strategy:**
- Add a bottom nav bar or drawer to `HomePage` for mobile
- Or: add entries to the existing `SideDrawer` bottom menu
- Existing mobile settings already has an entry point — extend it

### B.4 Mobile Navigation Design

**Option A: Bottom Navigation Bar (Recommended)**
```
[Home] [Dashboard] [Agents] [More] [Settings]
```
- `Home`: Chat (existing)
- `Dashboard`: Workspace overview (new)
- `Agents`: Agent list + factory (new)
- `More`: Tasks, Teams, Skills, Channels, Traces, Sync, Runtime (modal drawer)
- `Settings`: Existing settings page

**Option B: SideDrawer Extension (Simpler)**
- Add sections to the bottom of `SideDrawer`:
  - "Workspace: [Name]" (with workspace selector)
  - "Agents", "Tasks", "Teams", "Skills", "Channels", "Traces"
  - "Sync", "Runtime"
- Tap opens respective page via `MaterialPageRoute`

**Decision:** Option B is simpler to implement and respects existing patterns. The SideDrawer already has a bottom bar area.

---

## Phase C: Windows Desktop Fixes

### C.1 Windows-Specific Issues

| # | Task | File | Effort | Notes |
|---|---|---|---|---|
| C.1.1 | Verify `window_manager` + `bitsdojo_window` wiring | `main.dart`, `desktop_window_controller.dart` | Small | Already exists, just verify |
| C.1.2 | Verify `DesktopWindowController` initializes on Windows | `desktop_window_controller.dart` | Small | Title bar hidden, custom rendered |
| C.1.3 | Check `permission_handler_windows` override | `pubspec.yaml` | Small | Already configured |
| C.1.4 | Verify Windows build artifacts | `build.yml` | Small | Already configured |
| C.1.5 | Ensure `flutter_launcher_icons` has Windows config | `flutter_launcher_icons.yaml` | Small | Check existing |

### C.2 Desktop Home Page Refinements

| # | Task | File | Effort | Notes |
|---|---|---|---|
| C.2.1 | Fix `NavTab` runtime count (9 tabs vs 8 clamp) | `desktop_home_page.dart` | Small | Line 55: `clamp(0, 8)` should be `clamp(0, NavTab.values.length - 1)` |
| C.2.2 | Wire Dashboard quick actions | `dashboard_page.dart` | Small | Add `onTap` to chips |
| C.2.3 | Knowledge page placeholder → real | `knowledge_page.dart` | Medium | Link world books, add file attachment |

---

## Phase D: CI/CD Auto-Release Workflow

### D.1 Goal: Build & Release on Every Push to main

**Trigger:** Push to `main` branch OR manual `workflow_dispatch`
**Platforms:** Android (APK), iOS (unsigned IPA), Windows (ZIP + Installer)
**Versioning:** Auto-increment from `pubspec.yaml` + git short SHA
**No local build required** — everything runs in GitHub Actions

### D.2 Workflow Design

#### Workflow File: `.github/workflows/auto-release.yml`

**Jobs:**
1. `android` — Build APK, upload artifact, create GitHub release
2. `ios` — Build unsigned IPA, upload artifact, create GitHub release
3. `windows` — Build ZIP + Installer, upload artifact, create GitHub release

**Version Resolution:**
```yaml
- name: Resolve version
  id: version
  run: |
    RAW=$(grep 'version:' pubspec.yaml | sed 's/version: //' | tr -d ' ')
    SHA=$(git rev-parse --short HEAD)
    VERSION="${RAW}_${SHA}"
    echo "VERSION=$VERSION" >> $GITHUB_ENV
```

**Secrets:**
- `SILICONFLOW_KEY` → injected into `lib/secrets/fallback.dart`
- Android signing: `SIGN_KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
- iOS: No signing (unsigned IPA build)
- Windows: No signing (ZIP + Inno Setup installer)

**Release Publishing:**
- Use `softprops/action-gh-release@v2`
- Tag: `auto-${VERSION}`
- Pre-release: true (for auto builds)
- Includes all artifacts from 3 jobs

### D.3 CI Quality Gates (Pre-Release)

Before release, run:
1. `flutter pub get`
2. `dart format --set-exit-if-changed lib/ test/` (or check changed files)
3. `dart analyze lib test`
4. `flutter test`
5. `flutter gen-l10n` (verify no diff)

If any gate fails, release is blocked.

### D.4 Versioning Strategy

- Manual version bumps in `pubspec.yaml` (e.g., `1.2.0+61`)
- Auto builds append git SHA: `1.2.0+61_abc1234`
- Release builds use exact version from pubspec
- GitHub releases tagged as `v1.2.0+61` for manual releases, `auto-1.2.0+61_abc1234` for CI builds

---

## Phase E: Testing & Verification

### E.1 Tests to Add (Priority Order)

| # | Test | File | Priority | Notes |
|---|---|---|---|---|
| E.1.1 | WorkspaceProvider tests | `test/core/providers/workspace_provider_test.dart` | High | Mock SharedPreferences |
| E.1.2 | AgentProvider tests | `test/core/providers/agent_provider_test.dart` | High | Mock SharedPreferences + AssistantProvider |
| E.1.3 | TaskProvider tests | `test/core/providers/task_provider_test.dart` | High | Mock SharedPreferences |
| E.1.4 | LeadAgentService tests | `test/core/services/lead_agent_service_test.dart` | High | Mock LLM callback |
| E.1.5 | ChannelAdapter tests | `test/core/services/channels/telegram_adapter_test.dart` | Medium | Mock http client |
| E.1.6 | SyncProvider tests | `test/core/providers/sync_provider_test.dart` | Medium | Mock SharedPreferences |
| E.1.7 | RuntimeProvider tests | `test/core/providers/runtime_provider_test.dart` | Medium | Mock SharedPreferences |

### E.2 Mock Strategy

All provider tests use `SharedPreferences.setMockInitialValues({})`:
```dart
setUp(() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  provider = WorkspaceProvider();
  await provider.load(); // if needed
});
```

For services that depend on other providers, pass mock instances:
```dart
final mockAssistantProvider = MockAssistantProvider();
final agentProvider = AgentProvider(mockAssistantProvider);
```

---

## Phase F: Progress Tracking Updates

Update `PROGRESS_TRACKING.md` with:
- Phase 0.5: Mark as incomplete, add new sub-tasks for mobile UX
- Phase 8: Correct "placeholder adapters" claim
- Phase 9: Mark as "UI Complete / Backend Pending"
- Phase 10: Mark as "UI Complete / Execution Pending"
- Add Phase 11: "Mobile Parity" with sub-tasks
- Add Phase 12: "CI/CD Auto-Release"
- Add Phase 13: "Provider Test Coverage"

---

## Implementation Order

### Sprint 1 (This Session): Build Foundation
- [x] A.1.1 Create `fallback.dart`
- [ ] A.1.2 Regenerate l10n (when Flutter available)
- [ ] A.1.3 Regenerate Hive (when Flutter available)
- [ ] B.2.1-5 Mobile workspace in HomePage
- [ ] C.2.1 Fix NavTab clamp
- [ ] C.2.2 Wire dashboard quick actions
- [ ] D.2 Create auto-release workflow

### Sprint 2 (Next Session): Mobile Feature Pages
- [ ] B.2.6 Responsive Dashboard
- [ ] B.3 Mobile Agents page
- [ ] B.3 Mobile Tasks page (list view)
- [ ] B.3 Mobile Agent Factory (scrollable)
- [ ] B.3 Mobile Settings workspace section
- [ ] SideDrawer YLAgents menu entries

### Sprint 3: Testing & Polish
- [ ] E.1.1-7 Provider tests
- [ ] B.1.4 Format + analyze check
- [ ] F Progress tracking update
- [ ] CI/CD test run
- [ ] Mobile manual test on Android/iOS

---

## Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| No Flutter SDK locally | Can't verify compile/test | Create all code changes, rely on CI for verification |
| Mobile layout conflicts with desktop | High | Use `Responsive` wrappers or platform checks |
| SharedPreferences mock tests fail | Medium | Use `setMockInitialValues` pattern from Flutter docs |
| Android signing secrets missing | High | Build unsigned APK for CI, manual signing for release |
| iOS unsigned IPA rejected | Low | Document that IPA requires manual signing with Apple ID |
| Windows Inno Setup not installed | Medium | CI has it pre-installed; fallback to ZIP only |
| `build_runner` generates stale `.g.dart` | Medium | Always run with `--delete-conflicting-outputs` |

---

## Acceptance Criteria

- [ ] `flutter analyze` passes (zero errors, zero warnings)
- [ ] `flutter test` passes (all existing tests + new provider tests)
- [ ] `dart format` produces no changes
- [ ] `flutter gen-l10n` produces no changes
- [ ] `flutter build apk --release` succeeds
- [ ] `flutter build ios --release --no-codesign` succeeds
- [ ] `flutter build windows --release` succeeds
- [ ] CI workflow auto-builds on push to main
- [ ] Mobile home page shows workspace selector
- [ ] Mobile side drawer shows YLAgents menu entries
- [ ] Dashboard quick actions are wired
- [ ] Knowledge page has real content (not just empty state)
- [ ] No `catch (_) {}` without logging (at least log to FlutterLogger)
