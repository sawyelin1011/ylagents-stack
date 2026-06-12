# AGENTS.md

> Kelivo is a cross-platform Flutter LLM chat client (Android / iOS / macOS / Windows / Linux) extended with the YLAgents multi-agent orchestration stack.
> This file defines hard constraints and architectural context for AI-assisted development. Predictable, auditable, repeatable.

## 1. Repository Facts

- **Flutter app**: `pubspec.yaml` declares `sdk: ^3.12.1`, `flutter: >=3.44.1`, `flutter.generate: true`.
- **Main code**: `lib/`, **tests**: `test/`. **Local path dependencies** (must be treated as independent modules):
  - `dependencies/mcp_client` — MCP client SDK
  - `dependencies/tray_manager/packages/tray_manager` — Desktop tray icon
  - `dependencies/flutter_tts` — Text-to-speech (forked)
  - `dependencies/flutter-permission-handler/permission_handler_windows` — Windows permission override
  - `dependencies/gpt_markdown` — Markdown rendering (forked)
- **Localization**: `l10n.yaml` drives 4 ARB files that must stay in sync:
  - `lib/l10n/app_en.arb`, `lib/l10n/app_zh.arb`, `lib/l10n/app_zh_Hans.arb`, `lib/l10n/app_zh_Hant.arb`
- **Generated files** (never hand-edit):
  - `lib/l10n/app_localizations*.dart`
  - `lib/core/models/*.g.dart`
  - `.dart_tool/**`, `build/**`
- **Package name**: `Kelivo`. Imports use `package:Kelivo/...` everywhere. Do not normalize it.
- **Platform entry**: `main.dart` → `_selectHome()`
  - macOS / Windows / Linux → `DesktopHomePage`
  - Android / iOS → `HomePage`
- **Desktop is NOT "mobile stretched wider"**:
  - `lib/desktop/desktop_home_page.dart` is the desktop app shell (nav rail, title bar, hotkeys, desktop settings, translate/storage tabs)
  - `lib/desktop/desktop_chat_page.dart` is a thin wrapper that returns `const HomePage()` — the tablet/desktop branch inside `HomePage` handles the layout
  - `lib/features/home/pages/home_page.dart` switches internally by width to `home_mobile_layout.dart` or `home_desktop_layout.dart`
  - Therefore "wide/tablet layout" ≠ "desktop app entry". Do not conflate them.
- **Reusable UI primitives**:
  - `lib/shared/widgets/ios_tactile.dart`: `IosIconButton`, `IosCardPress`
  - `lib/shared/widgets/ios_tile_button.dart`, `ios_switch.dart`, `ios_checkbox.dart`, `ios_form_text_field.dart`
  - `lib/desktop/widgets/desktop_select_dropdown.dart`
  - `lib/shared/dialogs/**`, `lib/shared/responsive/**`
- **Theme**: `lib/theme/**` is the single source of truth. Android dynamic color is only enabled per-platform in `main.dart`. Do not extrapolate Android rules to desktop.

## 2. Working Style

- Communicate in **Chinese** throughout. Stay focused on the current task. No vague suggestions.
- Facts first. All conclusions must be based on current code, config, tests, build scripts, or git state. No guessing.
- Debug-first. Never add silent degradation, swallowed errors, hidden fallback paths, or fake success branches just to "make it run".
- Default to KISS / YAGNI:
  - Use the most direct, most verifiable approach first.
  - Do not pre-plant extra layers, empty abstractions, or config switches for "architectural completeness".
- SOLID is a tool, not a goal:
  - Only split responsibilities when it genuinely reduces coupling and improves readability.
  - Do not shatter simple logic into a chain of tiny files just for formal layering.
- Minimal closed loop. Make only the minimum change needed for the current task. Do not fix unrelated issues on the side.
- Parallel context gathering by default during exploration:
  - Independent file reads, `rg` searches, `git status`, config checks, and log inspections should be batched in a single parallel round.
