//
//  TodoRowView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    @EnvironmentObject var todoViewModel: TodoViewModel
    @State private var showingEditTodo = false
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.padding) {
            // Completion Toggle
            Button {
                todoViewModel.toggleTodo(id: todo.id)
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? AppConstants.Colors.success : AppConstants.Colors.textTertiary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(todo.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(todo.isCompleted ? AppConstants.Colors.textTertiary : AppConstants.Colors.textPrimary)
                    .strikethrough(todo.isCompleted)
                
                // Description
                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                // Meta Info
                HStack(spacing: AppConstants.Layout.smallPadding) {
                    // Priority Badge
                    PriorityBadge(priority: todo.priority, style: .compact)
                    
                    // Due Date
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: AppConstants.Icons.calendar)
                                .font(.caption2)
                            Text(dueDate.age)
                                .font(.caption2)
                        }
                        .foregroundColor(dueDate < Date() && !todo.isCompleted ? AppConstants.Colors.error : AppConstants.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    // Creation Date
                    Text(todo.createdAt.age)
                        .font(.caption2)
                        .foregroundColor(AppConstants.Colors.textTertiary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, AppConstants.Layout.smallPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditTodo = true
        }
        .sheet(isPresented: $showingEditTodo) {
            EditTodoView(todo: todo)
                .environmentObject(todoViewModel)
        }
    }
}

struct PriorityBadge: View {
    let priority: Priority
    let style: Style
    
    enum Style {
        case compact
        case full
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(priority.color)
                .frame(width: 6, height: 6)
            
            if style == .full {
                Text(priority.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, style == .full ? 8 : 4)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(priority.paleColor)
                .stroke(priority.borderColor, lineWidth: 0.5)
        )
    }
}

#Preview {
    List {
        TodoRowView(todo: Todo(
            title: "Sample Task",
            description: "This is a sample task description",
            priority: .high
        ))
        .environmentObject(TodoViewModel())
        
        TodoRowView(todo: Todo(
            title: "Completed Task",
            description: "This task is completed",
            priority: .medium
        ))
        .environmentObject(TodoViewModel())
    }
    .listStyle(PlainListStyle())
    .background(Color.black)
}