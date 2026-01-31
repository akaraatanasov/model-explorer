import SwiftUI

struct ConversationSidebar: View {
    @ObservedObject var store: ConversationStore
    let onNewConversation: () -> Void
    
    var body: some View {
        List(selection: $store.currentConversationId) {
            Section {
                Button(action: onNewConversation) {
                    Label("New Chat", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
            
            Section("Conversations") {
                ForEach(store.conversations) { conversation in
                    ConversationRow(conversation: conversation)
                        .tag(conversation.id)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                store.deleteConversation(conversation.id)
                            }
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        store.deleteConversation(store.conversations[index].id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        #if os(macOS)
        .frame(minWidth: 200)
        #endif
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.title)
                .font(.body)
                .lineLimit(1)
            
            HStack {
                Text(conversation.updatedAt, style: .relative)
                Text("•")
                Text("\(conversation.messages.count) messages")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