- For complex tasks, write a brief Mini Control Contract before touching code:
  - `Primary Setpoint`: What exactly must be achieved
  - `Acceptance`: What command, test, or behavior proves it
  - `Guardrails`: What must not break as a side effect
  - `Boundary`: Which files/modules are in scope
  - `Risks`: 1 to 3 key risks

## 3. Mandatory Rules

### 3.1 All User-Visible Text Must Be Localized

- No user-visible text may be hardcoded in Dart UI code. This includes page titles, button labels, `SnackBar`/`Dialog`/`Tooltip` content, `semanticLabel`, notification text, and tray menu text.
- When adding or modifying user-visible strings, **ALL 4 ARB files** must be updated simultaneously.
- Updating only `app_en.arb` or only `app_zh.arb` and stopping is **not acceptable**.
- Placeholders, plurals, selects, and `@key` metadata must be consistent across all four ARB files.
- New keys follow the existing camelCase convention with a feature prefix. Do not use context-free short names like `title1` or `labelText`.
- After ARB changes, run:

```bash
flutter gen-l10n
```

- Never hand-edit `lib/l10n/app_localizations.dart` or `lib/l10n/app_localizations_*.dart`.
- `desiredFileName.txt` is the untranslated messages file. Do not introduce new untranslated entries. If you add a key, provide translations for all languages in the same change.

### 3.2 Generated Code Must Be Maintained Via Commands

- After modifying Hive models, `@HiveType`, `@HiveField`, or `part '*.g.dart'` references, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- Generated file changes must correspond strictly to source changes. Do not hand-craft `*.g.dart` files.

### 3.3 Format Code Before Finishing

- Any change to Dart/Flutter code requires formatting before completion.
- Prefer formatting only the changed paths. For large changes, format `lib/` and `test/`.

```bash
dart format <changed-paths>
```

- Unformatted code must not be committed.

### 3.4 Minimum Sufficient Verification After Completion

- Default minimum verification loop:

```bash
flutter analyze
flutter test
```

- If the change scope is clearly narrow, at minimum run the relevant test subset and explain in the delivery notes why only a subset was run.
- If the following content types are modified, the corresponding extra action is mandatory:

| Change Type | Required Action |
| --- | --- |
| ARB / localization | `flutter gen-l10n`, check `desiredFileName.txt`, then `flutter analyze` |
| Hive model / generated code | `dart run build_runner build --delete-conflicting-outputs`, then run related tests |
| `pubspec.yaml` / dependencies | `flutter pub get`, then `flutter analyze` and related tests |
| `.github/workflows/**` / build scripts | Check ALL similar workflow files, not just one |
| Platform directories `android/ ios/ macos/ linux/ windows/` | At least one targeted platform verification; if impossible, state why explicitly |
| `dependencies/**` path dependencies | Run analysis/tests in the dependency's own directory, not just the root repo |
| `lib/desktop/**`, desktop hotkeys/tray/window logic | At least one desktop-targeted verification (e.g., `flutter run -d macos`, `flutter build macos`, or the corresponding Windows/Linux target); if only the current machine's platform was verified, state the uncovered platform boundary |

- If local environment limitations prevent completing any verification, the final delivery notes must explicitly state "what was not run, why, and where the risk lies".

### 3.5 Do Not Hand-Edit or Commit What Should Not Be Committed

- Never hand-edit:
  - `.dart_tool/**`
  - `build/**`
  - Content maintained by `flutter gen-l10n` / `build_runner`
- Do not modify unless required by the task:
  - `.idea/**`
  - Platform signing, certificates, personal environment files
  - Workflows unrelated to the current task

### 3.6 Secrets and Fallback Mechanisms

- Never commit real secrets to source code.
- `lib/secrets/fallback.dart` is generated at build time (CI injects it). Do not write real keys into the repo. The file does not exist in the working tree; it must be created to compile locally:

```bash
mkdir -p lib/secrets
cat > lib/secrets/fallback.dart <<'EOF'
const String siliconflowFallbackKey = '';
EOF
```

