import Foundation

/// Provides simulated responses for demo/testing when Foundation Models are unavailable
@MainActor
final class DemoModelService {
    static let shared = DemoModelService()
    
    private init() {}
    
    private let loremParagraphs = [
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "Curabitur pretium tincidunt lacus. Nulla gravida orci a odio. Nullam varius, turpis et commodo pharetra.",
        "Est eros bibendum elit, nec luctus magna felis sollicitudin mauris. Integer in mauris eu nibh euismod gravida.",
        "Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Vestibulum ante ipsum primis in faucibus.",
        "Nulla quis lorem ut libero malesuada feugiat. Vivamus magna justo, lacinia eget consectetur sed, convallis at tellus.",
        "Pellentesque in ipsum id orci porta dapibus. Cras ultricies ligula sed magna dictum porta.",
        "Mauris blandit aliquet elit, eget tincidunt nibh pulvinar a. Donec sollicitudin molestie malesuada."
    ]
    
    /// Generates a random Lorem ipsum response
    func generateResponse() -> String {
        let paragraphCount = Int.random(in: 1...3)
        let selectedParagraphs = (0..<paragraphCount).map { _ in
            loremParagraphs.randomElement()!
        }
        return selectedParagraphs.joined(separator: "\n\n")
    }
    
    /// Streams a response with simulated typing delay
    func streamResponse(_ prompt: String, onPartial: @escaping (String) -> Void) async -> String {
        let fullResponse = generateResponse()
        let words = fullResponse.split(separator: " ")
        var currentContent = ""
        
        for (index, word) in words.enumerated() {
            // Add space before word (except first)
            if index > 0 {
                currentContent += " "
            }
            currentContent += String(word)
            
            onPartial(currentContent)
            
            // Random delay between 20-80ms per word to simulate typing
            let delay = UInt64.random(in: 20_000_000...80_000_000)
            try? await Task.sleep(nanoseconds: delay)
        }
        
        return fullResponse
    }
}
