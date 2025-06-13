import SwiftUI

struct AddTodoFormView: View {
    let viewModel: TodoListViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority = Priority.medium
    @State private var dueDate = Date().addingTimeInterval(86400) // Tomorrow
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
                
                Section {
                    Button(action: addTodo) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Task")
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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
            }
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            AnalyticsService.shared.trackScreen("Add Todo Form")
        }
    }
    
    private func addTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else { return }
        
        viewModel.addTodo(
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            priority: selectedPriority,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        dismiss()
    }
}

#Preview {
    AddTodoFormView(viewModel: TodoListViewModel())
}