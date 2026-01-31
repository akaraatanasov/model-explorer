import Foundation
import Shared

/// Represents a saved conversation with metadata
public struct Conversation: Identifiable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public var messages: [ChatMessage]
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(id: UUID = UUID(), title: String = "New Conversation", messages: [ChatMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Generate a title from the first user message
    public mutating func generateTitle() {
        guard let firstUserMessage = messages.first(where: { $0.role == .user }) else { return }
        let content = firstUserMessage.content
        let maxLength = 50
        if content.count <= maxLength {
            title = content
        } else {
            title = String(content.prefix(maxLength)) + "..."
        }
    }
}

/// Manages persistent storage of conversations
@MainActor
public final class ConversationStore: ObservableObject {
    public static let shared = ConversationStore()
    
    @Published public private(set) var conversations: [Conversation] = []
    @Published public var currentConversationId: UUID?
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public var currentConversation: Conversation? {
        get {
            guard let id = currentConversationId else { return nil }
            return conversations.first { $0.id == id }
        }
        set {
            if let newValue {
                if let index = conversations.firstIndex(where: { $0.id == newValue.id }) {
                    conversations[index] = newValue
                }
            }
        }
    }
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        loadConversations()
    }
    
    // MARK: - File Paths
    
    private var conversationsDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("ModelExplorer/Conversations", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    private func fileURL(for id: UUID) -> URL {
        conversationsDirectory.appendingPathComponent("\(id.uuidString).json")
    }
    
    // MARK: - CRUD Operations
    
    public func createConversation() -> Conversation {
        let conversation = Conversation()
        conversations.insert(conversation, at: 0)
        currentConversationId = conversation.id
        saveConversation(conversation)
        return conversation
    }
    
    public func updateConversation(_ conversation: Conversation) {
        var updated = conversation
        updated.updatedAt = Date()
        
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = updated
        }
        
        saveConversation(updated)
    }
    
    public func deleteConversation(_ id: UUID) {
        conversations.removeAll { $0.id == id }
        
        let url = fileURL(for: id)
        try? fileManager.removeItem(at: url)
        
        if currentConversationId == id {
            currentConversationId = conversations.first?.id
        }
    }
    
    public func addMessage(_ message: ChatMessage, to conversationId: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        
        conversations[index].messages.append(message)
        conversations[index].updatedAt = Date()
        
        // Auto-generate title from first user message
        if conversations[index].title == "New Conversation" {
            conversations[index].generateTitle()
        }
        
        saveConversation(conversations[index])
    }
    
    public func updateLastMessage(in conversationId: UUID, content: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }),
              !conversations[index].messages.isEmpty else { return }
        
        let lastIndex = conversations[index].messages.count - 1
        let lastMessage = conversations[index].messages[lastIndex]
        
        conversations[index].messages[lastIndex] = ChatMessage(
            id: lastMessage.id,
            role: lastMessage.role,
            content: content,
            timestamp: lastMessage.timestamp
        )
        conversations[index].updatedAt = Date()
        
        saveConversation(conversations[index])
    }
    
    // MARK: - Persistence
    
    private func saveConversation(_ conversation: Conversation) {
        let url = fileURL(for: conversation.id)
        do {
            let data = try encoder.encode(conversation)
            try data.write(to: url)
        } catch {
            print("Failed to save conversation: \(error)")
        }
    }
    
    private func loadConversations() {
        do {
            let files = try fileManager.contentsOfDirectory(at: conversationsDirectory, includingPropertiesForKeys: nil)
            conversations = files
                .filter { $0.pathExtension == "json" }
                .compactMap { url -> Conversation? in
                    guard let data = try? Data(contentsOf: url) else { return nil }
                    return try? decoder.decode(Conversation.self, from: data)
                }
                .sorted { $0.updatedAt > $1.updatedAt }
            
            currentConversationId = conversations.first?.id
        } catch {
            // Directory might not exist yet
            conversations = []
        }
    }
    
    public func clearAllConversations() {
        for conversation in conversations {
            try? fileManager.removeItem(at: fileURL(for: conversation.id))
        }
        conversations = []
        currentConversationId = nil
    }
}
