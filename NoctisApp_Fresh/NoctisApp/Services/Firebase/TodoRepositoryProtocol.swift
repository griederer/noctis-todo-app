//
//  TodoRepositoryProtocol.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine

protocol TodoRepositoryProtocol {
    var todosPublisher: AnyPublisher<[Todo], Never> { get }
    
    func fetchTodos() async throws -> [Todo]
    func addTodo(_ todo: Todo) async throws
    func updateTodo(_ todo: Todo) async throws
    func deleteTodo(id: String) async throws
    func toggleTodo(id: String) async throws
}