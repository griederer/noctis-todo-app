//
//  TodoRepository.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine

protocol TodoRepositoryProtocol {
    func fetchTodos() async throws -> [Todo]
    func addTodo(_ todo: Todo) async throws
    func updateTodo(_ todo: Todo) async throws
    func deleteTodo(id: String) async throws
    func toggleTodo(id: String) async throws
    
    var todosPublisher: AnyPublisher<[Todo], Never> { get }
}

class TodoRepository: TodoRepositoryProtocol, ObservableObject {
    @Published private var todos: [Todo] = []
    
    var todosPublisher: AnyPublisher<[Todo], Never> {
        $todos.eraseToAnyPublisher()
    }
    
    func fetchTodos() async throws -> [Todo] {
        // For now, return mock data
        // TODO: Implement Firebase Firestore integration
        return todos
    }
    
    func addTodo(_ todo: Todo) async throws {
        // TODO: Implement Firebase Firestore integration
        todos.append(todo)
    }
    
    func updateTodo(_ todo: Todo) async throws {
        // TODO: Implement Firebase Firestore integration
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
        }
    }
    
    func deleteTodo(id: String) async throws {
        // TODO: Implement Firebase Firestore integration
        todos.removeAll { $0.id == id }
    }
    
    func toggleTodo(id: String) async throws {
        // TODO: Implement Firebase Firestore integration
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].toggleCompletion()
        }
    }
}