- Do not silently add new fallback keys, fallback APIs, or error-swallowing logic just to "make it run".
- If a fallback mechanism is genuinely needed, it must satisfy ALL of:
  - Explicit toggle
  - Clear logging
  - Can be disabled
  - Reason documented in the task description

### 3.7 Change Boundary and Duplicate Workflows

- This repo has multiple similar GitHub Actions workflow files, especially for builds. When touching build, versioning, or injection logic, check ALL similar workflows for sync.
- Do not expand scope just because you spotted something that "could be unified". Finish the current task first, then decide whether to open a separate refactoring task.
- When touching a path dependency, treat it as an independent module. Do not only patch the surface at the root repo level.

### 3.8 Desktop Tasks: Determine Entry Layer First

- When the task mentions desktop, Windows, macOS, Linux, tray, hotkeys, window, context menu, or desktop settings, first determine which layer the issue belongs to:
  - Top-level desktop app shell: `lib/desktop/**`
  - Shared chat content layer: `lib/features/home/**`
  - Platform services or providers: `lib/core/**`, platform directories, or path dependencies
- For desktop app shell changes, check these first:
  - `lib/main.dart`
  - `lib/desktop/desktop_home_page.dart`
  - `lib/desktop/desktop_settings_page.dart`
  - `lib/desktop/setting/**`
  - `lib/desktop/window_title_bar.dart`
  - `lib/desktop/desktop_tray_controller.dart`
  - `lib/desktop/hotkeys/**`
- Only when the issue clearly belongs to "shared content area reused by desktop chat page" should you prioritize:
  - `lib/features/home/pages/home_page.dart`
  - `lib/features/home/pages/home_desktop_layout.dart`
  - `lib/features/home/widgets/**`
- Do not guess desktop platform behavior in `home_mobile_layout.dart` or mobile branches. Do not stuff desktop-specific control flow into mobile entry points.
- Desktop interactions differ from mobile. For example, chat messages currently use "long-press on mobile, right-click menu on desktop". Desktop tasks must consider hover, right-click, keyboard shortcuts, window size, and title bar — not just touch gestures.
- If a task spans both the desktop shell and the shared content layer, state the primary landing point in the description first, then apply minimal changes in each respective layer. Do not scatter platform routing across unrelated locations.

### 3.9 UI Component Reuse and Custom iOS Style Boundary

- Before adding new UI, search these directories for existing components instead of hand-rolling a new one inline:
  - `lib/shared/widgets/**`
  - `lib/shared/dialogs/**`
  - `lib/shared/responsive/**`
  - `lib/desktop/widgets/**`
- Prefer reusing or extending existing components, such as:
  - `IosIconButton`, `IosCardPress`, `IosTileButton`, `IosSwitch`, `IosCheckbox`, `IosFormTextField`
  - `DesktopSelectDropdown`, `WindowTitleBar`
- If a new style will appear on two or more pages, do not keep adding page-private widgets. Extract it to `lib/shared/widgets/` or `lib/desktop/widgets/` as a reusable component.
- Visual and interaction style defaults to "custom iOS style", not Android style:
  - Do not introduce Android ripple, Material default splash, default FAB emphasis, or Android-style button feedback
  - Hover/press feedback should prefer the existing iOS tactile components' approach: color, opacity, subtle scale transitions
  - Desktop allows hover, right-click, and focus states, but the overall feel must remain unified to the custom iOS style, not a Material/Android mashup
- If Material native components must be used for semantic or framework reasons, explicitly suppress off-style default feedback and consolidate styling into shared components instead of patching it piecemeal across pages.
- Icons, spacing, forms, dialogs, and panel styles should follow existing theme tokens and components. Do not mix multiple visual languages on the same page.

### 3.10 Tests and Self-Review Must Be Requirement-Driven

- Tests must be driven by requirements, defect symptoms, or acceptance criteria — not by chasing implementation details.
- Before writing tests, list the minimum scenario set for this task. At minimum, explicitly cover:
  - Happy path
  - Boundary inputs
  - Error or failure paths
  - State transitions or interaction branches (if applicable)
