import SwiftUI

struct TypingIndicator: View {
    @State private var animationPhase = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.typingDot)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.4), value: animationPhase)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.bubbleGray, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            
            Spacer(minLength: 60)
        }
        .onAppear { startAnimation() }
        .onDisappear { stopAnimation() }
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            Task { @MainActor in
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

struct EmptyConversationView: View {
    let onSuggestionTapped: (String) -> Void
    
    private let suggestions = [
        "What's the weather like today?",
        "Tell me a fun fact",
        "Help me write an email",
        "Explain something complex"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                
                Text("Start a conversation")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSuggestionTapped(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.inputBackground, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Typing Indicator") {
    TypingIndicator()
        .padding()
}

#Preview("Empty State") {
    EmptyConversationView { prompt in
        print("Selected: \(prompt)")
    }
}
