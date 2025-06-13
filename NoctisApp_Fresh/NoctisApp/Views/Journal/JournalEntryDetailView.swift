//
//  JournalEntryDetailView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct JournalEntryDetailView: View {
    let entry: JournalEntry
    let viewModel: JournalListViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "book.pages")
                    .font(.system(size: 64))
                    .foregroundColor(AppConstants.Colors.textTertiary)
                
                Text("Journal Entry Detail")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.textSecondary)
                
                Text("Coming soon - View and edit your journal entries")
                    .font(.body)
                    .foregroundColor(AppConstants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title: \(entry.title)")
                        .font(.headline)
                    
                    Text("Created: \(entry.createdAt.formatted())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !entry.content.isEmpty {
                        Text("Content: \(entry.content.prefix(100))...")
                            .font(.body)
                            .padding(.top)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Entry Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // TODO: Implement edit functionality
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    JournalEntryDetailView(
        entry: JournalEntry(title: "Sample Entry", content: "Sample content"),
        viewModel: JournalListViewModel()
    )
}