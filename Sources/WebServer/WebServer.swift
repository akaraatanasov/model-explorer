import Foundation
import Hummingbird
import Shared

public actor WebServerManager {
    public static let shared = WebServerManager()
    
    private var serverTask: Task<Void, Error>?
    
    private init() {}
    
    public var isRunning: Bool {
        serverTask != nil
    }
    
    public func start(port: UInt16 = 8080) async throws {
        guard !isRunning else { return }
        
        let router = Router()
        
        // Serve static files
        router.get("/") { _, _ in
            Response(
                status: .ok,
                headers: [.contentType: "text/html"],
                body: .init(byteBuffer: .init(string: WebResources.indexHTML))
            )
        }
        
        router.get("/style.css") { _, _ in
            Response(
                status: .ok,
                headers: [.contentType: "text/css"],
                body: .init(byteBuffer: .init(string: WebResources.styleCSS))
            )
        }
        
        router.get("/app.js") { _, _ in
            Response(
                status: .ok,
                headers: [.contentType: "application/javascript"],
                body: .init(byteBuffer: .init(string: WebResources.appJS))
            )
        }
        
        // API routes
        router.post("/api/chat") { request, context in
            try await APIRoutes.handleChat(request: request, context: context)
        }
        
        router.post("/api/stream") { request, context in
            try await APIRoutes.handleStreamChat(request: request, context: context)
        }
        
        router.get("/api/status") { _, _ in
            try await APIRoutes.handleStatus()
        }
        
        let app = Application(
            router: router,
            configuration: .init(address: .hostname("127.0.0.1", port: Int(port)))
        )
        
        serverTask = Task.detached {
            try await app.run()
        }
        
        // Give server a moment to start
        try await Task.sleep(for: .milliseconds(100))
        print("Web server started at http://localhost:\(port)")
    }
    
    public func stop() async {
        serverTask?.cancel()
        serverTask = nil
        print("Web server stopped")
    }
}
