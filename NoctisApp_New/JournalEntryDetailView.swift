import SwiftUI

struct JournalEntryDetailView: View {
    let entry: JournalEntry
    let viewModel: JournalListViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    private var wordCount: Int {
        entry.content.split(separator: " ").count
    }
    
    private var readingTime: Int {
        max(1, wordCount / 200) // Assuming 200 words per minute reading speed
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with title and metadata
                    headerSection
                    
                    // Mood section
                    if let mood = entry.mood {
                        moodSection(mood)
                    }
                    
                    // Content section
                    contentSection
                    
                    // Tags section
                    if !entry.tags.isEmpty {
                        tagsSection
                    }
                    
                    // Metadata section
                    metadataSection
                }
                .padding()
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.showEditEntry(entry)
                            dismiss()
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            shareEntry()
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            viewModel.deleteEntry(entry)
                            dismiss()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .foregroundColor(.red)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color("Primary"))
                    }
                }
            }
            .background(Color("Background"))
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [shareText])
        }
        .onAppear {
            AnalyticsService.shared.trackScreen("Journal Entry Detail", parameters: [
                "entry_id": entry.id,
                "word_count": wordCount,
                "has_mood": entry.mood != nil,
                "tag_count": entry.tags.count
            ])
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("TextPrimary"))
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(entry.date.formatted(date: .complete, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                
                Spacer()
                
                Text("\\(readingTime) min read")
                    .font(.caption)
                    .foregroundColor(Color("TextTertiary"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color("Surface"))
                    )
            }
        }
    }
    
    // MARK: - Mood Section
    private func moodSection(_ mood: Mood) -> some View {
        HStack(spacing: 12) {
            Image(systemName: mood.icon)
                .font(.title2)
                .foregroundColor(mood.color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(mood.color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Mood")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
                
                Text(mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("TextPrimary"))
            }
            
            Spacer()
            
            Text(mood.emoji)
                .font(.title)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Content")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Text("\\(wordCount) words")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
            }
            
            Text(entry.content)
                .font(.body)
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(entry.tags, id: \\.self) { tag in
                    Text("#\\(tag)")
                        .font(.caption)
                        .foregroundColor(Color("Primary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color("Primary").opacity(0.2))
                        )
                        .onTapGesture {
                            // Could implement tag filtering here
                        }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Metadata Section
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            VStack(spacing: 8) {
                metadataRow(title: "Created", value: entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                
                if entry.updatedAt > entry.createdAt {
                    metadataRow(title: "Last Modified", value: entry.updatedAt.formatted(date: .abbreviated, time: .shortened))
                }
                
                metadataRow(title: "Word Count", value: "\\(wordCount)")
                metadataRow(title: "Character Count", value: "\\(entry.content.count)")
                metadataRow(title: "Reading Time", value: "\\(readingTime) minute\\(readingTime == 1 ? "" : "s")")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Metadata Row
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color("TextPrimary"))
        }
    }
    
    // MARK: - Share functionality
    private var shareText: String {
        var text = "\\(entry.title)\\n\\n"
        text += entry.content
        
        if let mood = entry.mood {
            text += "\\n\\nMood: \\(mood.displayName) \\(mood.emoji)"
        }
        
        if !entry.tags.isEmpty {
            text += "\\n\\nTags: " + entry.tags.map { "#\\($0)" }.joined(separator: " ")
        }
        
        text += "\\n\\nWritten on \\(entry.createdAt.formatted(date: .complete, time: .omitted))"
        text += "\\n\\nShared from Noctis Journal"
        
        return text
    }
    
    private func shareEntry() {
        showingShareSheet = true
        AnalyticsService.shared.trackCustomEvent(name: "journal_entry_shared", parameters: [
            "entry_id": entry.id,
            "word_count": wordCount
        ])
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    JournalEntryDetailView(
        entry: JournalEntry(
            title: "A Beautiful Morning",
            content: "Today started with a gorgeous sunrise that painted the sky in shades of orange and pink. I took a moment to appreciate the beauty around me and felt grateful for this new day. The birds were singing, and there was a gentle breeze that made everything feel fresh and alive. I realized how important it is to pause and notice these small moments of beauty in our daily lives. They remind us that there's always something to be grateful for, even in the midst of our busy schedules.",
            mood: .grateful,
            tags: ["morning", "gratitude", "nature", "mindfulness"]
        ),
        viewModel: JournalListViewModel()
    )
}