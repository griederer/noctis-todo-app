//
//  AddTaskView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-12.
//

import SwiftUI

struct AddTaskView: View {
    let onSave: (String, String?, Priority) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority: Priority = .medium
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter task title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputActive)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter description (optional)", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputActive)
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
            .onTapGesture {
                isInputActive = false
            }
            .navigationTitle("New Task")
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
    AddTaskView { title, description, priority in
        print("New task: \(title)")
    }
}