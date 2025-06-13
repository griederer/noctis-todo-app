//
//  EditTaskView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-12.
//

import SwiftUI

struct EditTaskView: View {
    let todo: Todo
    let onSave: (String, String?, Priority) -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var selectedPriority: Priority
    @Environment(\.dismiss) private var dismiss
    
    init(todo: Todo, onSave: @escaping (String, String?, Priority) -> Void) {
        self.todo = todo
        self.onSave = onSave
        
        // Initialize state with existing todo values
        _title = State(initialValue: todo.title)
        _description = State(initialValue: todo.description ?? "")
        _selectedPriority = State(initialValue: todo.priority)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter task title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter description (optional)", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground).ignoresSafeArea(.all))
            .navigationTitle("Edit Task")
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
                        onSave(title, description.isEmpty ? nil : description, selectedPriority)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    EditTaskView(
        todo: Todo(title: "Sample Task", description: "Sample description", priority: .high)
    ) { title, description, priority in
        print("Edited task: \(title)")
    }
}