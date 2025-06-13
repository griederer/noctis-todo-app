//
//  JournalView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct JournalView: View {
    @StateObject private var dataStore = SharedDataStore.shared
    @State private var showingEditToday = false
    @State private var editTitle = ""
    @State private var editContent = ""
    @State private var editMood: Mood = .neutral
    @State private var editTags: [String] = []
    @State private var newTag = ""
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                headerView
                journalListView
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingEditToday) {
            editJournalSheet
        }
        .onAppear {
            dataStore.ensureDailyJournalEntry()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Journal")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: editTodayAction) {
                Image(systemName: "pencil")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var journalListView: some View {
        List {
            ForEach(dataStore.journalEntries.sorted { $0.createdAt > $1.createdAt }) { entry in
                JournalEntryRow(entry: entry, dataStore: dataStore)
            }
        }
    }
    
    private var editJournalSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Today's Journal")) {
                    TextField("Title", text: $editTitle)
                        .focused($isInputActive)
                    
                    TextEditor(text: $editContent)
                        .frame(minHeight: 100)
                        .focused($isInputActive)
                    
                    Picker("Mood", selection: $editMood) {
                        ForEach([Mood.veryGood, .good, .neutral, .bad, .veryBad], id: \.self) { mood in
                            HStack {
                                Text(mood.emoji)
                                Text(mood.displayName)
                            }
                            .tag(mood)
                        }
                    }
                }
                
                Section(header: Text("Tags")) {
                    HStack {
                        TextField("Add tag", text: $newTag)
                            .focused($isInputActive)
                            .onSubmit {
                                addTag()
                            }
                        
                        Button("Add") {
                            addTag()
                        }
                        .disabled(newTag.isEmpty)
                    }
                    
                    if !editTags.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(editTags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text("#\(tag)")
                                        .font(.caption)
                                    
                                    Button(action: { removeTag(tag) }) {
                                        Image(systemName: "xmark")
                                            .font(.caption2)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Today's Journal")
            .onTapGesture {
                isInputActive = false
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingEditToday = false
                },
                trailing: Button("Save") {
                    dataStore.updateTodayJournalEntry(
                        title: editTitle,
                        content: editContent,
                        mood: editMood,
                        tags: editTags
                    )
                    showingEditToday = false
                }
                .disabled(editTitle.isEmpty)
            )
        }
        .preferredColorScheme(.light)
    }
    
    private func editTodayAction() {
        if let todayEntry = dataStore.getTodayJournalEntry() {
            editTitle = todayEntry.title
            editContent = todayEntry.content
            editMood = todayEntry.mood ?? .neutral
            editTags = todayEntry.tags
        }
        showingEditToday = true
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !editTags.contains(trimmedTag) {
            editTags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        editTags.removeAll { $0 == tag }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry
    let dataStore: SharedDataStore
    
    var body: some View {
        let isToday = Calendar.current.isDate(entry.createdAt, inSameDayAs: Date())
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(isToday ? .headline : .subheadline)
                    .fontWeight(isToday ? .semibold : .regular)
                
                Spacer()
                
                if isToday {
                    Text("TODAY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                if let mood = entry.mood {
                    Image(systemName: mood.icon)
                        .foregroundColor(mood.color)
                }
            }
            
            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(isToday ? nil : 2)
            } else if isToday {
                Text("Tap the pencil to add your thoughts for today...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .italic()
            }
            
            HStack {
                ForEach(entry.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, isToday ? 12 : 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.blue.opacity(0.05) : Color.clear)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !isToday {
                Button(role: .destructive) {
                    dataStore.deleteJournalEntry(id: entry.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    JournalView()
}