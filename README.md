<div align="center">
  <h1>YLAgents Stack</h1>
  <p><strong>A Multi-Agent Orchestration Platform Built on Flutter</strong></p>
</div>

YLAgents Stack is a cross-platform AI orchestration platform evolving from a powerful LLM chat client into a full multi-agent system. It supports multiple AI providers, custom agent creation, team-based task execution, MCP tool integration, and bot channel deployment — all from a single Flutter app running on Android, iOS, Windows, macOS, and Linux.

## Vision

YLAgents Stack transforms the traditional chatbot experience into a **multi-agent workspace** where users can:

- Create specialized AI agents with unique personas, goals, and tool access
- Form agent teams with Lead → Manager → Worker hierarchies
- Deploy agents as bots on Telegram, Discord, Slack, and more
- Run agents autonomously in the background via a runtime host
- Build a reusable skill ecosystem

## Current Features

- **Multi-Provider AI** — OpenAI, Google Gemini, Anthropic Claude, and more
- **Custom Assistants** — Create and manage personalized AI assistants with system prompts
- **MCP Tool Integration** — Model Context Protocol tool support with built-in tools
- **Multi-Modal Input** — Images, PDFs, text documents, Word files, and more
- **Markdown Rendering** — Code highlighting, LaTeX formulas, tables
- **Web Search** — Integrated with 15+ search engines (Bing, DuckDuckGo, Brave, Google, etc.)
- **Voice & TTS** — System TTS plus OpenAI / Gemini / ElevenLabs
- **Material You Design** — Dynamic color theming (Android 12+), dark mode
- **Multi-Language** — English and Chinese interface
- **Data Backup** — Chat history backup and restoration via WebDAV / S3
- **Cross-Platform** — Android, iOS, Windows, macOS, Linux

## Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ |
| iOS | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

## Implementation Roadmap

| Phase | Focus | Status |
|-------|-------|--------|
| 0 | Foundation & Architecture Audit | ✅ Complete |
| 1 | Workspace & Agent Model Foundation | 🔄 In Progress |
| 2 | Assistant → Agent Migration | 📋 Planned |
| 3 | Agent Factory (Visual Builder) | 📋 Planned |
| 4 | Multi-Agent Orchestration | 📋 Planned |
| 5 | Bot Channels (Telegram, Discord, Slack) | 📋 Planned |
| 6 | Workspace-First UX Redesign | 📋 Planned |
| 7 | Skills Ecosystem | 📋 Planned |
| 8 | Sync Infrastructure | 📋 Planned |
| 9 | Runtime Host (Headless & Docker) | 📋 Planned |

See [YLAGENTS_IMPLEMENTATION_PLAN.md](YLAGENTS_IMPLEMENTATION_PLAN.md) for full details.

## Tech Stack

- **Framework:** Flutter (Dart) — SDK ^3.12.1, Flutter >=3.44.1
- **State Management:** Provider
- **Local Storage:** Hive + SharedPreferences
- **Dependencies:** MCP client, GPT Markdown renderer, TTS engine, and more

## Getting Started

```bash
# Clone the repository
git clone https://github.com/<your-org>/ylagents-stack.git
cd ylagents-stack

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run the app
flutter run
```

## Contributing

Pull Requests and Issues are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the AGPL-3.0 License — see the [LICENSE](LICENSE) file for details.