- When fixing bugs, write a minimal failing case first, then fix. Do not only add an after-the-fact weak-assertion test that "happens to pass".
- Never widen public API surface, expose private internals, or distort production code responsibilities just to make tests easier to write.
- Before completion, perform at least one self-review explicitly checking these dimensions:
  - Maintainability: Is the code easier to read and modify than before?
  - Performance: Any obvious extra rebuilds, IO, traversals, or allocations introduced?
  - Security: Any input validation gaps, secret leaks, path/command injection, or permission boundary errors?
  - Style consistency: Does it match the repo's existing naming, organization, and UI language?
  - Documentation and comments: Does complex intent need minimal explanation?
  - Compatibility boundary: Does it affect existing user data, config, persisted fields, import/export formats, or established interactions?
- Compatibility is not a default-ignore item. When existing data or published behavior is involved, explicitly judge compatibility. If breaking, the delivery notes must state the breakage scope and migration path.

## 4. Architecture Overview

### 4.1 Layered Structure

```
lib/
├── main.dart                  # Entry point, MultiProvider wiring, platform gate
├── desktop/                   # Desktop app shell (rail, title bar, tray, hotkeys, settings)
├── features/                  # Feature pages and widgets (chat, home, agents, settings, etc.)
│   ├── home/                  # Shared chat page (mobile + desktop tablet layouts)
│   ├── chat/                  # Chat-specific widgets and controllers
│   ├── agents/                # Agent management UI
│   ├── agent_factory/           # Visual agent builder
│   ├── assistant/               # Assistant settings
│   ├── channels/                # Bot channel adapters (Discord, Slack, Telegram, etc.)
│   ├── lead_agent/              # Lead agent UI
│   ├── runtime/                 # Runtime host UI
│   ├── skills/                  # Skill system UI
│   ├── tasks/                   # Task queue UI
│   ├── team/                    # Team management UI
│   ├── traces/                  # Execution trace UI
│   ├── settings/                # Mobile settings
│   ├── translate/               # Translation page
│   ├── knowledge/               # Knowledge base
│   ├── world_book/              # World books
│   └── ...
├── core/
│   ├── models/                  # Hive-backed data models (ChatMessage, Conversation, Agent, Assistant, etc.)
│   ├── providers/               # ChangeNotifier providers (state management)
│   └── services/                # Business logic, API clients, orchestration
├── shared/
│   ├── widgets/                 # Reusable UI primitives (iOS style, dialogs, responsive)
│   ├── dialogs/                 # Shared dialog implementations
│   ├── responsive/              # Responsive layout helpers
│   └── platform/                # Platform abstraction stubs
├── theme/                       # Theme factory, palettes, design tokens, font weights
├── l10n/                        # ARB localization files
└── utils/                       # Utility helpers (sandbox paths, markdown, clipboard, etc.)
```

### 4.2 State Management Pattern

- **All state lives in `ChangeNotifier` providers** registered in `main.dart`'s `MultiProvider`.
- **Provider dependency injection** is explicit in `MultiProvider` order:
  - `WorkspaceProvider` → `ChatProvider` → `SettingsProvider` → `ChatService` → `AssistantProvider` (needs ChatService) → `AgentProvider` (needs AssistantProvider) → ...
  - Order matters. Do not reorder without verifying downstream dependencies.
- **Persistence strategy**:
  - Lightweight config (settings, agents, workspaces, provider configs) → `SharedPreferences` as JSON strings with versioned keys (`_v1` suffix).
  - Heavy data (messages, conversations) → Hive boxes with generated `.g.dart` adapters.
- **Versioned storage keys**: All persisted keys use `_v1` suffix (e.g., `agents_v1`, `workspaces_v1`) for safe migration.

### 4.3 Desktop-Specific Architecture

