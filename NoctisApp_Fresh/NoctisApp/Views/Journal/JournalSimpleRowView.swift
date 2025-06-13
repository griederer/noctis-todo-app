//
//  JournalSimpleRowView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-12.
//

import SwiftUI

struct JournalSimpleRowView: View {
    let entry: JournalEntry
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Mood indicator
            if let mood = entry.mood {
                Circle()
                    .fill(mood.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(mood.emoji)
                            .font(.title3)
                    )
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "book")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    )
            }
            
            // Entry content
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Text(dateFormatter.string(from: entry.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !entry.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(entry.tags.prefix(2), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.secondary)
                                    .cornerRadius(4)
                            }
                            
                            if entry.tags.count > 2 {
                                Text("+\(entry.tags.count - 2)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Favorite indicator
            if entry.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    VStack {
        JournalSimpleRowView(
            entry: JournalEntry(
                title: "Great Day at Work",
                content: "Had an amazing day at work today. Completed all my tasks and learned something new. Feeling accomplished and grateful.",
                mood: .good,
                tags: ["work", "productivity", "gratitude"]
            )
        )
        
        JournalSimpleRowView(
            entry: JournalEntry(
                title: "Weekend Reflections",
                content: "Spent quality time with family and friends. These moments remind me what's truly important in life.",
                mood: .happy,
                tags: ["family", "weekend"]
            )
        )
    }
    .padding()
}