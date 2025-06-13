//
//  TodoViewModel.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: TodoRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: TodoRepositoryProtocol = TodoRepository()) {
        self.repository = repository
        setupSubscriptions()
        loadTodos()
    }
    
    private func setupSubscriptions() {
        repository.todosPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todos in
                self?.todos = todos
            }
            .store(in: &cancellables)
    }
    
    func loadTodos() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await repository.fetchTodos()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func addTodo(title: String, description: String? = nil, priority: Priority = .medium, dueDate: Date? = nil) {
        print("🔥 DEBUG: TodoViewModel.addTodo called with title: \(title)")
        
        let todo = Todo(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate
        )
        
        print("🔥 DEBUG: Created todo with ID: \(todo.id)")
        
        Task {
            do {
                print("🔥 DEBUG: Calling repository.addTodo...")
                try await repository.addTodo(todo)
                print("🔥 DEBUG: Repository.addTodo completed successfully")
            } catch {
                print("🔥 DEBUG: Repository.addTodo failed with error: \(error)")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateTodo(_ todo: Todo) {
        Task {
            do {
                try await repository.updateTodo(todo)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteTodo(id: String) {
        Task {
            do {
                try await repository.deleteTodo(id: id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleTodo(id: String) {
        Task {
            do {
                try await repository.toggleTodo(id: id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var pendingTodos: [Todo] {
        todos.filter { !$0.isCompleted }
    }
    
    var completedTodos: [Todo] {
        todos.filter { $0.isCompleted }
    }
    
    var todayTodos: [Todo] {
        let calendar = Calendar.current
        return todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDateInToday(dueDate)
        }
    }
    
    var overdueTodos: [Todo] {
        let now = Date()
        return todos.filter { todo in
            guard let dueDate = todo.dueDate, !todo.isCompleted else { return false }
            return dueDate < now
        }
    }
    
    var upcomingTodos: [Todo] {
        let calendar = Calendar.current
        let now = Date()
        let oneWeekFromNow = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        
        return todos.filter { todo in
            guard let dueDate = todo.dueDate, !todo.isCompleted else { return false }
            return dueDate > now && dueDate <= oneWeekFromNow
        }
    }
    
    func todosByPriority(_ priority: Priority) -> [Todo] {
        todos.filter { $0.priority == priority && !$0.isCompleted }
    }
}