- **Desktop app shell**: `DesktopHomePage` manages tabs (Dashboard, Tasks, Agents, Knowledge, Channels, Sync, Runtime, Chats, Settings) via a navigation rail.
- **Desktop chat**: `DesktopChatPage` literally returns `const HomePage()`. The tablet branch inside `HomePage` (`home_desktop_layout.dart`) provides the actual desktop chat layout.
- **Window management**: `DesktopWindowController` uses `window_manager` + `bitsdojo_window` for Windows custom title bar and size/position persistence.
- **Tray**: `DesktopTrayController` manages the system tray icon and menu.
- **Hotkeys**: `HotkeyProvider` registers global shortcuts via `hotkey_manager`.
- **Event buses**: `HotkeyEventBus`, `ChatActionBus`, `SidebarTabBus`, `DesktopSettingsNavigationBus` — all use singleton `StreamController.broadcast()` for decoupled cross-widget communication. Use these instead of passing callbacks deep through the tree.
- **Windows title bar**: `TitleBarStyle.hidden` is set in `main.dart`. The custom `WindowTitleBar` widget renders the Flutter-based title bar. Do not change this on Windows without also updating `DesktopWindowController`.

### 4.4 Agent / Assistant Duality

- The codebase has a **dual model**: `Assistant` stores chat configuration (model, temperature, system prompt, etc.); `Agent` (wrapping `AgentGenome`) stores identity, soul, role, goals, policies, schedules, and channels.
- **Critical invariant**: `Agent.id` must exactly equal `Assistant.id`. They share the same UUID.
- `AgentProvider` depends on `AssistantProvider` in constructor. Migration from legacy Assistant to Agent happens via `AgentMigrationService`.
- Agent hierarchy: `LeadAgentService` → `ManagerAgentService` → `WorkerAgentService` for task delegation and orchestration.

### 4.5 Chat API Architecture

- `ChatApiService` is the main API client, split into `part` files via `part of` directives for each provider family (`openai_common.dart`, `claude_official.dart`, `google_gemini.dart`, etc.).
- Model capability inference is **regex-based** in `ModelRegistry` / `BuiltInToolsHelper` (classifies vision, tool, reasoning by model ID string). Adding a new model requires updating these regexes — there is no dynamic API discovery.
- `ChatService` is a `ChangeNotifier` that manages conversation state, message history, and delegates to `ChatApiService` for generation.
- Features like tool calling, reasoning, image generation, and custom headers are all modeled as per-assistant configuration fields.

### 4.6 Theme System

- `ThemePalettes` defines explicit `ColorScheme` for light+dark per palette (default, blue, green, purple, etc.). Colors are hardcoded hex values — no dynamic generation.
- `ThemeFactory` builds `ThemeData` from palette with platform-specific font fallbacks (CJK: PingFang SC, Heiti SC, Microsoft YaHei; Windows: Segoe UI).
- `DynamicColor` is used for Material You dynamic color on Android, but palettes are the primary system.
- `app_font_weights.dart` handles weight clamping for CJK fonts.

## 5. Essential Commands

```bash
# Dependencies
flutter pub get

# Build generated code (Hive, etc.)
dart run build_runner build --delete-conflicting-outputs

# Localization
flutter gen-l10n

# Analysis
flutter analyze
# Or scoped:
dart analyze lib test

# Tests
flutter test
# Or scoped:
flutter test test/path/to/specific_test.dart

# Format (run before committing)
dart format <changed-paths>
# Or full:
dart format lib/ test/

# Run on specific platforms
flutter run -d android
flutter run -d ios
flutter run -d macos
flutter run -d windows
flutter run -d linux

# Build release
flutter build apk --release
flutter build ios --release --no-codesign
flutter build macos --release
flutter build windows --release
flutter build linux --release

# Launcher icons / splash (when assets change)
flutter pub run flutter_launcher_icons:main
flutter pub run flutter_native_splash:create
```

### 5.1 CI / GitHub Actions

- Three workflows exist:
  - `.github/workflows/ci.yml` — analyze, format check, l10n, test on PR/push to main
  - `.github/workflows/pr-check.yml` — stricter PR checks including no-new-untranslated-messages
  - `.github/workflows/build.yml` — release builds for Android, iOS, macOS, Windows, Linux (with artifact upload and release publishing)
