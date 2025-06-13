import SwiftUI

struct DashboardView: View {
    @StateObject private var todoViewModel = TodoListViewModel()
    @StateObject private var habitViewModel = HabitListViewModel()
    @StateObject private var journalViewModel = JournalListViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    welcomeHeader
                    
                    // Quick Stats Overview
                    quickStatsSection
                    
                    // Today's Focus
                    todaysFocusSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Noctis")
            .navigationBarTitleDisplayMode(.large)
            .background(Color("Background"))
            .refreshable {
                // Refresh data
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            AnalyticsService.shared.trackScreen("Dashboard")
        }
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingMessage)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("Ready to make today productive?")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                // Moon phase or time-based icon
                Image(systemName: currentTimeIcon)
                    .font(.title)
                    .foregroundColor(Color("Primary"))
            }
            
            // Date
            Text(Date().formatted(date: .complete, time: .omitted))
                .font(.caption)
                .foregroundColor(Color("TextTertiary"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Overview")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DashboardStatCard(
                    title: "Tasks",
                    value: "\(todoViewModel.pendingTodos)",
                    subtitle: "pending today",
                    icon: "checkmark.circle",
                    color: .blue,
                    progress: todoViewModel.totalTodos > 0 ? Double(todoViewModel.completedTodos) / Double(todoViewModel.totalTodos) : 0
                )
                
                DashboardStatCard(
                    title: "Habits",
                    value: "\(habitViewModel.completedTodayCount)",
                    subtitle: "completed today",
                    icon: "repeat",
                    color: .green,
                    progress: habitViewModel.todayCompletionRate
                )
                
                DashboardStatCard(
                    title: "Journal",
                    value: journalViewModel.hasEntryForToday() ? "✓" : "—",
                    subtitle: journalViewModel.hasEntryForToday() ? "written today" : "not written",
                    icon: "book.closed",
                    color: .purple,
                    progress: journalViewModel.hasEntryForToday() ? 1.0 : 0.0
                )
                
                DashboardStatCard(
                    title: "Streak",
                    value: "\(journalViewModel.statistics.currentStreak)",
                    subtitle: "day journal streak",
                    icon: "flame",
                    color: .orange,
                    progress: nil
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Today's Focus
    private var todaysFocusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Focus")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            VStack(spacing: 8) {
                // High priority tasks
                let highPriorityTasks = todoViewModel.filteredTodos.filter { $0.priority == .high && !$0.isCompleted }.prefix(3)
                
                if !highPriorityTasks.isEmpty {
                    ForEach(Array(highPriorityTasks), id: \.id) { todo in
                        DashboardTaskRow(todo: todo) {
                            todoViewModel.toggleCompletion(todo)
                        }
                    }
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("No high priority tasks today!")
                            .font(.subheadline)
                            .foregroundColor(Color("TextSecondary"))
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                
                // Habits for today
                let pendingHabits = habitViewModel.filteredHabits.filter { habit in
                    habitViewModel.getHabitStatistics(habit).totalCompletions == 0 // Simplified check
                }.prefix(2)
                
                ForEach(Array(pendingHabits), id: \.id) { habit in
                    DashboardHabitRow(habit: habit) {
                        habitViewModel.toggleHabitEntry(habit)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            VStack(spacing: 8) {
                // Recent journal entry
                if let recentEntry = journalViewModel.filteredEntries.first {
                    DashboardJournalRow(entry: recentEntry) {
                        journalViewModel.showEntryDetail(recentEntry)
                    }
                }
                
                // Recently completed tasks
                let recentCompletedTasks = todoViewModel.filteredTodos.filter { $0.isCompleted }.prefix(2)
                ForEach(Array(recentCompletedTasks), id: \.id) { todo in
                    DashboardCompletedTaskRow(todo: todo)
                }
                
                if recentEntry == nil && recentCompletedTasks.isEmpty {
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(Color("TextTertiary"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "Add Task",
                    icon: "plus.circle",
                    color: .blue
                ) {
                    todoViewModel.showAddTodo()
                }
                
                QuickActionButton(
                    title: "Add Habit",
                    icon: "repeat",
                    color: .green
                ) {
                    habitViewModel.showAddHabit()
                }
                
                QuickActionButton(
                    title: "Write Entry",
                    icon: "square.and.pencil",
                    color: .purple
                ) {
                    journalViewModel.showAddEntry()
                }
                
                QuickActionButton(
                    title: "View Stats",
                    icon: "chart.bar",
                    color: .orange
                ) {
                    // Could navigate to a detailed stats view
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Surface"))
        )
    }
    
    // MARK: - Helper Properties
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    private var currentTimeIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<18:
            return "sun.max.fill"
        case 18..<22:
            return "sunset.fill"
        default:
            return "moon.stars.fill"
        }
    }
    
    private var recentEntry: JournalEntry? {
        journalViewModel.filteredEntries.first
    }
}

// MARK: - Supporting Views
struct DashboardStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color("TextPrimary"))
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(Color("TextSecondary"))
            
            if let progress = progress {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Background"))
        )
    }
}

struct DashboardTaskRow: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : todo.priority.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .font(.subheadline)
                    .foregroundColor(Color("TextPrimary"))
                    .strikethrough(todo.isCompleted)
                
                HStack {
                    Text(todo.priority.displayName)
                        .font(.caption2)
                        .foregroundColor(todo.priority.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(todo.priority.color.opacity(0.2))
                        )
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct DashboardHabitRow: View {
    let habit: Habit
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: habit.icon)
                    .foregroundColor(Color(habit.color))
            }
            
            Text(habit.name)
                .font(.subheadline)
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
            
            Text("Tap to complete")
                .font(.caption2)
                .foregroundColor(Color("TextTertiary"))
        }
        .padding(.vertical, 4)
    }
}

struct DashboardJournalRow: View {
    let entry: JournalEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color("TextPrimary"))
                    
                    Spacer()
                    
                    if let mood = entry.mood {
                        Text(mood.emoji)
                            .font(.caption)
                    }
                }
                
                Text(String(entry.content.prefix(60)) + "...")
                    .font(.caption)
                    .foregroundColor(Color("TextSecondary"))
                    .lineLimit(2)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

struct DashboardCompletedTaskRow: View {
    let todo: Todo
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            
            Text("Completed: \(todo.title)")
                .font(.caption)
                .foregroundColor(Color("TextSecondary"))
                .strikethrough()
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color("TextPrimary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Background"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    DashboardView()
}