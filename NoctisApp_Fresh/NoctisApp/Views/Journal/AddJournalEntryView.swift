//
//  AddJournalEntryView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct AddJournalEntryView: View {
    let onSave: (String, String, Mood?, [String]) -> Void
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: Mood?
    @State private var tagText = ""
    @State private var tags: [String] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter a title for your entry", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    // Mood Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How are you feeling?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach([Mood.veryGood, .good, .neutral, .bad, .veryBad, .happy, .stressed, .excited, .calm, .grateful], id: \.self) { mood in
                                Button(action: { 
                                    selectedMood = selectedMood == mood ? nil : mood
                                }) {
                                    VStack(spacing: 4) {
                                        Text(mood.emoji)
                                            .font(.title2)
                                        
                                        Text(mood.displayName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(height: 60)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedMood == mood ? mood.color.opacity(0.2) : Color(.systemGray6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 2)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("Add a tag and press Enter", text: $tagText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button("Add") {
                                addTag()
                            }
                            .disabled(tagText.isEmpty)
                            .foregroundColor(.blue)
                        }
                        
                        if !tags.isEmpty {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text("#\(tag)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        Spacer()
                                        
                                        Button(action: { removeTag(tag) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemBackground).ignoresSafeArea(.all))
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(title, content, selectedMood, tags)
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagText = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

#Preview {
    AddJournalEntryView { title, content, mood, tags in
        print("New entry: \(title)")
    }
}