- **Flutter version**: All workflows pin `FLUTTER_VERSION: '3.44.2'` and `channel: stable`. Do not change this in one workflow without changing all three.
- **Format check**: CI only checks changed files. It runs `dart format` on changed `.dart` files and fails if the formatter produces a diff.
- **Secrets injection**: All workflows inject `lib/secrets/fallback.dart` with `secrets.SILICONFLOW_KEY`. If you modify the secrets file format, update ALL workflows.

## 6. Important Gotchas

### 6.1 `lib/secrets/fallback.dart` is Required to Compile

The file does not exist in the working tree. CI generates it at build time. For local development, create it manually:

```bash
mkdir -p lib/secrets
cat > lib/secrets/fallback.dart <<'EOF'
const String siliconflowFallbackKey = '';
EOF
```

It is imported by `chat_api_service.dart` and `model_provider.dart`. If the import signature changes, compilation fails.

### 6.2 Hive Type IDs are Fixed

`ChatMessage` uses `typeId: 0`, `Conversation` uses `typeId: 1`. Adding new Hive types requires careful ID management to avoid collisions. Always run `build_runner` after model changes. Never hand-edit `*.g.dart` files.

### 6.3 Provider Creation Order in `main.dart` is Load-Bearing

`MultiProvider` registration order encodes dependency graph. `WorkspaceProvider` → `ChatProvider` → `SettingsProvider` → `ChatService` → `AssistantProvider` → `AgentProvider`. Changing order can cause runtime null errors or circular dependencies.

### 6.4 DesktopChatPage is a No-Op

Do not modify `lib/desktop/desktop_chat_page.dart` expecting to change the desktop chat experience. The real desktop chat layout is the tablet branch inside `lib/features/home/pages/home_page.dart` (`home_desktop_layout.dart`).

### 6.5 Windows Title Bar is Hidden

`windowManager.setTitleBarStyle(TitleBarStyle.hidden)` is called in `main.dart` for Windows. The custom `WindowTitleBar` widget provides the replacement. If you add window controls or drag regions, coordinate with `DesktopWindowController` and `WindowSizeManager`.

### 6.6 Agent / Assistant ID Sharing

`Agent.id` and `Assistant.id` must be identical. The agent system layers on top of the assistant chat config without duplicating it. When creating an agent, ensure the same UUID is used for both records.

### 6.7 Model Capability Inference is Regex-Based

Adding support for a new model provider or model ID requires updating `ModelRegistry` regexes in `model_provider.dart` and `BuiltInToolsHelper`. Vision, tool, and reasoning capabilities are inferred from model ID string patterns, not from API introspection.

### 6.8 Sandbox Path Resolution

`SandboxPathResolver` is initialized in `main()` to fix iOS file path issues. Any file storage operation that persists absolute paths across sessions must go through this resolver to handle iOS sandbox changes after app updates.

### 6.9 System Font Loading

Desktop only loads system fonts lazily (post-frame) if the user selected a system font family. Do not preload all system fonts at launch — it causes huge memory pressure. The `SystemFonts` package is used with selective family loading.

### 6.10 Android Background Execution

`AndroidBackgroundManager` is wired in `main.dart` post-frame. It matches the `androidBackgroundChatMode` setting (`off`, `on`, `onNotify`). If you change the notification initialization flow, test on a real Android device — background execution behavior varies across OEMs.

### 6.11 Path Dependencies are Independent Modules

`dependencies/mcp_client`, `dependencies/tray_manager`, `dependencies/flutter_tts`, `dependencies/gpt_markdown`, and `dependencies/flutter-permission-handler/permission_handler_windows` are separate packages with their own `pubspec.yaml`, tests, and analysis options. When modifying them, run their own tests/analysis, not just root repo verification.

### 6.12 Analysis Options Override

`analysis_options.yaml` disables `package_names` lint because the package is named `Kelivo` (capitalized). Do not change this unless the package name itself is being renamed. The analyzer also excludes `dependencies/flutter_tts/**` from analysis.

### 6.13 Image Cache Limit

