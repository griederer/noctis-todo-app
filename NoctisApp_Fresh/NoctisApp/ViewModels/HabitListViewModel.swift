import Foundation
import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var showingAddHabit = false
    @Published var selectedHabit: Habit?
    @Published var showingEditHabit = false
    @Published var showingHabitDetail = false
    @Published var selectedFilter: HabitFilter = .active
    
    private let repository = HabitFirebaseRepository()
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
    var filteredHabits: [Habit] {
        switch selectedFilter {
        case .active:
            return repository.getActiveHabits()
        case .all:
            return repository.habits
        case .completed:
            return repository.getCompletedHabitsForToday()
        case .pending:
            return repository.getHabitsForToday()
        }
    }
    
    var totalHabits: Int {
        repository.habits.count
    }
    
    var activeHabits: Int {
        repository.getActiveHabits().count
    }
    
    var completedTodayCount: Int {
        repository.getCompletedHabitsForToday().count
    }
    
    var pendingTodayCount: Int {
        repository.getHabitsForToday().count
    }
    
    var todayCompletionRate: Double {
        let totalActive = repository.getActiveHabits().count
        guard totalActive > 0 else { return 0 }
        return Double(completedTodayCount) / Double(totalActive)
    }
    
    var hasActiveHabits: Bool {
        !filteredHabits.isEmpty
    }
    
    var emptyStateMessage: String {
        switch selectedFilter {
        case .active:
            return activeHabits == 0 ? "No active habits. Create your first habit!" : "No active habits"
        case .all:
            return "No habits yet. Start building better habits today!"
        case .completed:
            return "No habits completed today yet"
        case .pending:
            return "All habits completed for today! 🎉"
        }
    }
    
    // MARK: - Actions
    func addHabit(name: String, description: String?, frequency: HabitFrequency, targetCount: Int, color: String, icon: String) {
        let habit = Habit(
            name: name,
            description: description,
            frequency: frequency,
            targetCount: targetCount,
            color: color,
            icon: icon
        )
        
        repository.addHabit(habit)
        showingAddHabit = false
        
        AnalyticsService.shared.trackCustomEvent(name: "habit_created_from_list", parameters: [
            "frequency": frequency.rawValue,
            "target_count": targetCount,
            "has_description": description?.isEmpty == false
        ])
    }
    
    func updateHabit(_ habit: Habit, name: String, description: String?, frequency: HabitFrequency, targetCount: Int, color: String, icon: String) {
        var updatedHabit = habit
        updatedHabit.name = name
        updatedHabit.description = description
        updatedHabit.frequency = frequency
        updatedHabit.targetCount = targetCount
        updatedHabit.color = color
        updatedHabit.icon = icon
        updatedHabit.updatedAt = Date()
        
        repository.updateHabit(updatedHabit)
        showingEditHabit = false
        selectedHabit = nil
    }
    
    func toggleHabitEntry(_ habit: Habit, for date: Date = Date()) {
        repository.toggleHabitEntry(habit, for: date)
        
        // Haptic feedback for completion
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    func deleteHabit(_ habit: Habit) {
        repository.deleteHabit(habit)
        
        if selectedHabit?.id == habit.id {
            selectedHabit = nil
            showingEditHabit = false
            showingHabitDetail = false
        }
    }
    
    func toggleHabitActive(_ habit: Habit) {
        var updatedHabit = habit
        updatedHabit.isActive.toggle()
        updatedHabit.updatedAt = Date()
        
        repository.updateHabit(updatedHabit)
        
        AnalyticsService.shared.trackCustomEvent(name: "habit_active_toggled", parameters: [
            "habit_id": habit.id,
            "is_active": updatedHabit.isActive
        ])
    }
    
    // MARK: - Filtering
    func setFilter(_ filter: HabitFilter) {
        selectedFilter = filter
        AnalyticsService.shared.trackCustomEvent(name: "habit_filter_applied", parameters: [
            "filter": filter.rawValue
        ])
    }
    
    // MARK: - Navigation
    func showAddHabit() {
        showingAddHabit = true
        AnalyticsService.shared.trackCustomEvent(name: "add_habit_initiated")
    }
    
    func showEditHabit(_ habit: Habit) {
        selectedHabit = habit
        showingEditHabit = true
        AnalyticsService.shared.trackCustomEvent(name: "edit_habit_initiated", parameters: [
            "habit_id": habit.id
        ])
    }
    
    func showHabitDetail(_ habit: Habit) {
        selectedHabit = habit
        showingHabitDetail = true
        AnalyticsService.shared.trackCustomEvent(name: "habit_detail_viewed", parameters: [
            "habit_id": habit.id
        ])
    }
    
    func dismissModals() {
        showingAddHabit = false
        showingEditHabit = false
        showingHabitDetail = false
        selectedHabit = nil
    }
    
    // MARK: - Statistics
    func getHabitStatistics(_ habit: Habit) -> HabitStatistics {
        return repository.getHabitStatistics(habit)
    }
    
    func getTodayOverallStatistics() -> TodayHabitStatistics {
        let activeHabits = repository.getActiveHabits()
        let completedToday = repository.getCompletedHabitsForToday().count
        let pendingToday = repository.getHabitsForToday().count
        
        return TodayHabitStatistics(
            totalActive: activeHabits.count,
            completed: completedToday,
            pending: pendingToday,
            completionRate: todayCompletionRate
        )
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types
enum HabitFilter: String, CaseIterable {
    case active = "active"
    case all = "all"
    case completed = "completed"
    case pending = "pending"
    
    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .all:
            return "All"
        case .completed:
            return "Completed Today"
        case .pending:
            return "Pending Today"
        }
    }
}

struct TodayHabitStatistics {
    let totalActive: Int
    let completed: Int
    let pending: Int
    let completionRate: Double
    
    var completionPercentage: Int {
        Int(completionRate * 100)
    }
}