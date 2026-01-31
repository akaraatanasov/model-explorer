import SwiftUI
#if os(macOS)
import WebServer
#endif

public struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    @StateObject private var conversationStore = ConversationStore.shared
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    #if os(macOS)
    @State private var isServerRunning = false
    @State private var serverPort: UInt16 = 8080
    #endif
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ConversationSidebar(store: conversationStore) {
                viewModel.newConversation()
            }
            .navigationTitle("History")
        } detail: {
            ChatView(viewModel: viewModel)
                .navigationTitle(currentTitle)
                #if os(macOS)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        serverToggle
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete", systemImage: "trash") {
                            viewModel.clearChat()
                        }
                        .disabled(viewModel.currentConversationId == nil)
                    }
                }
                #else
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Delete", systemImage: "trash") {
                            viewModel.clearChat()
                        }
                        .disabled(viewModel.currentConversationId == nil)
                    }
                }
                #endif
        }
        .onChange(of: conversationStore.currentConversationId) { _, newId in
            if let id = newId {
                viewModel.loadConversation(id)
            }
        }
        #if os(macOS)
        .frame(minWidth: 700, minHeight: 500)
        #endif
    }
    
    private var currentTitle: String {
        if let conversation = conversationStore.currentConversation {
            return conversation.title
        }
        return "Model Explorer"
    }
    
    #if os(macOS)
    private var serverToggle: some View {
        HStack {
            if isServerRunning {
                Link("localhost:\(serverPort)", destination: URL(string: "http://localhost:\(serverPort)")!)
                    .font(.caption.monospaced())
            }
            
            Toggle(isOn: $isServerRunning) {
                Label(
                    isServerRunning ? "Server Running" : "Start Server",
                    systemImage: isServerRunning ? "server.rack" : "play.circle"
                )
            }
            .toggleStyle(.button)
            .onChange(of: isServerRunning) { _, newValue in
                Task {
                    await toggleServer(running: newValue)
                }
            }
        }
    }
    
    private func toggleServer(running: Bool) async {
        if running {
            do {
                try await WebServerManager.shared.start(port: serverPort)
            } catch {
                isServerRunning = false
                print("Failed to start server: \(error)")
            }
        } else {
            await WebServerManager.shared.stop()
        }
    }
    #endif
}
