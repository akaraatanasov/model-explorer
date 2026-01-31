import SwiftUI

struct ConversationSidebar: View {
    @ObservedObject var store: ConversationStore
    let onNewConversation: () -> Void
    @State private var searchText = ""
    
    private var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return store.conversations
        }
        return store.conversations.filter { conversation in
            conversation.title.localizedCaseInsensitiveContains(searchText) ||
            conversation.messages.contains { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var groupedConversations: [(String, [Conversation])] {
        let grouped = Dictionary(grouping: filteredConversations) { conversation in
            relativeDate(for: conversation.updatedAt)
        }
        
        let order = ["Today", "Yesterday", "This Week", "Last Week", "This Month", "Older"]
        return order.compactMap { key in
            if let conversations = grouped[key], !conversations.isEmpty {
                return (key, conversations)
            }
            return nil
        }
    }
    
    var body: some View {
        List(selection: $store.currentConversationId) {
            Section {
                Button(action: onNewConversation) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                        Text("New Chat")
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            
            ForEach(groupedConversations, id: \.0) { section, conversations in
                Section(section) {
                    ForEach(conversations) { conversation in
                        ConversationRow(conversation: conversation)
                            .tag(conversation.id)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        store.deleteConversation(conversation.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    store.deleteConversation(conversation.id)
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $searchText, prompt: "Search conversations")
        #if os(macOS)
        .frame(minWidth: 220)
        #endif
    }
    
    private func relativeDate(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                  date > weekAgo {
            return "This Week"
        } else if let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now),
                  date > twoWeeksAgo {
            return "Last Week"
        } else if let monthAgo = calendar.date(byAdding: .month, value: -1, to: now),
                  date > monthAgo {
            return "This Month"
        } else {
            return "Older"
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    private var previewText: String {
        if let lastMessage = conversation.messages.last {
            let text = lastMessage.content.prefix(100)
            return String(text) + (lastMessage.content.count > 100 ? "..." : "")
        }
        return "No messages"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(conversation.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                Text(shortDate(conversation.updatedAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Text(previewText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 6)
    }
    
    private func shortDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
