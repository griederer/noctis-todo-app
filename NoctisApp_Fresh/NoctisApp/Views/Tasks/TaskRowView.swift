//
//  TaskRowView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-12.
//

import SwiftUI

struct TaskRowView: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .strikethrough(todo.isCompleted)
                
                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Priority indicator
            Circle()
                .fill(todo.priority.color)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(todo.isCompleted ? Color(.systemGray6) : Color(.systemBackground))
                .stroke(todo.isCompleted ? Color(.systemGray3) : Color(.systemGray4), lineWidth: 0.5)
        )
    }
}

#Preview {
    TaskRowView(
        todo: Todo(title: "Sample Task", description: "Sample description", priority: .high)
    ) {
        // Toggle action
    }
    .padding()
    .background(Color(.systemBackground))
}