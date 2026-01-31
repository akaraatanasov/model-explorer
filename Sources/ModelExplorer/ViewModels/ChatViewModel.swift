import SwiftUI
import Shared

@Observable
@MainActor
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var isDemoMode: Bool = false
    
    private let modelService = FoundationModelService.shared
    private let demoService = DemoModelService.shared
    private let conversationStore = ConversationStore.shared
    private var currentTask: Task<Void, Never>?
    
    var currentConversationId: UUID? {
        conversationStore.currentConversationId
    }
    
    var isAvailable: Bool {
        modelService.isAvailable
    }
    
    var availabilityStatus: ModelAvailabilityStatus {
        modelService.availabilityStatus
    }
    
    /// Returns true if we should use demo mode (model unavailable but user wants to test UI)
    var shouldUseDemoMode: Bool {
        !isAvailable && isDemoMode
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
        
        // Use demo mode if model unavailable and demo mode is enabled
        if shouldUseDemoMode {
            _ = await demoService.streamResponse(text) { [weak self] partialContent in
                guard let self else { return }
                messages[assistantIndex] = ChatMessage(
                    id: assistantMessage.id,
                    role: .assistant,
                    content: partialContent,
                    timestamp: assistantMessage.timestamp
                )
                conversationStore.updateLastMessage(in: conversationId!, content: partialContent)
            }
            isLoading = false
            return
        }
        
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
            
            // Provide more descriptive error messages
            if ModelAvailabilityStatus.isSimulator {
                errorMessage = "Foundation Models cannot run in the iOS Simulator. Please use a physical device or run on macOS."
            } else if "\(error)".contains("GenerationError") || "\(error)".contains("modelcatalog") {
                errorMessage = "The on-device AI model is not available. This may happen on simulators, virtual machines, or if Apple Intelligence is not set up. Please check Settings > Apple Intelligence & Siri."
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func stopGenerating() {
        currentTask?.cancel()
        currentTask = nil
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
