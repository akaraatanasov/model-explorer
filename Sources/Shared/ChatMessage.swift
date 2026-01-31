import Foundation

public struct ChatMessage: Identifiable, Codable, Sendable {
    public let id: UUID
    public let role: Role
    public var content: String
    public let timestamp: Date
    
    public enum Role: String, Codable, Sendable {
        case user
        case assistant
        case system
    }
    
    public init(id: UUID = UUID(), role: Role, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}
