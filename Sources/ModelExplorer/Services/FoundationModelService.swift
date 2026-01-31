import Foundation
import FoundationModels
import Shared

@MainActor
public final class FoundationModelService: Sendable {
    public static let shared = FoundationModelService()
    
    private var session: LanguageModelSession?
    
    private init() {}
    
    public var availabilityStatus: ModelAvailabilityStatus {
        ModelAvailabilityStatus()
    }
    
    public var isAvailable: Bool {
        availabilityStatus.isAvailable
    }
    
    public func createSession() throws -> LanguageModelSession {
        let status = availabilityStatus
        guard status.isAvailable else {
            throw FoundationModelError.unavailable(status)
        }
        let session = LanguageModelSession()
        self.session = session
        return session
    }
    
    public func send(_ prompt: String) async throws -> String {
        let session = try session ?? createSession()
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    /// Streams a response, calling the handler with each partial result
    public func streamResponse(_ prompt: String, onPartial: @escaping (String) -> Void) async throws -> String {
        let session = try session ?? createSession()
        let stream = session.streamResponse(to: prompt)
        var finalContent = ""
        
        for try await partial in stream {
            finalContent = partial.content
            onPartial(finalContent)
        }
        
        return finalContent
    }
    
    public func resetSession() {
        session = nil
    }
}

public enum FoundationModelError: LocalizedError {
    case unavailable(ModelAvailabilityStatus)
    case sessionFailed
    
    public var errorDescription: String? {
        switch self {
        case .unavailable(let status):
            return "\(status.title): \(status.message)"
        case .sessionFailed:
            return "Failed to create language model session."
        }
    }
}
