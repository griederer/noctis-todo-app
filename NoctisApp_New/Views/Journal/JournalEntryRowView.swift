import SwiftUI

struct JournalEntryRowView: View {
    let entry: JournalEntry
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private var previewText: String {
        String(entry.content.prefix(100))
    }
    
    private var wordCount: Int {
        entry.content.split(separator: " ").count
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header with title and date
                HStack {
                    Text(entry.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextPrimary"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                // Content preview
                if !entry.content.isEmpty {
                    Text(previewText + (entry.content.count > 100 ? "..." : ""))
                        .font(.body)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Footer with mood, tags, and metadata
                HStack {
                    // Mood indicator
                    if let mood = entry.mood {
                        HStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .font(.caption)
                                .foregroundColor(mood.color)
                            
                            Text(mood.displayName)
                                .font(.caption2)
                                .foregroundColor(Color("TextSecondary"))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(mood.color.opacity(0.2))
                        )
                    }
                    
                    // Tags (show first 2)
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundColor(Color("Primary"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color("Primary").opacity(0.2))
                            )
                    }
                    
                    if entry.tags.count > 2 {
                        Text("+\(entry.tags.count - 2)")
                            .font(.caption2)
                            .foregroundColor(Color("TextTertiary"))
                    }
                    
                    Spacer()
                    
                    // Word count
                    HStack(spacing: 2) {
                        Image(systemName: "text.alignleft")
                            .font(.caption2)
                            .foregroundColor(Color("TextTertiary"))
                        
                        Text("\(wordCount)")
                            .font(.caption2)
                            .foregroundColor(Color("TextTertiary"))
                    }
                    
                    // Modified indicator
                    if entry.updatedAt > entry.createdAt {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption2)
                            .foregroundColor(Color("TextTertiary"))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Primary").opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            contextMenuItems
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions
        }
    }
    
    // MARK: - Context Menu
    private var contextMenuItems: some View {
        Group {
            Button(action: onTap) {
                Label("Read Entry", systemImage: "eye")
            }
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            if !entry.tags.isEmpty {
                Menu("Tags") {
                    ForEach(entry.tags, id: \.self) { tag in
                        Button("#\(tag)") {
                            // Could implement tag filtering here
                        }
                    }
                }
            }
            
            Divider()
            
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Swipe Actions
    private var swipeActions: some View {
        Group {
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        JournalEntryRowView(
            entry: JournalEntry(
                title: "Morning Reflections",
                content: "Today started with a beautiful sunrise. I feel grateful for the opportunities ahead and excited about the projects I'm working on. The weather is perfect for a walk in the park.",
                mood: .happy,
                tags: ["gratitude", "morning", "nature"]
            ),
            onTap: {},
            onEdit: {},
            onDelete: {}
        )
        
        JournalEntryRowView(
            entry: JournalEntry(
                title: "Busy Day",
                content: "Had a challenging day at work with multiple meetings and deadlines. Feeling a bit overwhelmed but pushing through.",
                mood: .stressed,
                tags: ["work", "challenges"]
            ),
            onTap: {},
            onEdit: {},
            onDelete: {}
        )
    }
    .padding()
    .background(Color("Background"))
    .preferredColorScheme(.dark)
}