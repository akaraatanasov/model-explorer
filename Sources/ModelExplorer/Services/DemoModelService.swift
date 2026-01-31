import Foundation

/// Provides simulated responses for demo/testing when Foundation Models are unavailable
@MainActor
final class DemoModelService {
    static let shared = DemoModelService()
    
    private init() {}
    
    private let demoResponses = [
        // Simple text responses
        """
        That's a great question! Let me break this down for you.
        
        The key points to consider are:
        - First, understand the basic concepts
        - Then, apply them to your specific situation
        - Finally, iterate and refine your approach
        
        Would you like me to elaborate on any of these points?
        """,
        
        // Response with code block
        """
        Here's how you could implement that in Swift:
        
        ```swift
        func greet(name: String) -> String {
            return "Hello, \\(name)!"
        }
        
        let message = greet(name: "World")
        print(message)
        ```
        
        This function takes a name as input and returns a personalized greeting. The `\\()` syntax is Swift's string interpolation.
        """,
        
        // Response with markdown formatting
        """
        # Understanding the Basics
        
        Here's a quick overview of the **key concepts** you should know:
        
        1. **Variables** - Store data that can change
        2. **Constants** - Store data that stays the same
        3. **Functions** - Reusable blocks of code
        
        > Pro tip: Always use `let` instead of `var` when the value won't change.
        
        For more details, check out the official documentation.
        """,
        
        // List-heavy response
        """
        Great idea! Here are some suggestions:
        
        **Pros:**
        - Easy to implement
        - Well-documented
        - Active community support
        
        **Cons:**
        - Steeper learning curve initially
        - Requires some setup time
        
        I'd recommend starting with the basics and building up from there. Let me know if you'd like specific examples!
        """,
        
        // Short conversational response
        """
        Absolutely! That's a common approach and works well for most use cases.
        
        The main thing to keep in mind is that you'll want to handle edge cases gracefully. A simple `guard` statement can help with that.
        """,
        
        // Technical explanation
        """
        This is a classic example of the *observer pattern*.
        
        ```swift
        protocol Observer {
            func update(_ value: Any)
        }
        
        class Subject {
            private var observers: [Observer] = []
            
            func attach(_ observer: Observer) {
                observers.append(observer)
            }
        }
        ```
        
        The pattern allows objects to be notified of state changes without tight coupling between components.
        """
    ]
    
    /// Generates a random demo response
    func generateResponse() -> String {
        demoResponses.randomElement()!
    }
    
    /// Streams a response with simulated typing delay
    func streamResponse(_ prompt: String, onPartial: @escaping (String) -> Void) async -> String {
        let fullResponse = generateResponse()
        var currentContent = ""
        
        // Stream character by character for more realistic effect
        for char in fullResponse {
            currentContent.append(char)
            onPartial(currentContent)
            
            // Variable delay based on character type
            let delay: UInt64
            if char == "\n" {
                delay = 50_000_000 // 50ms for newlines
            } else if char == " " {
                delay = 15_000_000 // 15ms for spaces
            } else {
                delay = UInt64.random(in: 8_000_000...25_000_000) // 8-25ms for chars
            }
            
            try? await Task.sleep(nanoseconds: delay)
            
            // Check for cancellation
            if Task.isCancelled { break }
        }
        
        return fullResponse
    }
}
