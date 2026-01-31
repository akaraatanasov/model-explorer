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
                
                // Empty state or message list
                if viewModel.messages.isEmpty {
                    Spacer()
                    EmptyConversationView { suggestion in
                        viewModel.inputText = suggestion
                        Task { await viewModel.sendMessage() }
                    }
                    Spacer()
                } else {
                    messageList
                }
                
                inputArea
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
    }
    
    private var demoBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .foregroundStyle(.orange)
            Text("Demo Mode")
                .fontWeight(.medium)
            Spacer()
            Button("Exit") {
                viewModel.isDemoMode = false
                viewModel.clearChat()
            }
            .font(.caption)
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.inputBackground)
    }
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Message", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.inputBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .focused($isInputFocused)
                    .onSubmit {
                        if canSend && !viewModel.isLoading {
                            Task { await viewModel.sendMessage() }
                        }
                    }
                
                Button {
                    if viewModel.isLoading {
                        viewModel.stopGenerating()
                    } else {
                        Task { await viewModel.sendMessage() }
                    }
                } label: {
                    Image(systemName: viewModel.isLoading ? "stop.fill" : "arrow.up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle().fill(buttonColor)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSend && !viewModel.isLoading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
    
    private var buttonColor: Color {
        if viewModel.isLoading {
            return .red
        }
        return canSend ? .blue : .disabledButton
    }
    
    private var canSend: Bool {
        !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    if viewModel.isLoading,
                       let lastMessage = viewModel.messages.last,
                       lastMessage.role == .user || lastMessage.content.isEmpty {
                        TypingIndicator()
                            .id("typing")
                    }
                    
                    // Invisible anchor at bottom
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                isInputFocused = false
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isInputFocused) { _, focused in
                if focused {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}
