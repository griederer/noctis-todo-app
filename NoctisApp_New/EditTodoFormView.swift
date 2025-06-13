import SwiftUI

struct EditTodoFormView: View {
    let todo: Todo
    let viewModel: TodoListViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority = Priority.medium
    @State private var dueDate = Date().addingTimeInterval(86400)
    @State private var hasDueDate = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                        .foregroundColor(Color("TextPrimary"))
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .foregroundColor(Color("TextPrimary"))
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(priority.displayName)
                                    .foregroundColor(Color("TextPrimary"))
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                        .foregroundColor(Color("TextPrimary"))
                    
                    if hasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .foregroundColor(Color("TextPrimary"))
                    }
                }
                
                Section("Status") {
                    HStack {
                        Text("Completed")
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                        
                        if todo.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(Color("TextSecondary"))
                            
                            Text("Pending")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                    
                    if let completedAt = todo.completedAt {
                        HStack {
                            Text("Completed at")
                                .foregroundColor(Color("TextSecondary"))
                            
                            Spacer()
                            
                            Text(completedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                }
                
                Section {
                    Button(action: saveTodo) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Changes")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedPriority.color)
                        )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                Section {
                    Button(action: toggleCompletion) {
                        HStack {
                            Image(systemName: todo.isCompleted ? "circle" : "checkmark.circle")
                            Text(todo.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                        }
                        .foregroundColor(todo.isCompleted ? .orange : .green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(todo.isCompleted ? .orange : .green, lineWidth: 2)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Delete") {
                        deleteTodo()
                    }
                    .foregroundColor(.red)
                }
            }
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupInitialValues()
            AnalyticsService.shared.trackScreen("Edit Todo Form")
        }
    }
    
    private func setupInitialValues() {
        title = todo.title
        description = todo.description ?? ""
        selectedPriority = todo.priority
        hasDueDate = todo.dueDate != nil
        if let todoDueDate = todo.dueDate {
            dueDate = todoDueDate
        }
    }
    
    private func saveTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else { return }
        
        viewModel.updateTodo(
            todo,
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            priority: selectedPriority,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        dismiss()
    }
    
    private func toggleCompletion() {
        viewModel.toggleCompletion(todo)
        dismiss()
    }
    
    private func deleteTodo() {
        viewModel.deleteTodo(todo)
        dismiss()
    }
}

#Preview {
    EditTodoFormView(
        todo: Todo(
            title: "Sample Todo",
            description: "This is a sample todo item",
            priority: .high,
            dueDate: Date().addingTimeInterval(86400)
        ),
        viewModel: TodoListViewModel()
    )
}