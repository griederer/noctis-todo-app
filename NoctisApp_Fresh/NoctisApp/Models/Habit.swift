//
//  Habit.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import SwiftUI

enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        }
    }
}

struct HabitEntry: Identifiable, Codable {
    let id: String
    let date: Date
    var isCompleted: Bool
    var notes: String?
    
    init(id: String = UUID().uuidString, date: Date, isCompleted: Bool = false, notes: String? = nil) {
        self.id = id
        self.date = date
        self.isCompleted = isCompleted
        self.notes = notes
    }
}

struct Habit: Identifiable, Codable {
    let id: String
    var name: String
    var description: String?
    var frequency: HabitFrequency
    var targetCount: Int
    var color: String
    var icon: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    var entries: [HabitEntry]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        frequency: HabitFrequency = .daily,
        targetCount: Int = 1,
        color: String = "blue",
        icon: String = "circle.fill"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.frequency = frequency
        self.targetCount = targetCount
        self.color = color
        self.icon = icon
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.entries = []
    }
    
    var currentStreak: Int {
        let sortedEntries = entries.sorted { $0.date > $1.date }
        var streak = 0
        let calendar = Calendar.current
        
        for entry in sortedEntries {
            if entry.isCompleted {
                streak += 1
            } else if calendar.isDateInToday(entry.date) || calendar.isDateInYesterday(entry.date) {
                break
            }
        }
        
        return streak
    }
    
    mutating func addEntry(_ entry: HabitEntry) {
        entries.append(entry)
        updatedAt = Date()
    }
    
    mutating func toggleEntry(for date: Date) {
        let calendar = Calendar.current
        
        if let index = entries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            entries[index].isCompleted.toggle()
        } else {
            let newEntry = HabitEntry(date: date, isCompleted: true)
            entries.append(newEntry)
        }
        
        updatedAt = Date()
    }
}