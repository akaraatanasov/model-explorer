import SwiftUI
import Shared

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.shouldUseDemoMode || viewModel.isAvailable {
                // Demo mode banner
                if viewModel.isDemoMode {
                    demoBanner
                }
                
                messageList
                
                Divider()
                
                InputBar(
                    text: $viewModel.inputText,
                    isLoading: viewModel.isLoading,
                    isDisabled: false,
                    onSend: { Task { await viewModel.sendMessage() } }
                )
                .focused($isInputFocused)
            } else {
                ModelUnavailableView(status: viewModel.availabilityStatus) {
                    viewModel.isDemoMode = true
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onAppear { isInputFocused = true }
    }
    
    private var demoBanner: some View {
        HStack {
            Image(systemName: "theatermask.and.paintbrush")
            Text("Demo Mode")
                .fontWeight(.medium)
            Text("— Responses are simulated Lorem ipsum text")
                .foregroundStyle(.secondary)
            Spacer()
            Button("Exit") {
                viewModel.isDemoMode = false
                viewModel.clearChat()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .font(.caption)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.yellow.opacity(0.2))
    }
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}
