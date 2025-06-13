import Foundation
import FirebaseFirestore
import Combine

class JournalFirebaseRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let authService = AuthenticationService.shared
    
    @Published var entries: [JournalEntry] = []
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
                    self?.entries = []
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
            Logger.shared.dataError("No user ID available for listening to journal entries")
            return
        }
        
        stopListening() // Stop any existing listener
        
        Logger.shared.dataInfo("Starting to listen for journal entries for user: \(userId)")
        
        listener = db.collection("users").document(userId).collection("journal_entries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.setError("Failed to fetch journal entries: \(error.localizedDescription)")
                        AnalyticsService.shared.recordError(error)
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.setError("No journal entries found")
                        return
                    }
                    
                    self?.entries = documents.compactMap { document in
                        do {
                            var entry = try document.data(as: JournalEntry.self)
                            return entry
                        } catch {
                            Logger.shared.dataError("Failed to decode journal entry: \(error)")
                            return nil
                        }
                    }
                    
                    Logger.shared.dataInfo("Fetched \(self?.entries.count ?? 0) journal entries")
                    self?.clearError()
                }
            }
    }
    
    private func stopListening() {
        listener?.remove()
        listener = nil
        Logger.shared.dataInfo("Stopped listening for journal entries")
    }
    
    // MARK: - CRUD Operations
    func addEntry(_ entry: JournalEntry) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        do {
            let _ = try db.collection("users").document(userId).collection("journal_entries")
                .document(entry.id).setData(from: entry) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.setLoading(false)
                        
                        if let error = error {
                            self?.setError("Failed to add journal entry: \(error.localizedDescription)")
                            AnalyticsService.shared.recordError(error)
                        } else {
                            Logger.shared.dataInfo("Journal entry added successfully")
                            AnalyticsService.shared.trackCustomEvent(name: "journal_entry_created", parameters: [
                                "word_count": entry.content.split(separator: " ").count,
                                "has_mood": entry.mood != nil,
                                "has_tags": !entry.tags.isEmpty
                            ])
                            self?.clearError()
                        }
                    }
                }
        } catch {
            setLoading(false)
            setError("Failed to encode journal entry: \(error.localizedDescription)")
            AnalyticsService.shared.recordError(error)
        }
    }
    
    func updateEntry(_ entry: JournalEntry) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        do {
            let _ = try db.collection("users").document(userId).collection("journal_entries")
                .document(entry.id).setData(from: entry) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.setLoading(false)
                        
                        if let error = error {
                            self?.setError("Failed to update journal entry: \(error.localizedDescription)")
                            AnalyticsService.shared.recordError(error)
                        } else {
                            Logger.shared.dataInfo("Journal entry updated successfully")
                            AnalyticsService.shared.trackCustomEvent(name: "journal_entry_updated")
                            self?.clearError()
                        }
                    }
                }
        } catch {
            setLoading(false)
            setError("Failed to encode journal entry: \(error.localizedDescription)")
            AnalyticsService.shared.recordError(error)
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        guard let userId = authService.currentUser?.id else {
            setError("User not authenticated")
            return
        }
        
        setLoading(true)
        
        db.collection("users").document(userId).collection("journal_entries")
            .document(entry.id).delete { [weak self] error in
                DispatchQueue.main.async {
                    self?.setLoading(false)
                    
                    if let error = error {
                        self?.setError("Failed to delete journal entry: \(error.localizedDescription)")
                        AnalyticsService.shared.recordError(error)
                    } else {
                        Logger.shared.dataInfo("Journal entry deleted successfully")
                        AnalyticsService.shared.trackCustomEvent(name: "journal_entry_deleted")
                        self?.clearError()
                    }
                }
            }
    }
    
    // MARK: - Filtering and Searching
    func getEntriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: date)
        }
    }
    
    func getEntriesForDateRange(from startDate: Date, to endDate: Date) -> [JournalEntry] {
        return entries.filter { entry in
            entry.createdAt >= startDate && entry.createdAt <= endDate
        }
    }
    
    func searchEntries(query: String) -> [JournalEntry] {
        guard !query.isEmpty else { return entries }
        
        let lowercaseQuery = query.lowercased()
        return entries.filter { entry in
            entry.title.lowercased().contains(lowercaseQuery) ||
            entry.content.lowercased().contains(lowercaseQuery) ||
            entry.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    func getEntriesByMood(_ mood: Mood) -> [JournalEntry] {
        return entries.filter { entry in
            entry.mood == mood
        }
    }
    
    func getEntriesWithTag(_ tag: String) -> [JournalEntry] {
        return entries.filter { entry in
            entry.tags.contains(tag)
        }
    }
    
    // MARK: - Statistics
    func getJournalStatistics() -> JournalStatistics {
        let totalEntries = entries.count
        let currentDate = Date()
        let calendar = Calendar.current
        
        // This week entries
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start ?? currentDate
        let thisWeekEntries = entries.filter { entry in
            entry.createdAt >= startOfWeek
        }
        
        // This month entries
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let thisMonthEntries = entries.filter { entry in
            entry.createdAt >= startOfMonth
        }
        
        // Current streak
        let currentStreak = calculateCurrentStreak()
        
        // Longest streak
        let longestStreak = calculateLongestStreak()
        
        // Average words per entry
        let totalWords = entries.reduce(0) { total, entry in
            total + entry.content.split(separator: " ").count
        }
        let averageWords = totalEntries > 0 ? Double(totalWords) / Double(totalEntries) : 0
        
        // Most common mood
        let moodCounts = Dictionary(grouping: entries.compactMap { $0.mood }, by: { $0 })
            .mapValues { $0.count }
        let mostCommonMood = moodCounts.max(by: { $0.value < $1.value })?.key
        
        // All unique tags
        let allTags = Set(entries.flatMap { $0.tags })
        
        return JournalStatistics(
            totalEntries: totalEntries,
            thisWeekEntries: thisWeekEntries.count,
            thisMonthEntries: thisMonthEntries.count,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            averageWordsPerEntry: Int(averageWords),
            mostCommonMood: mostCommonMood,
            uniqueTags: Array(allTags)
        )
    }
    
    // MARK: - Streak Calculation
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        // Check if there's an entry for today
        let hasEntryToday = entries.contains { entry in
            calendar.isDate(entry.createdAt, inSameDayAs: today)
        }
        
        if hasEntryToday {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        } else {
            // If no entry today, check yesterday and start from there
            currentDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        }
        
        // Count consecutive days with entries going backwards
        while true {
            let hasEntry = entries.contains { entry in
                calendar.isDate(entry.createdAt, inSameDayAs: currentDate)
            }
            
            if hasEntry {
                if hasEntryToday || streak > 0 {
                    streak += 1
                } else {
                    streak = 1
                }
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return hasEntryToday ? streak : 0
    }
    
    private func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.createdAt < $1.createdAt }
        
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for entry in sortedEntries {
            if let last = lastDate {
                let daysBetween = calendar.dateComponents([.day], from: last, to: entry.createdAt).day ?? 0
                
                if daysBetween == 1 {
                    // Consecutive day
                    currentStreak += 1
                } else if daysBetween == 0 {
                    // Same day, don't increment
                    continue
                } else {
                    // Gap in days, reset streak
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastDate = entry.createdAt
        }
        
        return max(longestStreak, currentStreak)
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
struct JournalStatistics {
    let totalEntries: Int
    let thisWeekEntries: Int
    let thisMonthEntries: Int
    let currentStreak: Int
    let longestStreak: Int
    let averageWordsPerEntry: Int
    let mostCommonMood: Mood?
    let uniqueTags: [String]
    
    var hasEntries: Bool {
        totalEntries > 0
    }
}