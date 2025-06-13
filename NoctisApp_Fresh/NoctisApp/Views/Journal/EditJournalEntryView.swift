import SwiftUI

struct EditJournalEntryView: View {
    let entry: JournalEntry
    let viewModel: JournalListViewModel
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: Mood?
    @State private var tags: [String] = []
    @State private var tagInput = ""
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isContentFocused: Bool
    
    private var wordCount: Int {
        content.split(separator: " ").count
    }
    
    private var characterCount: Int {
        content.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Entry Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Created")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                            
                            Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                            
                            Spacer()
                            
                            if entry.updatedAt > entry.createdAt {
                                Text("Modified")
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                                
                                Text(entry.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Surface"))
                        )
                    }
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        TextField("Entry title", text: $title)
                            .font(.title3)
                            .foregroundColor(Color("TextPrimary"))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Surface"))
                            )
                    }
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Content")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            
                            Spacer()
                            
                            Text("\\(wordCount) words • \\(characterCount) characters")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                        }
                        
                        TextEditor(text: $content)
                            .font(.body)
                            .foregroundColor(Color("TextPrimary"))
                            .frame(minHeight: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Surface"))
                            )
                            .focused($isContentFocused)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isContentFocused ? Color("Primary") : Color.clear, lineWidth: 2)
                            )
                    }
                    
                    // Mood Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How are you feeling?")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                moodButton(mood)
                            }
                        }
                    }
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        
                        // Tag input
                        HStack {
                            TextField("Add a tag...", text: $tagInput)
                                .foregroundColor(Color("TextPrimary"))
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button("Add") {
                                addTag()
                            }
                            .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .foregroundColor(Color("Primary"))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Surface"))
                        )
                        
                        // Current tags
                        if !tags.isEmpty {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    tagChip(tag)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Save Changes") {
                            saveEntry()
                        }
                        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Divider()
                        
                        Button("Delete Entry", role: .destructive) {
                            deleteEntry()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color("Primary"))
                    }
                }
            }
            .background(Color("Background"))
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupInitialValues()
            AnalyticsService.shared.trackScreen("Edit Journal Entry")
        }
    }
    
    // MARK: - Setup
    private func setupInitialValues() {
        title = entry.title
        content = entry.content
        selectedMood = entry.mood
        tags = entry.tags
    }
    
    // MARK: - Mood Button
    private func moodButton(_ mood: Mood) -> some View {
        Button(action: {
            selectedMood = selectedMood == mood ? nil : mood
        }) {
            VStack(spacing: 6) {
                Image(systemName: mood.icon)
                    .font(.title2)
                    .foregroundColor(selectedMood == mood ? .white : mood.color)
                
                Text(mood.displayName)
                    .font(.caption)
                    .foregroundColor(selectedMood == mood ? .white : Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedMood == mood ? mood.color : Color("Surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(mood.color.opacity(0.3), lineWidth: selectedMood == mood ? 0 : 1)
            )
            .scaleEffect(selectedMood == mood ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: selectedMood)
    }
    
    // MARK: - Tag Chip
    private func tagChip(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text("#\\(tag)")
                .font(.caption)
                .foregroundColor(Color("Primary"))
            
            Button(action: {
                removeTag(tag)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color("Primary").opacity(0.2))
        )
    }
    
    // MARK: - Actions
    private func addTag() {
        let trimmedTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmedTag.isEmpty && !tags.contains(trimmedTag) else {
            return
        }
        
        tags.append(trimmedTag)
        tagInput = ""
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveEntry() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = title.isEmpty ? "Journal Entry" : title
        
        guard !trimmedContent.isEmpty else { return }
        
        viewModel.updateEntry(
            entry,
            title: finalTitle,
            content: trimmedContent,
            mood: selectedMood,
            tags: tags
        )
        
        dismiss()
    }
    
    private func deleteEntry() {
        viewModel.deleteEntry(entry)
        dismiss()
    }
}

#Preview {
    EditJournalEntryView(
        entry: JournalEntry(
            title: "Sample Entry",
            content: "This is a sample journal entry with some content to edit.",
            mood: .happy,
            tags: ["sample", "preview"]
        ),
        viewModel: JournalListViewModel()
    )
}