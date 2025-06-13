import SwiftUI

struct ModernTodoRowView: View {
    let todo: Todo
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onPriorityChange: (Priority) -> Void
    
    @State private var showingPriorityMenu = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: onToggleCompletion) {
                ZStack {
                    Circle()
                        .fill(todo.isCompleted ? todo.priority.color : Color("Surface"))
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .stroke(todo.priority.borderColor, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if todo.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(todo.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(todo.isCompleted ? Color("TextSecondary") : Color("TextPrimary"))
                        .strikethrough(todo.isCompleted)
                    
                    Spacer()
                    
                    // Due Date
                    if let dueDate = todo.dueDate {
                        dueDateView(dueDate)
                    }
                }
                
                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(2)
                }
                
                // Priority and Metadata
                HStack {
                    // Priority Badge
                    priorityBadge
                    
                    Spacer()
                    
                    // Created Date
                    Text(todo.createdAt.timeAgoDisplay())
                        .font(.caption2)
                        .foregroundColor(Color("TextTertiary"))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(todo.isCompleted ? Color("Surface").opacity(0.5) : todo.priority.paleColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(todo.priority.borderColor.opacity(0.3), lineWidth: 1)
        )
        .contextMenu {
            contextMenuItems
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions
        }
        .opacity(todo.isCompleted ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: todo.isCompleted)
    }
    
    // MARK: - Due Date View
    private func dueDateView(_ dueDate: Date) -> some View {
        let isOverdue = dueDate < Date() && !todo.isCompleted
        let isToday = Calendar.current.isDateInToday(dueDate)
        
        return HStack(spacing: 4) {
            Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                .font(.caption2)
                .foregroundColor(isOverdue ? .red : isToday ? .orange : Color("TextSecondary"))
            
            Text(dueDate.dueDateDisplay())
                .font(.caption2)
                .foregroundColor(isOverdue ? .red : isToday ? .orange : Color("TextSecondary"))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill((isOverdue ? Color.red : isToday ? Color.orange : Color("Surface")).opacity(0.2))
        )
    }
    
    // MARK: - Priority Badge
    private var priorityBadge: some View {
        Button(action: { showingPriorityMenu = true }) {
            HStack(spacing: 4) {
                Circle()
                    .fill(todo.priority.color)
                    .frame(width: 8, height: 8)
                
                Text(todo.priority.displayName)
                    .font(.caption2)
                    .foregroundColor(Color("TextSecondary"))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color("Surface"))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Change Priority", isPresented: $showingPriorityMenu) {
            ForEach(Priority.allCases, id: \.self) { priority in
                Button(priority.displayName) {
                    onPriorityChange(priority)
                }
            }
        }
    }
    
    // MARK: - Context Menu
    private var contextMenuItems: some View {
        Group {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onToggleCompletion) {
                Label(
                    todo.isCompleted ? "Mark Incomplete" : "Mark Complete",
                    systemImage: todo.isCompleted ? "circle" : "checkmark.circle"
                )
            }
            
            Menu("Change Priority") {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Button(priority.displayName) {
                        onPriorityChange(priority)
                    }
                }
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
                    todo.isCompleted ? "Incomplete" : "Complete",
                    systemImage: todo.isCompleted ? "circle" : "checkmark"
                )
            }
            .tint(.green)
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("Background"))
        )
    }
}

struct PriorityFilterChip: View {
    let priority: Priority?
    let selectedPriority: Priority?
    let onTap: () -> Void
    
    private var isSelected: Bool {
        if priority == nil && selectedPriority == nil {
            return true
        }
        return priority == selectedPriority
    }
    
    private var displayName: String {
        priority?.displayName ?? "All"
    }
    
    private var chipColor: Color {
        if isSelected {
            return priority?.color ?? Color("Primary")
        } else {
            return Color("Surface")
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let priority = priority {
                    Circle()
                        .fill(priority.color)
                        .frame(width: 8, height: 8)
                }
                
                Text(displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : Color("TextPrimary"))
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

// MARK: - Date Extensions
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func dueDateDisplay() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: self)
        }
    }
}

#Preview {
    VStack {
        ModernTodoRowView(
            todo: Todo(
                title: "Complete project documentation",
                description: "Write comprehensive documentation for the new features",
                priority: .high,
                dueDate: Date().addingTimeInterval(86400)
            ),
            onToggleCompletion: {},
            onEdit: {},
            onDelete: {},
            onPriorityChange: { _ in }
        )
        
        ModernTodoRowView(
            todo: Todo(
                title: "Review pull requests",
                priority: .medium
            ),
            onToggleCompletion: {},
            onEdit: {},
            onDelete: {},
            onPriorityChange: { _ in }
        )
    }
    .padding()
    .background(Color("Background"))
    .preferredColorScheme(.dark)
}