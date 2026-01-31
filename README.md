# Model Explorer

A multiplatform SwiftUI app for interacting with Apple Foundation Models, featuring a built-in web server on macOS.

## Features

- 💬 **Chat Interface** - Clean SwiftUI chat UI with streaming responses
- 🌐 **Web Server** (macOS) - Built-in Hummingbird server with SSE streaming
- 💾 **Conversation History** - Persistent storage of chat sessions
- 🔍 **Detailed Error Handling** - Specific messages for unavailability reasons

## Requirements

- **Xcode 26+** / Swift 6.2+
- **macOS 26+** / iOS 26+ / iPadOS 26+
- **Physical Apple Silicon device** (VMs not supported)
- Apple Intelligence enabled in System Settings

## Build & Run

```bash
# Build
swift build

# Run (macOS)
swift run ModelExplorer

# Open in Xcode
open Package.swift
```

## Architecture

| Module | Description |
|--------|-------------|
| `ModelExplorer` | Main SwiftUI app with chat UI and conversation management |
| `WebServer` | macOS-only Hummingbird web server with REST + SSE APIs |
| `Shared` | Cross-platform models and utilities |

## Web API

When the server is running (toggle in toolbar):

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Web UI |
| `/api/status` | GET | Check model availability |
| `/api/chat` | POST | Non-streaming chat |
| `/api/stream` | POST | SSE streaming chat |

## License

MIT
