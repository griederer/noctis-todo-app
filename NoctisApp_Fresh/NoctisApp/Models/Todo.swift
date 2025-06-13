//
//  Todo.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import SwiftUI

enum Priority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    var paleColor: Color {
        switch self {
        case .low:
            return .green.opacity(0.3)
        case .medium:
            return .orange.opacity(0.3)
        case .high:
            return .red.opacity(0.3)
        }
    }
    
    var borderColor: Color {
        switch self {
        case .low:
            return .green.opacity(0.6)
        case .medium:
            return .orange.opacity(0.6)
        case .high:
            return .red.opacity(0.6)
        }
    }
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

struct Todo: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String?
    var isCompleted: Bool
    var priority: Priority
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var dueDate: Date?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String? = nil,
        priority: Priority = .medium,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
    }
    
    mutating func toggleCompletion() {
        isCompleted.toggle()
        updatedAt = Date()
        completedAt = isCompleted ? Date() : nil
    }
    
    mutating func update(title: String? = nil, description: String? = nil, priority: Priority? = nil, dueDate: Date? = nil) {
        if let title = title { self.title = title }
        if let description = description { self.description = description }
        if let priority = priority { self.priority = priority }
        if let dueDate = dueDate { self.dueDate = dueDate }
        self.updatedAt = Date()
    }
}