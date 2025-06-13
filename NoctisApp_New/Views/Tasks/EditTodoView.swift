//
//  EditTodoView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct EditTodoView: View {
    let todo: Todo
    @EnvironmentObject var todoViewModel: TodoViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var priority: Priority
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    
    init(todo: Todo) {
        self.todo = todo
        self._title = State(initialValue: todo.title)
        self._description = State(initialValue: todo.description ?? "")
        self._priority = State(initialValue: todo.priority)
        self._dueDate = State(initialValue: todo.dueDate ?? Date())
        self._hasDueDate = State(initialValue: todo.dueDate != nil)
    }
    
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
                
                Section("Status") {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(todo.createdAt.dateTimeString)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                    
                    if todo.updatedAt != todo.createdAt {
                        HStack {
                            Text("Updated")
                            Spacer()
                            Text(todo.updatedAt.dateTimeString)
                                .foregroundColor(AppConstants.Colors.textSecondary)
                        }
                    }
                    
                    if let completedAt = todo.completedAt {
                        HStack {
                            Text("Completed")
                            Spacer()
                            Text(completedAt.dateTimeString)
                                .foregroundColor(AppConstants.Colors.success)
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
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
        var updatedTodo = todo
        updatedTodo.update(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespaces),
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        todoViewModel.updateTodo(updatedTodo)
        dismiss()
    }
}

#Preview {
    EditTodoView(todo: Todo(
        title: "Sample Task",
        description: "This is a sample task",
        priority: .high
    ))
    .environmentObject(TodoViewModel())
}