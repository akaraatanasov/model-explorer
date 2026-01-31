import SwiftUI

struct InputBar: View {
    @Binding var text: String
    let isLoading: Bool
    let isDisabled: Bool
    let onSend: () -> Void
    var onStop: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Text input with rounded background
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Message", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...8)
                    .disabled(isDisabled)
                    .focused($isFocused)
                    .onSubmit {
                        if canSend && !isLoading {
                            onSend()
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.leading, 16)
                
                // Send or Stop button inside the input area
                Group {
                    if isLoading {
                        stopButton
                    } else {
                        sendButton
                    }
                }
                .padding(.trailing, 6)
                .padding(.bottom, 6)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.secondary.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        #if os(macOS)
        .background(.background)
        #else
        .background(.ultraThinMaterial)
        #endif
    }
    
    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(canSend ? .blue : .secondary.opacity(0.3))
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .animation(.easeInOut(duration: 0.15), value: canSend)
    }
    
    private var stopButton: some View {
        Button {
            onStop?()
        } label: {
            Image(systemName: "stop.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(.red)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && !isDisabled
    }
}
