//
//  AppDataStore.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-12.
//

import Foundation
import SwiftUI

class AppDataStore: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var habits: [Habit] = []
    @Published var journalEntries: [JournalEntry] = []
    
    static let shared = AppDataStore()
    
    private init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample todos
        todos = [
            Todo(title: "Review quarterly data with Olivia", description: "Complete analysis and prepare presentation", priority: .high),
            Todo(title: "Finish expense report", description: "Submit monthly expenses", priority: .medium),
            Todo(title: "Get car inspected", description: "Annual inspection due", priority: .low),
            Todo(title: "Organize catering", description: "Plan for team meeting", priority: .medium)
        ]
        
        // Sample habits
        habits = [
            Habit(name: "Drink Water", description: "8 glasses daily", frequency: .daily, targetCount: 8, color: "blue", icon: "drop.fill"),
            Habit(name: "Exercise", description: "30 minutes workout", frequency: .daily, targetCount: 1, color: "green", icon: "figure.walk"),
            Habit(name: "Read", description: "Read for 30 minutes", frequency: .daily, targetCount: 1, color: "orange", icon: "book.fill"),
            Habit(name: "Meditate", description: "10 minutes meditation", frequency: .daily, targetCount: 1, color: "purple", icon: "brain.head.profile")
        ]
        
        // Sample journal entries
        let calendar = Calendar.current
        let today = Date()
        
        journalEntries = [
            JournalEntry(title: "Productive Day", content: "Had a great day at work today. Completed all my tasks and felt really accomplished. Looking forward to tomorrow's challenges.", mood: .good, tags: ["work", "productivity"]),
            JournalEntry(title: "Morning Reflection", content: "Started the day with meditation and coffee. Feeling grateful for the small moments that bring peace.", mood: .calm, tags: ["morning", "meditation", "gratitude"]),
            JournalEntry(title: "Weekend Plans", content: "Excited about the upcoming weekend. Planning to visit the park and spend time with family.", mood: .excited, tags: ["weekend", "family", "plans"])
        ]
        
        // Set different dates for variety
        for i in 0..<journalEntries.count {
            journalEntries[i].createdAt = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            journalEntries[i].updatedAt = journalEntries[i].createdAt
        }
    }
    
    // MARK: - Todo Methods
    func addTodo(_ todo: Todo) {
        todos.append(todo)
    }
    
    func toggleTodo(id: String) {
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].isCompleted.toggle()
        }
    }
    
    func deleteTodo(id: String) {
        todos.removeAll { $0.id == id }
    }
    
    // MARK: - Habit Methods
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func toggleHabitToday(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].toggleEntry(for: Date())
        }
    }
    
    func getCompletedHabitsToday() -> Int {
        let today = Date()
        let calendar = Calendar.current
        
        return habits.filter { habit in
            habit.entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: today) && entry.isCompleted
            }
        }.count
    }
    
    // MARK: - Journal Methods
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.insert(entry, at: 0)
    }
}