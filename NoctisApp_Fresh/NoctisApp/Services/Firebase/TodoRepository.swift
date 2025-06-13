//
//  TodoRepository.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine

class TodoRepository: TodoRepositoryProtocol {
    private let firebaseRepository = TodoFirebaseRepository()
    
    var todosPublisher: AnyPublisher<[Todo], Never> {
        firebaseRepository.$todos.eraseToAnyPublisher()
    }
    
    func fetchTodos() async throws -> [Todo] {
        return firebaseRepository.todos
    }
    
    func addTodo(_ todo: Todo) async throws {
        firebaseRepository.addTodo(todo)
    }
    
    func updateTodo(_ todo: Todo) async throws {
        firebaseRepository.updateTodo(todo)
    }
    
    func deleteTodo(id: String) async throws {
        if let todo = firebaseRepository.todos.first(where: { $0.id == id }) {
            firebaseRepository.deleteTodo(todo)
        }
    }
    
    func toggleTodo(id: String) async throws {
        if let todo = firebaseRepository.todos.first(where: { $0.id == id }) {
            var updatedTodo = todo
            updatedTodo.toggleCompletion()
            firebaseRepository.updateTodo(updatedTodo)
        }
    }
}