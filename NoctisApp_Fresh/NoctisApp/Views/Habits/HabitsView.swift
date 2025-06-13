//
//  HabitsView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct HabitsView: View {
    @StateObject private var dataStore = SharedDataStore.shared
    @State private var selectedDate = Date()
    @State private var showingAddHabit = false
    @State private var newHabitName = ""
    @State private var newHabitDescription = ""
    @State private var newHabitColor = "blue"
    @State private var newHabitIcon = "star.fill"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Habits")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingAddHabit = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Today's Progress
                    VStack(spacing: 8) {
                        HStack {
                            Text("Today's Progress")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(completedHabitsCount)/\(dataStore.habits.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Habits List
                List {
                    ForEach(dataStore.habits) { habit in
                        HabitRow(habit: habit)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingAddHabit) {
            NavigationView {
                Form {
                    Section(header: Text("Habit Details")) {
                        TextField("Habit Name", text: $newHabitName)
                        TextField("Description", text: $newHabitDescription)
                        
                        Picker("Color", selection: $newHabitColor) {
                            Text("Blue").tag("blue")
                            Text("Green").tag("green")
                            Text("Orange").tag("orange")
                            Text("Purple").tag("purple")
                            Text("Red").tag("red")
                            Text("Yellow").tag("yellow")
                        }
                        
                        Picker("Icon", selection: $newHabitIcon) {
                            Text("Star").tag("star.fill")
                            Text("Drop").tag("drop.fill")
                            Text("Heart").tag("heart.fill")
                            Text("Leaf").tag("leaf.fill")
                            Text("Dumbbell").tag("dumbbell.fill")
                            Text("Book").tag("book.fill")
                        }
                    }
                }
                .navigationTitle("New Habit")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingAddHabit = false
                        newHabitName = ""
                        newHabitDescription = ""
                    },
                    trailing: Button("Save") {
                        let newHabit = Habit(
                            name: newHabitName,
                            description: newHabitDescription,
                            frequency: .daily,
                            targetCount: 1,
                            color: newHabitColor,
                            icon: newHabitIcon
                        )
                        dataStore.addHabit(newHabit)
                        showingAddHabit = false
                        newHabitName = ""
                        newHabitDescription = ""
                    }
                    .disabled(newHabitName.isEmpty)
                )
            }
            .preferredColorScheme(.light)
        }
    }
    
    var completedHabitsCount: Int {
        dataStore.getCompletedHabitsToday()
    }
    
    var progressPercentage: Double {
        guard !dataStore.habits.isEmpty else { return 0 }
        return Double(completedHabitsCount) / Double(dataStore.habits.count)
    }
    
    func habitColor(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        default: return .gray
        }
    }
}

// MARK: - HabitRow Component
struct HabitRow: View {
    let habit: Habit
    @StateObject private var dataStore = SharedDataStore.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Habit Icon
            Circle()
                .fill(habitColor(habit.color))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: habit.icon)
                        .foregroundColor(.white)
                        .font(.title3)
                )
            
            // Habit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                
                if let description = habit.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Check button
            Button(action: { 
                dataStore.toggleHabitEntry(habitId: habit.id)
            }) {
                Image(systemName: dataStore.isHabitCompletedToday(habitId: habit.id) ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(dataStore.isHabitCompletedToday(habitId: habit.id) ? habitColor(habit.color) : .gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    func getCurrentCount() -> Int {
        let today = Date()
        let calendar = Calendar.current
        
        return habit.entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: today) && entry.isCompleted
        }.count
    }
    
    
    func habitColor(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        default: return .gray
        }
    }
}

#Preview {
    HabitsView()
}