# Copilot Instructions

## Build & Run

```bash
# Build the app
swift build

# Run the app (macOS only - SwiftUI requires a window server)
swift run ModelExplorer

# Build for release
swift build -c release

# Open in Xcode (if needed for debugging)
open Package.swift
```

## Architecture

This is a multiplatform SwiftUI app (macOS/iOS/iPadOS) that provides a chat interface to Apple Foundation Models, with a built-in web server on macOS.

### Module Structure

- **ModelExplorer** - Main SwiftUI app executable
  - `App.swift` - Entry point with @main
  - `ContentView.swift` - Root view with NavigationSplitView and server toggle
  - `Services/FoundationModelService.swift` - Singleton wrapper for LanguageModelSession
  - `Services/ConversationStore.swift` - File-based conversation persistence
  - `Services/ModelAvailabilityStatus.swift` - Detailed availability error handling
  - `ViewModels/ChatViewModel.swift` - @Observable view model for chat state
  - `Views/` - SwiftUI components (ChatView, MessageBubble, InputBar, ConversationSidebar, ModelUnavailableView)
  
- **WebServer** - macOS-only Hummingbird web server
  - `WebServer.swift` - WebServerManager actor for start/stop
  - `Routes/APIRoutes.swift` - REST API endpoints with SSE streaming
  - `WebResources.swift` - Embedded HTML/CSS/JS as Swift strings
  
- **Shared** - Cross-platform code shared between modules
  - `ChatMessage.swift` - Message model used by both native and web

### Key Patterns

- Platform-specific code uses `#if os(macOS)` conditionals
- WebServer module is conditionally linked only on macOS via Package.swift
- FoundationModelService is a @MainActor singleton for thread-safe session management
- ConversationStore persists to `~/Library/Application Support/ModelExplorer/Conversations/`
- Web UI is embedded as static strings to avoid resource bundling complexity
- `ModelAvailabilityStatus` enum provides specific error messages for unavailability reasons

## Conventions

- Use `@Observable` (not ObservableObject) for view models - requires Swift 5.9+
- Use `@StateObject` for `ConversationStore` (ObservableObject for SwiftUI binding)
- Async/await for all Foundation Model interactions
- Streaming responses for both native and web UI
- SSE (Server-Sent Events) for web API streaming at `/api/stream`

## Requirements

- Xcode 26+ / Swift 6.2+ (swift-tools-version: 6.2 for v26 platforms)
- macOS 26+ / iOS 26+ (Apple Foundation Models requirement)
- **Physical** Apple Silicon device (VMs are not supported)

## Web Server API

When macOS server is running (localhost:8080):

- `GET /` - Web UI (with SSE streaming support)
- `GET /api/status` - Check Foundation Models availability (includes `reason` field)
- `POST /api/chat` - Non-streaming: `{"message": "Hello"}` → `{"response": "...", "timestamp": "..."}`
- `POST /api/stream` - SSE streaming: `{"message": "Hello"}` → SSE events with `{type, content, timestamp}`

### SSE Event Types
- `content` - Partial response text
- `done` - Generation complete
- `error` - Error occurred
