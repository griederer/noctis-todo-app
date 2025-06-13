//
//  TasksView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct TasksView: View {
    @StateObject private var dataStore = SharedDataStore.shared
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with title and + button
                HStack {
                    Text("To Do")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                List {
                    ForEach(Array(dataStore.todos.enumerated()), id: \.element.id) { index, todo in
                        // First 3 todos are LARGE (important), 4th+ are small
                        let isMainTask = index < 3
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                dataStore.toggleTodo(id: todo.id)
                            }) {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title)
                                    .foregroundColor(todo.isCompleted ? .green : .gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(todo.title)
                                    .font(isMainTask ? .headline : .subheadline)
                                    .fontWeight(isMainTask ? .semibold : .regular)
                                    .strikethrough(todo.isCompleted)
                                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                                
                                if let description = todo.description, !description.isEmpty {
                                    Text(description)
                                        .font(isMainTask ? .caption : .caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(isMainTask ? 2 : 1)
                                }
                            }
                            
                            Spacer()
                            
                            // Priority indicator
                            Circle()
                                .fill(todo.priority.color)
                                .frame(width: 12, height: 12)
                        }
                        .padding(.vertical, isMainTask ? 16 : 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isMainTask ? Color(.systemBackground) : Color.clear)
                                .stroke(
                                    isMainTask ? Color(.systemGray4) : Color.clear, 
                                    lineWidth: isMainTask ? 1 : 0
                                )
                                .shadow(
                                    color: isMainTask ? .black.opacity(0.1) : .clear,
                                    radius: isMainTask ? 2 : 0,
                                    x: 0,
                                    y: isMainTask ? 1 : 0
                                )
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: isMainTask ? 8 : 4, leading: 20, bottom: isMainTask ? 8 : 4, trailing: 20))
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView { title, description, priority in
                let newTodo = Todo(
                    title: title,
                    description: description,
                    priority: priority
                )
                dataStore.addTodo(newTodo)
                showingAddTask = false
            }
        }
    }
}

#Preview {
    TasksView()
}