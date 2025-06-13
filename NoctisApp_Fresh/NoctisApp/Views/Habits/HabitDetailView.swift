import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    let viewModel: HabitListViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeframe: StatisticsTimeframe = .month
    
    private var statistics: HabitStatistics {
        viewModel.getHabitStatistics(habit)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    habitHeader
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Progress Chart Placeholder
                    progressSection
                    
                    // Recent Entries
                    recentEntriesSection
                    
                    // Actions
                    actionsSection
                }
                .padding()
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        viewModel.showEditHabit(habit)
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
            }
            .background(Color("Background"))
        }
        .preferredColorScheme(.dark)
        .onAppear {
            AnalyticsService.shared.trackScreen("Habit Detail")
        }
    }
    
    // MARK: - Habit Header
    private var habitHeader: some View {
        VStack(spacing: 16) {
            // Icon and Basic Info
            VStack(spacing: 12) {
                Image(systemName: habit.icon)
                    .font(.system(size: 48))
                    .foregroundColor(Color(habit.color))
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color(habit.color).opacity(0.2))
                    )
                
                VStack(spacing: 4) {
                    Text(habit.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    if let description = habit.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            // Frequency and Target Info
            HStack(spacing: 16) {
                InfoPill(
                    icon: "calendar",
                    text: habit.frequency.displayName,
                    color: Color("Primary")
                )
                
                InfoPill(
                    icon: "target",
                    text: "\(habit.targetCount)x",
                    color: Color(habit.color)
                )
                
                if habit.currentStreak > 0 {
                    InfoPill(
                        icon: "flame.fill",
                        text: "\(habit.currentStreak) day\(habit.currentStreak == 1 ? "" : "s")",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            VStack(spacing: 12) {
                HStack {
                    StatCard(title: "Current Streak", value: "\(statistics.currentStreak)", color: .orange)
                    StatCard(title: "Longest Streak", value: "\(statistics.longestStreak)", color: .green)
                }
                
                HStack {
                    StatCard(title: "This Week", value: "\(statistics.thisWeekCompletions)", color: .blue)
                    StatCard(title: "This Month", value: "\(statistics.thisMonthCompletions)", color: .purple)
                }
                
                HStack {
                    StatCard(title: "Total Completions", value: "\(statistics.totalCompletions)", color: Color("Primary"))
                    StatCard(title: "Success Rate", value: "\(statistics.completionPercentage)%", color: Color(habit.color))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(StatisticsTimeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.displayName)
                            .tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            // Completion Rate Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Completion Rate")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                    
                    Text("\(statistics.completionPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                ProgressView(value: statistics.completionRate)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(habit.color)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Calendar-like view placeholder
            VStack(alignment: .leading, spacing: 8) {
                Text("Last 7 Days")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                
                weeklyCalendarView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Weekly Calendar View
    private var weeklyCalendarView: some View {
        let calendar = Calendar.current
        let today = Date()
        let weekDates = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
        
        return HStack(spacing: 8) {
            ForEach(weekDates, id: \.self) { date in
                let entry = habit.entries.first { entry in
                    calendar.isDate(entry.date, inSameDayAs: date)
                }
                
                VStack(spacing: 4) {
                    Text(calendar.component(.day, from: date).description)
                        .font(.caption2)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Circle()
                        .fill(entry?.isCompleted == true ? Color(habit.color) : Color("Surface"))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color(habit.color).opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
    }
    
    // MARK: - Recent Entries Section
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            if habit.entries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title2)
                        .foregroundColor(Color("TextTertiary"))
                    
                    Text("No entries yet")
                        .font(.body)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Text("Start tracking this habit to see your progress")
                        .font(.caption)
                        .foregroundColor(Color("TextTertiary"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                let recentEntries = habit.entries
                    .sorted { $0.date > $1.date }
                    .prefix(5)
                
                ForEach(Array(recentEntries), id: \.id) { entry in
                    entryRow(entry)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Entry Row
    private func entryRow(_ entry: HabitEntry) -> some View {
        HStack {
            Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(entry.isCompleted ? .green : Color("TextTertiary"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.body)
                    .foregroundColor(Color("TextPrimary"))
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            
            Spacer()
            
            Text(entry.isCompleted ? "Completed" : "Skipped")
                .font(.caption)
                .foregroundColor(entry.isCompleted ? .green : Color("TextTertiary"))
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.toggleHabitEntry(habit)
                
                // Provide immediate feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }) {
                let isCompletedToday = todayEntry?.isCompleted == true
                
                HStack {
                    Image(systemName: isCompletedToday ? "arrow.uturn.backward.circle" : "checkmark.circle.fill")
                    Text(isCompletedToday ? "Mark as Incomplete" : "Mark as Complete")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCompletedToday ? .orange : .green)
                )
            }
            
            Button(action: {
                viewModel.showEditHabit(habit)
                dismiss()
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Habit")
                }
                .foregroundColor(Color("Primary"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("Primary"), lineWidth: 2)
                )
            }
        }
    }
    
    // MARK: - Helper Properties
    private var todayEntry: HabitEntry? {
        let today = Date()
        let calendar = Calendar.current
        
        return habit.entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: today)
        }
    }
}

// MARK: - Supporting Views
struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color("TextPrimary"))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.2))
        )
    }
}

enum StatisticsTimeframe: String, CaseIterable {
    case week = "week"
    case month = "month"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .year:
            return "Year"
        }
    }
}

#Preview {
    HabitDetailView(
        habit: Habit(
            name: "Morning Exercise",
            description: "30 minutes of cardio to start the day",
            frequency: .daily,
            targetCount: 1,
            color: "blue",
            icon: "figure.run"
        ),
        viewModel: HabitListViewModel()
    )
}