import Foundation
import Hummingbird
import FoundationModels
import NIOCore
import Shared

struct ChatRequest: Codable {
    let message: String
}

struct ChatResponse: Codable {
    let response: String
    let timestamp: Date
}

struct StatusResponse: Codable {
    let available: Bool
    let message: String
    let reason: String?
}

struct SSEEvent: Codable {
    let type: String  // "content", "done", "error"
    let content: String?
    let timestamp: Date?
}

enum APIRoutes {
    static func handleChat(request: Request, context: some RequestContext) async throws -> Response {
        let body = try await request.body.collect(upTo: 1024 * 1024) // 1MB limit
        let chatRequest = try JSONDecoder().decode(ChatRequest.self, from: body)
        
        guard SystemLanguageModel.default.isAvailable else {
            let errorResponse = ChatResponse(
                response: "Apple Foundation Models are not available on this device.",
                timestamp: Date()
            )
            let data = try JSONEncoder().encode(errorResponse)
            return Response(
                status: .serviceUnavailable,
                headers: [.contentType: "application/json"],
                body: .init(byteBuffer: .init(data: data))
            )
        }
        
        let session = LanguageModelSession()
        let response = try await session.respond(to: chatRequest.message)
        
        let chatResponse = ChatResponse(
            response: response.content,
            timestamp: Date()
        )
        
        let data = try JSONEncoder().encode(chatResponse)
        return Response(
            status: .ok,
            headers: [.contentType: "application/json"],
            body: .init(byteBuffer: .init(data: data))
        )
    }
    
    static func handleStreamChat(request: Request, context: some RequestContext) async throws -> Response {
        let body = try await request.body.collect(upTo: 1024 * 1024)
        let chatRequest = try JSONDecoder().decode(ChatRequest.self, from: body)
        
        guard SystemLanguageModel.default.isAvailable else {
            return Response(
                status: .serviceUnavailable,
                headers: [
                    .contentType: "text/event-stream",
                    .cacheControl: "no-cache",
                    .connection: "keep-alive"
                ],
                body: .init(byteBuffer: .init(string: formatSSE(SSEEvent(type: "error", content: "Apple Foundation Models are not available", timestamp: Date()))))
            )
        }
        
        let message = chatRequest.message
        
        let responseStream = AsyncStream<ByteBuffer> { continuation in
            Task { @Sendable in
                do {
                    let session = LanguageModelSession()
                    let stream = session.streamResponse(to: message)
                    
                    for try await partial in stream {
                        let event = SSEEvent(type: "content", content: partial.content, timestamp: nil)
                        let sseData = formatSSE(event)
                        continuation.yield(ByteBuffer(string: sseData))
                    }
                    
                    // Send done event
                    let doneEvent = SSEEvent(type: "done", content: nil, timestamp: Date())
                    continuation.yield(ByteBuffer(string: formatSSE(doneEvent)))
                    continuation.finish()
                } catch {
                    let errorEvent = SSEEvent(type: "error", content: error.localizedDescription, timestamp: Date())
                    continuation.yield(ByteBuffer(string: formatSSE(errorEvent)))
                    continuation.finish()
                }
            }
        }
        
        return Response(
            status: .ok,
            headers: [
                .contentType: "text/event-stream",
                .cacheControl: "no-cache",
                .connection: "keep-alive"
            ],
            body: .init(asyncSequence: responseStream)
        )
    }
    
    static func handleStatus() async throws -> Response {
        let availability = SystemLanguageModel.default.availability
        let (available, reason): (Bool, String?) = switch availability {
        case .available:
            (true, nil)
        case .unavailable(let r):
            (false, describeReason(r))
        }
        
        let status = StatusResponse(
            available: available,
            message: available
                ? "Apple Foundation Models are available"
                : "Apple Foundation Models are not available",
            reason: reason
        )
        
        let data = try JSONEncoder().encode(status)
        return Response(
            status: .ok,
            headers: [.contentType: "application/json"],
            body: .init(byteBuffer: .init(data: data))
        )
    }
    
    private static func describeReason(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "Device not eligible (requires Apple Silicon, cannot run in VM)"
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled in System Settings"
        case .modelNotReady:
            return "Models are still downloading or being prepared"
        @unknown default:
            return "Unknown reason"
        }
    }
    
    private static func formatSSE(_ event: SSEEvent) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(event),
              let json = String(data: data, encoding: .utf8) else {
            return "data: {\"type\":\"error\",\"content\":\"Encoding failed\"}\n\n"
        }
        return "data: \(json)\n\n"
    }
}
