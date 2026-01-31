import SwiftUI
import Shared

// MARK: - Platform Colors

extension Color {
    static var bubbleGray: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(uiColor: .systemGray5)
        #endif
    }
    
    static var inputBackground: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(uiColor: .systemGray6)
        #endif
    }
    
    static var codeBackground: Color {
        #if os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(uiColor: .systemGray6)
        #endif
    }
    
    static var codeHeader: Color {
        #if os(macOS)
        Color(nsColor: .separatorColor)
        #else
        Color(uiColor: .systemGray4)
        #endif
    }
    
    static var typingDot: Color {
        #if os(macOS)
        Color(nsColor: .tertiaryLabelColor)
        #else
        Color(uiColor: .systemGray3)
        #endif
    }
    
    static var disabledButton: Color {
        #if os(macOS)
        Color(nsColor: .tertiaryLabelColor)
        #else
        Color(uiColor: .systemGray4)
        #endif
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    @State private var showCopyConfirmation = false
    
    private var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Group {
                    if isUser {
                        Text(message.content)
                            .foregroundStyle(.white)
                    } else {
                        MarkdownText(message.content)
                            .foregroundStyle(.primary)
                    }
                }
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleColor, in: bubbleShape)
                .contextMenu {
                    Button {
                        copyToClipboard()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
            
            if !isUser { Spacer(minLength: 60) }
        }
    }
    
    private var bubbleShape: some InsettableShape {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }
    
    private var bubbleColor: Color {
        isUser ? .blue : .bubbleGray
    }
    
    private func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.content, forType: .string)
        #else
        UIPasteboard.general.string = message.content
        #endif
    }
}

// MARK: - Markdown Text Renderer

struct MarkdownText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(parseBlocks().enumerated()), id: \.offset) { _, block in
                switch block {
                case .paragraph(let content):
                    Text(parseInlineMarkdown(content))
                        .font(.body)
                case .code(let code, let language):
                    CodeBlockView(code: code, language: language)
                case .bulletList(let items):
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .foregroundStyle(.secondary)
                                Text(parseInlineMarkdown(item))
                            }
                        }
                    }
                case .numberedList(let items):
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 6) {
                                Text("\(index + 1).")
                                    .foregroundStyle(.secondary)
                                    .frame(minWidth: 18, alignment: .trailing)
                                Text(parseInlineMarkdown(item))
                            }
                        }
                    }
                case .heading(let level, let content):
                    Text(content)
                        .font(headingFont(level: level))
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func headingFont(level: Int) -> Font {
        switch level {
        case 1: return .title3
        case 2: return .headline
        default: return .subheadline
        }
    }
    
    private enum Block {
        case paragraph(String)
        case code(String, language: String?)
        case bulletList([String])
        case numberedList([String])
        case heading(Int, String)
    }
    
    private func parseBlocks() -> [Block] {
        var blocks: [Block] = []
        var currentParagraph = ""
        var inCodeBlock = false
        var codeContent = ""
        var codeLanguage: String?
        var bulletItems: [String] = []
        var numberedItems: [String] = []
        
        let lines = text.components(separatedBy: "\n")
        
        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    blocks.append(.code(codeContent.trimmingCharacters(in: .whitespacesAndNewlines), language: codeLanguage))
                    codeContent = ""
                    codeLanguage = nil
                    inCodeBlock = false
                } else {
                    if !currentParagraph.isEmpty {
                        blocks.append(.paragraph(currentParagraph.trimmingCharacters(in: .whitespacesAndNewlines)))
                        currentParagraph = ""
                    }
                    flushLists(&blocks, &bulletItems, &numberedItems)
                    inCodeBlock = true
                    let lang = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    codeLanguage = lang.isEmpty ? nil : lang
                }
                continue
            }
            
            if inCodeBlock {
                codeContent += line + "\n"
                continue
            }
            
            if line.hasPrefix("#") {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.trimmingCharacters(in: .whitespacesAndNewlines)))
                    currentParagraph = ""
                }
                flushLists(&blocks, &bulletItems, &numberedItems)
                
                var level = 0
                for char in line {
                    if char == "#" { level += 1 }
                    else { break }
                }
                let content = String(line.dropFirst(level)).trimmingCharacters(in: .whitespaces)
                blocks.append(.heading(level, content))
                continue
            }
            
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.trimmingCharacters(in: .whitespacesAndNewlines)))
                    currentParagraph = ""
                }
                if !numberedItems.isEmpty {
                    blocks.append(.numberedList(numberedItems))
                    numberedItems = []
                }
                bulletItems.append(String(trimmed.dropFirst(2)))
                continue
            }
            
            if let match = trimmed.firstMatch(of: /^\d+\.\s+(.+)/) {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.trimmingCharacters(in: .whitespacesAndNewlines)))
                    currentParagraph = ""
                }
                if !bulletItems.isEmpty {
                    blocks.append(.bulletList(bulletItems))
                    bulletItems = []
                }
                numberedItems.append(String(match.1))
                continue
            }
            
            flushLists(&blocks, &bulletItems, &numberedItems)
            
            if trimmed.isEmpty {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.trimmingCharacters(in: .whitespacesAndNewlines)))
                    currentParagraph = ""
                }
            } else {
                currentParagraph += (currentParagraph.isEmpty ? "" : " ") + line
            }
        }
        
        flushLists(&blocks, &bulletItems, &numberedItems)
        if !currentParagraph.isEmpty {
            blocks.append(.paragraph(currentParagraph.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        
        return blocks
    }
    
    private func flushLists(_ blocks: inout [Block], _ bulletItems: inout [String], _ numberedItems: inout [String]) {
        if !bulletItems.isEmpty {
            blocks.append(.bulletList(bulletItems))
            bulletItems = []
        }
        if !numberedItems.isEmpty {
            blocks.append(.numberedList(numberedItems))
            numberedItems = []
        }
    }
    
    private func parseInlineMarkdown(_ text: String) -> AttributedString {
        if let attributed = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            return attributed
        }
        return AttributedString(text)
    }
}

// MARK: - Code Block View

struct CodeBlockView: View {
    let code: String
    let language: String?
    @State private var copied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(language ?? "code")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    copyCode()
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption2)
                        .foregroundStyle(copied ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.codeHeader)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(10)
            }
        }
        .background(Color.codeBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private func copyCode() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #else
        UIPasteboard.general.string = code
        #endif
        
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}
