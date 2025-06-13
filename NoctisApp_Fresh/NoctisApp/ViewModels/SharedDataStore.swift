//
//  SharedDataStore.swift
//  NoctisApp
//
//  Global data store for the app
//

import SwiftUI

class SharedDataStore: ObservableObject {
    @Published var todos: [Todo] = [] {
        didSet { saveTodos() }
    }
    @Published var habits: [Habit] = [] {
        didSet { saveHabits() }
    }
    @Published var journalEntries: [JournalEntry] = [] {
        didSet { saveJournalEntries() }
    }
    
    static let shared = SharedDataStore()
    
    // UserDefaults keys
    private let todosKey = "com.thr3ethings.todos"
    private let habitsKey = "com.thr3ethings.habits"
    private let journalKey = "com.thr3ethings.journal"
    private let hasLaunchedKey = "com.thr3ethings.hasLaunched"
    
    private init() {
        loadPersistedData()
        ensureDailyJournalEntry()
    }
    
    private func loadSampleData() {
        todos = [
            Todo(title: "Review quarterly data with Olivia", description: "Complete analysis and prepare presentation", priority: .high),
            Todo(title: "Finish expense report", description: "Submit monthly expenses", priority: .medium),
            Todo(title: "Get car inspected", description: "Annual inspection due", priority: .low),
            Todo(title: "Organize catering", description: "Plan for team meeting", priority: .medium)
        ]
        
        habits = [
            Habit(name: "Drink Water", description: "8 glasses daily", frequency: .daily, targetCount: 8, color: "blue", icon: "drop.fill"),
            Habit(name: "Exercise", description: "30 minutes workout", frequency: .daily, targetCount: 1, color: "green", icon: "figure.walk"),
            Habit(name: "Read", description: "Read for 30 minutes", frequency: .daily, targetCount: 1, color: "orange", icon: "book.fill")
        ]
        
        // Create sample entries for different days
        let calendar = Calendar.current
        let today = Date()
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) {
            
            var entry1 = JournalEntry(title: "Productive Day", content: "Had a great day at work today.", mood: .good, tags: ["work", "productivity"])
            entry1.createdAt = twoDaysAgo
            entry1.updatedAt = twoDaysAgo
            
            var entry2 = JournalEntry(title: "Morning Reflection", content: "Started the day with meditation and coffee.", mood: .calm, tags: ["morning", "meditation"])
            entry2.createdAt = yesterday
            entry2.updatedAt = yesterday
            
            journalEntries = [entry1, entry2]
        } else {
            journalEntries = []
        }
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
    }
    
    func toggleTodo(id: String) {
        if let index = todos.firstIndex(where: { $0.id == id }) {
            var updatedTodo = todos[index]
            updatedTodo.isCompleted.toggle()
            updatedTodo.updatedAt = Date()
            updatedTodo.completedAt = updatedTodo.isCompleted ? Date() : nil
            todos[index] = updatedTodo
        }
    }
    
    func deleteTodo(id: String) {
        todos.removeAll { $0.id == id }
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
    
    func toggleHabitEntry(habitId: String) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            let today = Date()
            let calendar = Calendar.current
            
            // Check if there's already an entry for today
            if let entryIndex = habits[index].entries.firstIndex(where: { 
                calendar.isDate($0.date, inSameDayAs: today) 
            }) {
                // Toggle existing entry
                habits[index].entries[entryIndex].isCompleted.toggle()
            } else {
                // Create new entry for today
                let newEntry = HabitEntry(date: today, isCompleted: true)
                habits[index].entries.append(newEntry)
            }
        }
    }
    
    func isHabitCompletedToday(habitId: String) -> Bool {
        guard let habit = habits.first(where: { $0.id == habitId }) else { return false }
        let today = Date()
        let calendar = Calendar.current
        
        return habit.entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: today) && entry.isCompleted
        }
    }
    
    var pendingTodosCount: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    var completedTodosCount: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedTodosCount) / Double(todos.count) * 100
    }
    
    var totalActiveItems: Int {
        pendingTodosCount + habits.count + journalEntries.count
    }
    
    var taskCompletionRatio: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedTodosCount) / Double(todos.count)
    }
    
    var habitCompletionRatio: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(getCompletedHabitsToday()) / Double(habits.count)
    }
    
    var recentTodos: [Todo] {
        todos.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // Daily Goals - Enfoque aspiracional
    var allDailyTasksCompleted: Bool {
        return pendingTodosCount == 0 && !todos.isEmpty
    }
    
    var dailyTasksStatus: String {
        return "\(completedTodosCount)/\(todos.count)"
    }
    
    var hasDailyJournalCompleted: Bool {
        let today = Date()
        let calendar = Calendar.current
        
        return journalEntries.contains { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: today)
        }
    }
    
    var pendingHabitsToday: Int {
        let completedToday = getCompletedHabitsToday()
        return max(0, habits.count - completedToday)
    }
    
    var allDailyHabitsCompleted: Bool {
        return pendingHabitsToday == 0 && !habits.isEmpty
    }
    
    var dailyHabitsStatus: String {
        return "\(getCompletedHabitsToday())/\(habits.count)"
    }
    
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.insert(entry, at: 0)
    }
    
    func deleteJournalEntry(id: String) {
        journalEntries.removeAll { $0.id == id }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func toggleHabitToday(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].toggleEntry(for: Date())
        }
    }
    
    // MARK: - Daily Journal Management
    func ensureDailyJournalEntry() {
        let today = Date()
        let calendar = Calendar.current
        
        // Check if there's already an entry for today
        let hasTodayEntry = journalEntries.contains { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: today)
        }
        
        // If no entry for today, create one
        if !hasTodayEntry {
            let dailyEntry = JournalEntry(
                title: "Today's Reflection",
                content: "",
                mood: .neutral,
                tags: []
            )
            journalEntries.insert(dailyEntry, at: 0)
        }
    }
    
    func getTodayJournalEntry() -> JournalEntry? {
        let today = Date()
        let calendar = Calendar.current
        
        return journalEntries.first { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: today)
        }
    }
    
    func updateTodayJournalEntry(title: String, content: String, mood: Mood, tags: [String]) {
        let today = Date()
        let calendar = Calendar.current
        
        if let index = journalEntries.firstIndex(where: { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: today)
        }) {
            var updatedEntry = journalEntries[index]
            updatedEntry.title = title
            updatedEntry.content = content
            updatedEntry.mood = mood
            updatedEntry.tags = tags
            updatedEntry.updatedAt = Date()
            journalEntries[index] = updatedEntry
        }
    }
    
    // MARK: - Persistence Methods
    private func loadPersistedData() {
        let hasLaunched = UserDefaults.standard.bool(forKey: hasLaunchedKey)
        
        if !hasLaunched {
            // First launch - load sample data
            loadSampleData()
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
        } else {
            // Load saved data
            loadTodos()
            loadHabits()
            loadJournalEntries()
        }
    }
    
    // MARK: - Save Methods
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
        }
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
    }
    
    private func saveJournalEntries() {
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encoded, forKey: journalKey)
        }
    }
    
    // MARK: - Load Methods
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            todos = decoded
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    private func loadJournalEntries() {
        if let data = UserDefaults.standard.data(forKey: journalKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            journalEntries = decoded
        }
    }
}