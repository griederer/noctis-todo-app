//
//  AddTodoView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct AddTodoView: View {
    @EnvironmentObject var todoViewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = Priority.medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    PrioritySelector(selectedPriority: $priority)
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTodo()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveTodo() {
        todoViewModel.addTodo(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespaces),
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        dismiss()
    }
}

struct PrioritySelector: View {
    @Binding var selectedPriority: Priority
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.padding) {
            ForEach(Priority.allCases, id: \.self) { priority in
                PriorityButton(
                    priority: priority,
                    isSelected: selectedPriority == priority
                ) {
                    selectedPriority = priority
                }
            }
        }
    }
}

struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(priority.color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                    )
                
                Text(priority.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? priority.color : AppConstants.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppConstants.Layout.padding)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                    .fill(isSelected ? priority.paleColor : AppConstants.Colors.surface)
                    .stroke(isSelected ? priority.borderColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddTodoView()
        .environmentObject(TodoViewModel())
}