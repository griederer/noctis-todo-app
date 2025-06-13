//
//  TasksView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var selectedFilter: TaskFilter = .all
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistics Header
                if viewModel.totalTodos > 0 {
                    statisticsHeader
                }
                
                // Search Bar
                searchBar
                
                // Filter Picker
                filterPicker
                
                // Tasks List
                tasksList
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: viewModel.toggleShowCompleted) {
                            Label(
                                viewModel.showCompleted ? "Hide Completed" : "Show Completed",
                                systemImage: viewModel.showCompleted ? "eye.slash" : "eye"
                            )
                        }
                        
                        if viewModel.completedTodos > 0 {
                            Divider()
                            
                            Button(action: viewModel.deleteCompletedTodos) {
                                Label("Delete Completed", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color("Primary"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.showAddTodo) {
                        Image(systemName: "plus")
                            .foregroundColor(Color("Primary"))
                    }
                }
            }
            .background(Color("Background"))
            .sheet(isPresented: $viewModel.showingAddTodo) {
                AddTodoFormView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingEditTodo) {
                if let todo = viewModel.selectedTodo {
                    EditTodoFormView(todo: todo, viewModel: viewModel)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            AnalyticsService.shared.trackScreen("Tasks List")
        }
    }
    
    // MARK: - Statistics Header
    private var statisticsHeader: some View {
        VStack(spacing: 8) {
            HStack {
                StatCard(title: "Total", value: "\(viewModel.totalTodos)", color: Color("TextSecondary"))
                StatCard(title: "Pending", value: "\(viewModel.pendingTodos)", color: .orange)
                StatCard(title: "Completed", value: "\(viewModel.completedTodos)", color: .green)
                StatCard(title: "Progress", value: "\(viewModel.getStatistics().completionPercentage)%", color: Color("Primary"))
            }
            
            if viewModel.highPriorityTodos > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("\(viewModel.highPriorityTodos) high priority tasks pending")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color("Surface"))
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("TextSecondary"))
            
            TextField("Search todos...", text: $viewModel.searchText)
                .foregroundColor(Color("TextPrimary"))
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("Surface"))
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Filter Picker
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                PriorityFilterChip(priority: nil, selectedPriority: viewModel.selectedPriorityFilter) {
                    viewModel.setPriorityFilter(nil)
                }
                
                ForEach(Priority.allCases, id: \.self) { priority in
                    PriorityFilterChip(priority: priority, selectedPriority: viewModel.selectedPriorityFilter) {
                        viewModel.setPriorityFilter(priority)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Tasks List
    private var tasksList: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Primary")))
                    
                    Text("Loading tasks...")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background"))
            } else if !viewModel.hasActiveTodos {
                EmptyStateView(
                    icon: "moon.stars",
                    title: "No Tasks",
                    subtitle: viewModel.emptyStateMessage
                )
            } else {
                List {
                    ForEach(viewModel.filteredTodos) { todo in
                        ModernTodoRowView(todo: todo) {
                            viewModel.toggleCompletion(todo)
                        } onEdit: {
                            viewModel.showEditTodo(todo)
                        } onDelete: {
                            viewModel.deleteTodo(todo)
                        } onPriorityChange: { priority in
                            viewModel.changePriority(todo, to: priority)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color("Background"))
            }
        }
    }
    
}

enum TaskFilter: CaseIterable {
    case all
    case pending
    case completed
    case today
    case overdue
    case high
    case medium
    case low
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .pending:
            return "Pending"
        case .completed:
            return "Completed"
        case .today:
            return "Today"
        case .overdue:
            return "Overdue"
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        }
    }
    
    func count(from viewModel: TodoViewModel) -> Int {
        filter(viewModel.todos).count
    }
    
    func filter(_ todos: [Todo]) -> [Todo] {
        switch self {
        case .all:
            return todos
        case .pending:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { $0.isCompleted }
        case .today:
            return todos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }
        case .overdue:
            let now = Date()
            return todos.filter { todo in
                guard let dueDate = todo.dueDate, !todo.isCompleted else { return false }
                return dueDate < now
            }
        case .high:
            return todos.filter { $0.priority == .high && !$0.isCompleted }
        case .medium:
            return todos.filter { $0.priority == .medium && !$0.isCompleted }
        case .low:
            return todos.filter { $0.priority == .low && !$0.isCompleted }
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(AuthenticationService.shared)
}