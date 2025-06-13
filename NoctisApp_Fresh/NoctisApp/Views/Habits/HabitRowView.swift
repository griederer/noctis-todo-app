import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDetail: () -> Void
    let onDelete: () -> Void
    
    @State private var showingOptions = false
    
    private var todayEntry: HabitEntry? {
        let today = Date()
        let calendar = Calendar.current
        
        return habit.entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: today)
        }
    }
    
    private var isCompletedToday: Bool {
        todayEntry?.isCompleted == true
    }
    
    private var habitColor: Color {
        Color(habit.color)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: onToggleCompletion) {
                ZStack {
                    Circle()
                        .fill(isCompletedToday ? habitColor : Color("Surface"))
                        .frame(width: 28, height: 28)
                    
                    Circle()
                        .stroke(habitColor, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Habit Icon
            Image(systemName: habit.icon)
                .font(.system(size: 20))
                .foregroundColor(habitColor)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isCompletedToday ? Color("TextSecondary") : Color("TextPrimary"))
                        .strikethrough(isCompletedToday)
                    
                    Spacer()
                    
                    // Streak Badge
                    if habit.currentStreak > 0 {
                        streakBadge
                    }
                }
                
                if let description = habit.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                }
                
                // Frequency and Target
                HStack {
                    frequencyBadge
                    
                    if habit.targetCount > 1 {
                        targetBadge
                    }
                    
                    Spacer()
                    
                    // Status for today
                    statusIndicator
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCompletedToday ? Color("Surface").opacity(0.5) : habitColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(habitColor.opacity(0.3), lineWidth: 1)
        )
        .contextMenu {
            contextMenuItems
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions
        }
        .opacity(habit.isActive ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isCompletedToday)
        .onTapGesture {
            onDetail()
        }
    }
    
    // MARK: - Streak Badge
    private var streakBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundColor(.orange)
            
            Text("\(habit.currentStreak)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.2))
        )
    }
    
    // MARK: - Frequency Badge
    private var frequencyBadge: some View {
        Text(habit.frequency.displayName)
            .font(.caption2)
            .foregroundColor(Color("TextSecondary"))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color("Surface"))
            )
    }
    
    // MARK: - Target Badge
    private var targetBadge: some View {
        Text("\(habit.targetCount)x")
            .font(.caption2)
            .foregroundColor(Color("TextSecondary"))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color("Surface"))
            )
    }
    
    // MARK: - Status Indicator
    private var statusIndicator: some View {
        Group {
            if isCompletedToday {
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Done")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            } else {
                HStack(spacing: 2) {
                    Image(systemName: "circle")
                        .font(.caption2)
                        .foregroundColor(Color("TextTertiary"))
                    
                    Text("Pending")
                        .font(.caption2)
                        .foregroundColor(Color("TextTertiary"))
                }
            }
        }
    }
    
    // MARK: - Context Menu
    private var contextMenuItems: some View {
        Group {
            Button(action: onDetail) {
                Label("View Details", systemImage: "chart.line.uptrend.xyaxis")
            }
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onToggleCompletion) {
                Label(
                    isCompletedToday ? "Mark Incomplete" : "Mark Complete",
                    systemImage: isCompletedToday ? "circle" : "checkmark.circle"
                )
            }
            
            Divider()
            
            if habit.isActive {
                Button("Deactivate") {
                    // Handle deactivation
                }
                .foregroundColor(.orange)
            } else {
                Button("Activate") {
                    // Handle activation
                }
                .foregroundColor(.green)
            }
            
            Divider()
            
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Swipe Actions
    private var swipeActions: some View {
        Group {
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
            
            Button(action: onToggleCompletion) {
                Label(
                    isCompletedToday ? "Undo" : "Done",
                    systemImage: isCompletedToday ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(.green)
        }
    }
}

// MARK: - Supporting Views
struct HabitFilterChip: View {
    let filter: HabitFilter
    let selectedFilter: HabitFilter
    let count: Int
    let onTap: () -> Void
    
    private var isSelected: Bool {
        filter == selectedFilter
    }
    
    private var chipColor: Color {
        if isSelected {
            return Color("Primary")
        } else {
            return Color("Surface")
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(filter.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : Color("TextPrimary"))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : Color("TextSecondary"))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.3) : Color("Background"))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(chipColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        HabitRowView(
            habit: Habit(
                name: "Morning Exercise",
                description: "30 minutes of cardio",
                frequency: .daily,
                targetCount: 1,
                color: "blue",
                icon: "figure.run"
            ),
            onToggleCompletion: {},
            onEdit: {},
            onDetail: {},
            onDelete: {}
        )
        
        HabitRowView(
            habit: Habit(
                name: "Read Book",
                description: "Read for 20 minutes",
                frequency: .daily,
                targetCount: 1,
                color: "green",
                icon: "book.fill"
            ),
            onToggleCompletion: {},
            onEdit: {},
            onDetail: {},
            onDelete: {}
        )
    }
    .padding()
    .background(Color("Background"))
    .preferredColorScheme(.dark)
}