`main.dart` caps `PaintingBinding.instance.imageCache` to 200 items / ~48MB. This is intentional to reduce memory pressure from large images in chat. Do not raise this without understanding the memory impact on low-end Android devices.

## 7. Recommended Execution Order

1. `git status --short` — confirm workspace baseline.
2. Read relevant code and config. Write clear acceptance criteria. For desktop tasks, confirm entry topology first: `main.dart` → `lib/desktop/**` → shared chat layout.
3. Batch all independent context reads, searches, and status checks in parallel, then decide the minimal change landing point.
4. List requirement scenarios and verification methods first, then make minimal changes. Do not mix in unrelated refactoring.
5. Run the generation, formatting, analysis, and test commands relevant to this task.
6. Self-review `git diff`. Confirm no missed localization, generated files, compatibility risks, or unrelated changes.
7. When delivering, state explicitly:
   - What was changed
   - What commands were run
   - What verification was skipped
   - What residual risks remain

## 8. Pre-Commit Checklist

- All new user-visible text uses `AppLocalizations`.
- All 4 ARB files have been updated in sync.
- `flutter gen-l10n` has been executed and generated files match ARB content.
- If Hive models were touched, `build_runner` has been executed.
- `dart format` has been executed.
- `flutter analyze` has been executed.
- Related `flutter test` has been executed. If no related tests exist, create and run them following official testing standards.
- Test scenarios cover the happy path, boundary values, and failure paths for this task's requirements — not just a single green run.
- Desktop tasks have confirmed the entry layer. No desktop-only logic leaked into mobile branches.
- New or adjusted UI prioritized reuse of existing shared / desktop components. No near-duplicate widgets created.
- New UI does not introduce unnecessary Android ripple or Material default interaction feedback.
- At least one round of self-review completed, checking maintainability, performance, security, style consistency, and compatibility boundary.
- No real secrets, build artifacts, or unrelated files committed.
- If workflows / platform directories / path dependencies were touched, corresponding extra verification has been done.

## 9. External Best Practices

- Code should follow the Flutter contribution guide:
  - https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md
- Tests should reference:
  - https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md
  - https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md
- For Flutter code style, follow the Flutter styleguide first. Follow Effective Dart: Style only when it does not conflict:
  - https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md
  - https://dart.dev/effective-dart/style
- If the repo ever introduces `engine/`-level changes, add engine test guidance then. The repo currently has no such directory; do not apply it mechanically.
- PR descriptions should include the Pre-launch Checklist from the Flutter PR template when applicable:
  - https://github.com/flutter/flutter/blob/main/.github/PULL_REQUEST_TEMPLATE.md

## 10. Design Principles

- Readability first. Code is for humans to read, not for machines to show off.
- Default against bloated implementations, idle abstractions, and academic over-engineering.
- If you can remove complexity, remove it. If you can avoid a branch, avoid it. If you can skip a layer of indirection, skip it.
- Simple, stable, and verifiable first. "Elegant" comes after.
- Avoid dual state and dual truth. Keep one source of truth.
- Write only what is needed now, but write it right.
- Error messages must be useful — they should help locate and recover, not just say "failed".
- Mechanisms over hand-picked magic constants. If a threshold must be hardcoded, explain why and state its boundaries.
- When small-step verification is possible, do not make large irreversible changes.

## 11. Historical Pitfall Log

> Record significant pitfalls encountered during development here.

- Recording principles:
  - Only record issues that actually occurred in this repo and have reuse value for future development.
  - Do not write "heard this might happen" hearsay entries.
  - When adding entries, prefer "symptom -> root cause -> fix/constraint". Avoid recording conclusions without context.

### 11.1 Example Entry Format

```
- **Symptom**: [What broke or behaved unexpectedly]
- **Root cause**: [Why it happened]
- **Fix/constraint**: [What was done to resolve it, and what rule now applies]
```

## Appendix: Skills Usage Rules

- Before starting a task, scan available skill documents in `/.agents/skills/`.
- When activating a skill, declare the skill name and purpose in communication.
- Regular development does not mandate any specific skill. Activate only when semantically matched.
