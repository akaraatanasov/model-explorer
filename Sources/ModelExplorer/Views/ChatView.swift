import SwiftUI
import Shared

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.isAvailable {
                ModelUnavailableView(status: viewModel.availabilityStatus)
            } else {
                messageList
                
                Divider()
                
                InputBar(
                    text: $viewModel.inputText,
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.isAvailable,
                    onSend: { Task { await viewModel.sendMessage() } }
                )
                .focused($isInputFocused)
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
