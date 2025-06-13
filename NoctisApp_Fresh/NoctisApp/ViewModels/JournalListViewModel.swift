import Foundation
import SwiftUI
import Combine

class JournalListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedMoodFilter: Mood?
    @Published var selectedDateFilter: DateFilter = .all
    @Published var showingAddEntry = false
    @Published var selectedEntry: JournalEntry?
    @Published var showingEditEntry = false
    @Published var showingEntryDetail = false
    
    private let repository = JournalFirebaseRepository()
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
    var filteredEntries: [JournalEntry] {
        var filtered = repository.entries
        
        // Apply date filter
        switch selectedDateFilter {
        case .all:
            break
        case .today:
            filtered = repository.getEntriesForDate(Date())
        case .thisWeek:
            let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            filtered = repository.getEntriesForDateRange(from: startOfWeek, to: Date())
        case .thisMonth:
            let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
            filtered = repository.getEntriesForDateRange(from: startOfMonth, to: Date())
        }
        
        // Apply mood filter
        if let mood = selectedMoodFilter {
            filtered = filtered.filter { $0.mood == mood }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = repository.searchEntries(query: searchText).filter { entry in
                filtered.contains { $0.id == entry.id }
            }
        }
        
        return filtered
    }
    
    var totalEntries: Int {
        repository.entries.count
    }
    
    var hasEntries: Bool {
        !filteredEntries.isEmpty
    }
    
    var emptyStateMessage: String {
        if searchText.isEmpty && selectedMoodFilter == nil && selectedDateFilter == .all {
            return "No journal entries yet. Start writing your thoughts!"
        } else {
            return "No entries match your filters"
        }
    }
    
    var statistics: JournalStatistics {
        repository.getJournalStatistics()
    }
    
    // MARK: - Actions
    func addEntry(title: String, content: String, mood: Mood?, tags: [String]) {
        let entry = JournalEntry(
            title: title,
            content: content,
            mood: mood,
            tags: tags
        )
        
        repository.addEntry(entry)
        showingAddEntry = false
        
        AnalyticsService.shared.trackCustomEvent(name: "journal_entry_created_from_list", parameters: [
            "word_count": content.split(separator: " ").count,
            "has_mood": mood != nil,
            "tag_count": tags.count
        ])
    }
    
    func updateEntry(_ entry: JournalEntry, title: String, content: String, mood: Mood?, tags: [String]) {
        var updatedEntry = entry
        updatedEntry.title = title
        updatedEntry.content = content
        updatedEntry.mood = mood
        updatedEntry.tags = tags
        updatedEntry.updatedAt = Date()
        
        repository.updateEntry(updatedEntry)
        showingEditEntry = false
        selectedEntry = nil
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        repository.deleteEntry(entry)
        
        if selectedEntry?.id == entry.id {
            selectedEntry = nil
            showingEditEntry = false
            showingEntryDetail = false
        }
    }
    
    func getEntryForDate(_ date: Date) -> JournalEntry? {
        return repository.getEntriesForDate(date).first
    }
    
    // MARK: - Filtering
    func setMoodFilter(_ mood: Mood?) {
        selectedMoodFilter = mood
        AnalyticsService.shared.trackCustomEvent(name: "journal_mood_filter_applied", parameters: [
            "mood": mood?.rawValue ?? "none"
        ])
    }
    
    func setDateFilter(_ filter: DateFilter) {
        selectedDateFilter = filter
        AnalyticsService.shared.trackCustomEvent(name: "journal_date_filter_applied", parameters: [
            "filter": filter.rawValue
        ])
    }
    
    func clearFilters() {
        searchText = ""
        selectedMoodFilter = nil
        selectedDateFilter = .all
    }
    
    // MARK: - Navigation
    func showAddEntry() {
        showingAddEntry = true
        AnalyticsService.shared.trackCustomEvent(name: "add_journal_entry_initiated")
    }
    
    func showEditEntry(_ entry: JournalEntry) {
        selectedEntry = entry
        showingEditEntry = true
        AnalyticsService.shared.trackCustomEvent(name: "edit_journal_entry_initiated", parameters: [
            "entry_id": entry.id
        ])
    }
    
    func showEntryDetail(_ entry: JournalEntry) {
        selectedEntry = entry
        showingEntryDetail = true
        AnalyticsService.shared.trackCustomEvent(name: "journal_entry_detail_viewed", parameters: [
            "entry_id": entry.id
        ])
    }
    
    func dismissModals() {
        showingAddEntry = false
        showingEditEntry = false
        showingEntryDetail = false
        selectedEntry = nil
    }
    
    // MARK: - Quick Actions
    func createQuickEntry(content: String, mood: Mood? = nil) {
        let title = generateTitleFromContent(content)
        addEntry(title: title, content: content, mood: mood, tags: [])
    }
    
    func getTodaysEntry() -> JournalEntry? {
        return repository.getEntriesForDate(Date()).first
    }
    
    func hasEntryForToday() -> Bool {
        return getTodaysEntry() != nil
    }
    
    // MARK: - Tag Management
    func getAllTags() -> [String] {
        return statistics.uniqueTags.sorted()
    }
    
    func getEntriesWithTag(_ tag: String) -> [JournalEntry] {
        return repository.getEntriesWithTag(tag)
    }
    
    func getMostUsedTags(limit: Int = 10) -> [String] {
        let allTags = repository.entries.flatMap { $0.tags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
        
        return tagCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }
    
    // MARK: - Calendar Integration
    func getCalendarData() -> [Date: Int] {
        let calendar = Calendar.current
        var calendarData: [Date: Int] = [:]
        
        for entry in repository.entries {
            let dayStart = calendar.startOfDay(for: entry.createdAt)
            calendarData[dayStart, default: 0] += 1
        }
        
        return calendarData
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Helpers
    private func generateTitleFromContent(_ content: String) -> String {
        let words = content.prefix(50).split(separator: " ")
        let title = words.prefix(8).joined(separator: " ")
        return title.isEmpty ? "Journal Entry" : String(title)
    }
}

// MARK: - Supporting Types
enum DateFilter: String, CaseIterable {
    case all = "all"
    case today = "today"
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
    
    var displayName: String {
        switch self {
        case .all:
            return "All Time"
        case .today:
            return "Today"
        case .thisWeek:
            return "This Week"
        case .thisMonth:
            return "This Month"
        }
    }
}