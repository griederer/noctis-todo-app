import Foundation
import FirebaseFirestore
import Combine

class HabitFirebaseRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let authService = AuthenticationService.shared
    
    @Published var habits: [Habit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to authentication state changes
        authService.$currentUser
            .sink { [weak self] user in
                if user != nil {
                    self?.startListening()
                } else {
                    self?.stopListening()
                    self?.habits = []
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        stopListening()
    }
    
    // MARK: - Real-time Listening
    private func startListening() {
        guard let userId = authService.currentUser?.id else {
            Logger.shared.dataError("No user ID available for listening to habits")
            return
        }
        
        stopListening() // Stop any existing listener
        
        Logger.shared.dataInfo("Starting to listen for habits for user: \(userId)")
        
        listener = db.collection("users").document(userId).collection("habits")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.setError("Failed to fetch habits: \(error.localizedDescription)")
                        AnalyticsService.shared.recordError(error)
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.setError("No habits found")
                        return
                    }
                    
                    self?.habits = documents.compactMap { document in
                        do {
                            let habit = try document.data(as: Habit.self)
                            return habit
                        } catch {
                            Logger.shared.dataError("Failed to decode habit: \(error)")
                            return nil
                        }
                    }
                    
                    Logger.shared.dataInfo("Fetched \(self?.habits.count ?? 0) habits")
                    self?.clearError()
                }
            }
    }
    
    private func stopListening() {
        listener?.remove()
        listener = nil
        Logger.shared.dataInfo("Stopped listening for habits")
    }
    
    // MARK: - CRUD Operations
    func addHabit(_ habit: Habit) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        do {
            let _ = try db.collection("users").document(userId).collection("habits")
                .document(habit.id).setData(from: habit) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.setLoading(false)
                        
                        if let error = error {
                            self?.setError("Failed to add habit: \(error.localizedDescription)")
                            AnalyticsService.shared.recordError(error)
                        } else {
                            Logger.shared.dataInfo("Habit added successfully: \(habit.name)")
                            AnalyticsService.shared.trackCustomEvent(name: "habit_created", parameters: [
                                "frequency": habit.frequency.rawValue,
                                "target_count": habit.targetCount
                            ])
                            self?.clearError()
                        }
                    }
                }
        } catch {
            setLoading(false)
            setError("Failed to encode habit: \(error.localizedDescription)")
            AnalyticsService.shared.recordError(error)
        }
    }
    
    func updateHabit(_ habit: Habit) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        do {
            let _ = try db.collection("users").document(userId).collection("habits")
                .document(habit.id).setData(from: habit) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.setLoading(false)
                        
                        if let error = error {
                            self?.setError("Failed to update habit: \(error.localizedDescription)")
                            AnalyticsService.shared.recordError(error)
                        } else {
                            Logger.shared.dataInfo("Habit updated successfully: \(habit.name)")
                            AnalyticsService.shared.trackCustomEvent(name: "habit_updated")
                            self?.clearError()
                        }
                    }
                }
        } catch {
            setLoading(false)
            setError("Failed to encode habit: \(error.localizedDescription)")
            AnalyticsService.shared.recordError(error)
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        db.collection("users").document(userId).collection("habits")
            .document(habit.id).delete { [weak self] error in
                DispatchQueue.main.async {
                    self?.setLoading(false)
                    
                    if let error = error {
                        self?.setError("Failed to delete habit: \(error.localizedDescription)")
                        AnalyticsService.shared.recordError(error)
                    } else {
                        Logger.shared.dataInfo("Habit deleted successfully: \(habit.name)")
                        AnalyticsService.shared.trackCustomEvent(name: "habit_deleted")
                        self?.clearError()
                    }
                }
            }
    }
    
    func toggleHabitEntry(_ habit: Habit, for date: Date) {
        var updatedHabit = habit
        updatedHabit.toggleEntry(for: date)
        
        updateHabit(updatedHabit)
        
        AnalyticsService.shared.trackCustomEvent(name: "habit_entry_toggled", parameters: [
            "habit_id": habit.id,
            "date": date.timeIntervalSince1970
        ])
    }
    
    func addHabitEntry(_ habit: Habit, entry: HabitEntry) {
        var updatedHabit = habit
        updatedHabit.addEntry(entry)
        
        updateHabit(updatedHabit)
        
        if entry.isCompleted {
            AnalyticsService.shared.trackCustomEvent(name: "habit_completed", parameters: [
                "habit_id": habit.id,
                "streak": updatedHabit.currentStreak
            ])
        }
    }
    
    // MARK: - Statistics and Analytics
    func getHabitStatistics(_ habit: Habit) -> HabitStatistics {
        let today = Date()
        let calendar = Calendar.current
        
        let completedEntries = habit.entries.filter { $0.isCompleted }
        let daysSinceCreation = calendar.dateComponents([.day], from: habit.createdAt, to: today).day ?? 0 + 1
        
        let completionRate = daysSinceCreation > 0 ? Double(completedEntries.count) / Double(daysSinceCreation) : 0
        
        // Calculate longest streak
        let sortedEntries = habit.entries.sorted { $0.date < $1.date }
        var longestStreak = 0
        var currentStreakCount = 0
        
        for entry in sortedEntries {
            if entry.isCompleted {
                currentStreakCount += 1
                longestStreak = max(longestStreak, currentStreakCount)
            } else {
                currentStreakCount = 0
            }
        }
        
        // This week completion
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let thisWeekEntries = habit.entries.filter { entry in
            entry.date >= startOfWeek && entry.isCompleted
        }
        
        // This month completion
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let thisMonthEntries = habit.entries.filter { entry in
            entry.date >= startOfMonth && entry.isCompleted
        }
        
        return HabitStatistics(
            totalCompletions: completedEntries.count,
            currentStreak: habit.currentStreak,
            longestStreak: longestStreak,
            completionRate: completionRate,
            thisWeekCompletions: thisWeekEntries.count,
            thisMonthCompletions: thisMonthEntries.count,
            daysSinceCreation: daysSinceCreation
        )
    }
    
    // MARK: - Filtering
    func getActiveHabits() -> [Habit] {
        return habits.filter { $0.isActive }
    }
    
    func getHabitsForToday() -> [Habit] {
        let today = Date()
        let calendar = Calendar.current
        
        return habits.filter { habit in
            guard habit.isActive else { return false }
            
            // Check if habit has been completed today
            let todayEntry = habit.entries.first { entry in
                calendar.isDate(entry.date, inSameDayAs: today)
            }
            
            return todayEntry?.isCompleted != true
        }
    }
    
    func getCompletedHabitsForToday() -> [Habit] {
        let today = Date()
        let calendar = Calendar.current
        
        return habits.filter { habit in
            guard habit.isActive else { return false }
            
            let todayEntry = habit.entries.first { entry in
                calendar.isDate(entry.date, inSameDayAs: today)
            }
            
            return todayEntry?.isCompleted == true
        }
    }
    
    // MARK: - Private Helpers
    private func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    private func setError(_ message: String) {
        errorMessage = message
        Logger.shared.dataError(message)
    }
    
    private func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types
struct HabitStatistics {
    let totalCompletions: Int
    let currentStreak: Int
    let longestStreak: Int
    let completionRate: Double
    let thisWeekCompletions: Int
    let thisMonthCompletions: Int
    let daysSinceCreation: Int
    
    var completionPercentage: Int {
        Int(completionRate * 100)
    }
}