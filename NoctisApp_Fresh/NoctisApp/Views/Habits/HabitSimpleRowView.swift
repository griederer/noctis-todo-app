//
//  HabitSimpleRowView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-12.
//

import SwiftUI

struct HabitSimpleRowView: View {
    let habit: Habit
    let onToggle: () -> Void
    
    private var isCompletedToday: Bool {
        let today = Date()
        let calendar = Calendar.current
        
        return habit.entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: today) && entry.isCompleted
        }
    }
    
    private var habitColor: Color {
        switch habit.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Habit Icon
            Circle()
                .fill(habitColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: habit.icon)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                )
            
            // Habit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = habit.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Text(habit.frequency.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(habitColor.opacity(0.1))
                        .foregroundColor(habitColor)
                        .cornerRadius(8)
                    
                    if habit.targetCount > 1 {
                        Text("Target: \(habit.targetCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Check Button
            Button(action: onToggle) {
                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompletedToday ? habitColor : .gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    VStack {
        HabitSimpleRowView(
            habit: Habit(name: "Drink Water", description: "8 glasses daily", frequency: .daily, targetCount: 8, color: "blue", icon: "drop.fill")
        ) {
            print("Toggled")
        }
        
        HabitSimpleRowView(
            habit: Habit(name: "Exercise", description: "30 minutes workout", frequency: .daily, targetCount: 1, color: "green", icon: "figure.walk")
        ) {
            print("Toggled")
        }
    }
    .padding()
}