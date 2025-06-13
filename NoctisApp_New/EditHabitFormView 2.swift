import SwiftUI

struct EditHabitFormView: View {
    let habit: Habit
    let viewModel: HabitListViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedFrequency = HabitFrequency.daily
    @State private var targetCount = 1
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "circle.fill"
    
    @Environment(\.dismiss) private var dismiss
    
    private let availableColors = ["blue", "green", "orange", "red", "purple", "pink", "teal", "indigo"]
    private let availableIcons = [
        "circle.fill", "star.fill", "heart.fill", "flame.fill",
        "figure.run", "book.fill", "dumbbell.fill", "leaf.fill",
        "drop.fill", "brain.head.profile", "pills.fill", "cup.and.saucer.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $name)
                        .foregroundColor(Color("TextPrimary"))
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .foregroundColor(Color("TextPrimary"))
                        .lineLimit(2...4)
                }
                
                Section("Frequency") {
                    Picker("How often?", selection: $selectedFrequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName)
                                .foregroundColor(Color("TextPrimary"))
                                .tag(frequency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Target") {
                    Stepper("Complete \(targetCount) time\(targetCount == 1 ? "" : "s") per \(selectedFrequency.displayName.lowercased())", 
                            value: $targetCount, in: 1...10)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Section("Appearance") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TextPrimary"))
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                colorButton(color)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TextPrimary"))
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                iconButton(icon)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Statistics") {
                    let stats = viewModel.getHabitStatistics(habit)
                    
                    VStack(spacing: 8) {
                        HStack {
                            StatCard(title: "Current Streak", value: "\(stats.currentStreak)", color: .orange)
                            StatCard(title: "Longest Streak", value: "\(stats.longestStreak)", color: .green)
                            StatCard(title: "Completion Rate", value: "\(stats.completionPercentage)%", color: Color("Primary"))
                        }
                        
                        HStack {
                            StatCard(title: "This Week", value: "\(stats.thisWeekCompletions)", color: .blue)
                            StatCard(title: "This Month", value: "\(stats.thisMonthCompletions)", color: .purple)
                            StatCard(title: "Total", value: "\(stats.totalCompletions)", color: Color("TextSecondary"))
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                Section("Preview") {
                    habitPreview
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                
                Section {
                    Button(action: saveHabit) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Changes")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(selectedColor))
                        )
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                Section {
                    Button(action: toggleActive) {
                        HStack {
                            Image(systemName: habit.isActive ? "pause.circle" : "play.circle")
                            Text(habit.isActive ? "Deactivate Habit" : "Activate Habit")
                        }
                        .foregroundColor(habit.isActive ? .orange : .green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(habit.isActive ? .orange : .green, lineWidth: 2)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Delete") {
                        deleteHabit()
                    }
                    .foregroundColor(.red)
                }
            }
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            setupInitialValues()
            AnalyticsService.shared.trackScreen("Edit Habit Form")
        }
    }
    
    // MARK: - Setup
    private func setupInitialValues() {
        name = habit.name
        description = habit.description ?? ""
        selectedFrequency = habit.frequency
        targetCount = habit.targetCount
        selectedColor = habit.color
        selectedIcon = habit.icon
    }
    
    // MARK: - Color Button
    private func colorButton(_ color: String) -> some View {
        Button(action: {
            selectedColor = color
        }) {
            Circle()
                .fill(Color(color))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 3)
                )
                .scaleEffect(selectedColor == color ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: selectedColor)
    }
    
    // MARK: - Icon Button
    private func iconButton(_ icon: String) -> some View {
        Button(action: {
            selectedIcon = icon
        }) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(selectedIcon == icon ? Color(selectedColor) : Color("TextSecondary"))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(selectedIcon == icon ? Color(selectedColor).opacity(0.2) : Color("Surface"))
                )
                .overlay(
                    Circle()
                        .stroke(selectedIcon == icon ? Color(selectedColor) : Color.clear, lineWidth: 2)
                )
                .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: selectedIcon)
    }
    
    // MARK: - Habit Preview
    private var habitPreview: some View {
        let previewHabit = Habit(
            name: name.isEmpty ? "Habit Name" : name,
            description: description.isEmpty ? nil : description,
            frequency: selectedFrequency,
            targetCount: targetCount,
            color: selectedColor,
            icon: selectedIcon
        )
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color("TextSecondary"))
            
            HabitRowView(
                habit: previewHabit,
                onToggleCompletion: {},
                onEdit: {},
                onDetail: {},
                onDelete: {}
            )
            .disabled(true)
        }
        .padding()
    }
    
    // MARK: - Actions
    private func saveHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else { return }
        
        viewModel.updateHabit(
            habit,
            name: trimmedName,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            frequency: selectedFrequency,
            targetCount: targetCount,
            color: selectedColor,
            icon: selectedIcon
        )
        
        dismiss()
    }
    
    private func toggleActive() {
        viewModel.toggleHabitActive(habit)
        dismiss()
    }
    
    private func deleteHabit() {
        viewModel.deleteHabit(habit)
        dismiss()
    }
}

#Preview {
    EditHabitFormView(
        habit: Habit(
            name: "Morning Exercise",
            description: "30 minutes of cardio",
            frequency: .daily,
            targetCount: 1,
            color: "blue",
            icon: "figure.run"
        ),
        viewModel: HabitListViewModel()
    )
}