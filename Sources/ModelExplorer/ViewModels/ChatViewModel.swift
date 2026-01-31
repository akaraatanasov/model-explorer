import SwiftUI
import Shared

@Observable
@MainActor
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let modelService = FoundationModelService.shared
    private let conversationStore = ConversationStore.shared
    
    var currentConversationId: UUID? {
        conversationStore.currentConversationId
    }
    
    var isAvailable: Bool {
        modelService.isAvailable
    }
    
    var availabilityStatus: ModelAvailabilityStatus {
        modelService.availabilityStatus
    }
    
    init() {
        // Load messages from current conversation if exists
        if let conversation = conversationStore.currentConversation {
            messages = conversation.messages
        }
    }
    
    func loadConversation(_ id: UUID) {
        if let conversation = conversationStore.conversations.first(where: { $0.id == id }) {
            messages = conversation.messages
            conversationStore.currentConversationId = id
        }
    }
    
    func newConversation() {
        let conversation = conversationStore.createConversation()
        messages = []
        modelService.resetSession()
        conversationStore.currentConversationId = conversation.id
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Ensure we have a conversation
        var conversationId = currentConversationId
        if conversationId == nil {
            let conversation = conversationStore.createConversation()
            conversationId = conversation.id
        }
        
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        conversationStore.addMessage(userMessage, to: conversationId!)
        
        inputText = ""
        isLoading = true
        errorMessage = nil
        
        // Add placeholder for assistant response
        let assistantMessage = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMessage)
        conversationStore.addMessage(assistantMessage, to: conversationId!)
        let assistantIndex = messages.count - 1
        
        do {
            _ = try await modelService.streamResponse(text) { [weak self] partialContent in
                guard let self else { return }
                messages[assistantIndex] = ChatMessage(
                    id: assistantMessage.id,
                    role: .assistant,
                    content: partialContent,
                    timestamp: assistantMessage.timestamp
                )
                // Update stored message
                conversationStore.updateLastMessage(in: conversationId!, content: partialContent)
            }
        } catch {
            messages.removeLast()
            // Remove the failed message from store
            if var conversation = conversationStore.currentConversation {
                conversation.messages.removeLast()
                conversationStore.updateConversation(conversation)
            }
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearChat() {
        if let id = currentConversationId {
            conversationStore.deleteConversation(id)
        }
        messages = []
        modelService.resetSession()
        errorMessage = nil
    }
}
