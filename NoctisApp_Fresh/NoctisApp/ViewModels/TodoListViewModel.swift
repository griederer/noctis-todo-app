import Foundation
import SwiftUI
import Combine

class TodoListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedPriorityFilter: Priority?
    @Published var showCompleted = true
    @Published var showingAddTodo = false
    @Published var selectedTodo: Todo?
    @Published var showingEditTodo = false
    
    private let repository = TodoFirebaseRepository()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Bind repository state
        repository.$isLoading
            .assign(to: &$isLoading)
        
        repository.$errorMessage
            .assign(to: &$errorMessage)
    }
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var filteredTodos: [Todo] {
        repository.filteredTodos(
            showCompleted: showCompleted,
            priority: selectedPriorityFilter,
            searchText: searchText
        )
    }
    
    var totalTodos: Int {
        repository.totalTodos
    }
    
    var completedTodos: Int {
        repository.completedTodos
    }
    
    var pendingTodos: Int {
        repository.pendingTodos
    }
    
    var highPriorityTodos: Int {
        repository.highPriorityTodos
    }
    
    var completionRate: Double {
        repository.completionRate
    }
    
    var hasActiveTodos: Bool {
        !filteredTodos.isEmpty
    }
    
    var emptyStateMessage: String {
        if searchText.isEmpty && selectedPriorityFilter == nil {
            if showCompleted {
                return pendingTodos == 0 ? "All tasks completed! 🌙" : "No todos yet. Add your first task!"
            } else {
                return "No pending tasks! Time to relax 🌟"
            }
        } else {
            return "No todos match your search"
        }
    }
    
    // MARK: - Actions
    func addTodo(title: String, description: String?, priority: Priority, dueDate: Date?) {
        let todo = Todo(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate
        )
        
        repository.addTodo(todo)
        showingAddTodo = false
        
        AnalyticsService.shared.trackCustomEvent(name: "todo_created_from_list", parameters: [
            "priority": priority.rawValue,
            "has_description": description?.isEmpty == false,
            "has_due_date": dueDate != nil
        ])
    }
    
    func updateTodo(_ todo: Todo, title: String, description: String?, priority: Priority, dueDate: Date?) {
        var updatedTodo = todo
        updatedTodo.update(title: title, description: description, priority: priority, dueDate: dueDate)
        
        repository.updateTodo(updatedTodo)
        showingEditTodo = false
        selectedTodo = nil
    }
    
    func toggleCompletion(_ todo: Todo) {
        repository.toggleTodoCompletion(todo)
        
        // Haptic feedback for completion
        if !todo.isCompleted {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        repository.deleteTodo(todo)
        
        if selectedTodo?.id == todo.id {
            selectedTodo = nil
            showingEditTodo = false
        }
    }
    
    func changePriority(_ todo: Todo, to priority: Priority) {
        repository.updateTodoPriority(todo, priority: priority)
    }
    
    func deleteCompletedTodos() {
        repository.deleteCompletedTodos()
    }
    
    // MARK: - Filtering
    func clearFilters() {
        searchText = ""
        selectedPriorityFilter = nil
        showCompleted = true
    }
    
    func setPriorityFilter(_ priority: Priority?) {
        selectedPriorityFilter = priority
        AnalyticsService.shared.trackCustomEvent(name: "todo_filter_applied", parameters: [
            "filter_type": "priority",
            "filter_value": priority?.rawValue ?? "none"
        ])
    }
    
    func toggleShowCompleted() {
        showCompleted.toggle()
        AnalyticsService.shared.trackCustomEvent(name: "todo_filter_toggled", parameters: [
            "filter_type": "show_completed",
            "show_completed": showCompleted
        ])
    }
    
    // MARK: - Navigation
    func showAddTodo() {
        showingAddTodo = true
        AnalyticsService.shared.trackCustomEvent(name: "add_todo_initiated")
    }
    
    func showEditTodo(_ todo: Todo) {
        selectedTodo = todo
        showingEditTodo = true
        AnalyticsService.shared.trackCustomEvent(name: "edit_todo_initiated", parameters: [
            "todo_priority": todo.priority.rawValue,
            "todo_completed": todo.isCompleted
        ])
    }
    
    func dismissModals() {
        showingAddTodo = false
        showingEditTodo = false
        selectedTodo = nil
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Statistics Helper
    func getStatistics() -> TodoStatistics {
        return TodoStatistics(
            total: totalTodos,
            completed: completedTodos,
            pending: pendingTodos,
            highPriority: highPriorityTodos,
            completionRate: completionRate
        )
    }
}

// MARK: - Supporting Types
struct TodoStatistics {
    let total: Int
    let completed: Int
    let pending: Int
    let highPriority: Int
    let completionRate: Double
    
    var completionPercentage: Int {
        Int(completionRate * 100)
    }
}