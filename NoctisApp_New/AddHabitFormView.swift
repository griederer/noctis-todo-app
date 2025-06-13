import SwiftUI

struct AddHabitFormView: View {
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
                
                Section("Preview") {
                    habitPreview
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                
                Section {
                    Button(action: addHabit) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Habit")
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
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("Primary"))
                }
            }
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            AnalyticsService.shared.trackScreen("Add Habit Form")
        }
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
    private func addHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else { return }
        
        viewModel.addHabit(
            name: trimmedName,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            frequency: selectedFrequency,
            targetCount: targetCount,
            color: selectedColor,
            icon: selectedIcon
        )
        
        dismiss()
    }
}

#Preview {
    AddHabitFormView(viewModel: HabitListViewModel())
}