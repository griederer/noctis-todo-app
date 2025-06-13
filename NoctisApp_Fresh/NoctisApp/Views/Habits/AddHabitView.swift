//
//  AddHabitView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-12.
//

import SwiftUI

struct AddHabitView: View {
    let onSave: (String, String?, HabitFrequency, Int, String, String) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedFrequency: HabitFrequency = .daily
    @State private var targetCount = 1
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "circle.fill"
    @Environment(\.dismiss) private var dismiss
    
    private let colors = ["blue", "green", "orange", "purple", "red", "yellow"]
    private let icons = ["circle.fill", "drop.fill", "figure.walk", "book.fill", "brain.head.profile", "heart.fill", "star.fill", "leaf.fill"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter habit name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter description (optional)", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Frequency Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frequency")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Picker("Frequency", selection: $selectedFrequency) {
                            ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.displayName).tag(frequency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Target Count Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Count")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Stepper(value: $targetCount, in: 1...20) {
                            Text("\(targetCount) time\(targetCount > 1 ? "s" : "") per \(selectedFrequency.rawValue)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Color Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { colorName in
                                Button(action: { selectedColor = colorName }) {
                                    Circle()
                                        .fill(colorForName(colorName))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == colorName ? Color.primary : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Icon Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(icons, id: \.self) { iconName in
                                Button(action: { selectedIcon = iconName }) {
                                    Circle()
                                        .fill(colorForName(selectedColor).opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: iconName)
                                                .font(.system(size: 20))
                                                .foregroundColor(colorForName(selectedColor))
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(selectedIcon == iconName ? colorForName(selectedColor) : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemBackground).ignoresSafeArea(.all))
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(name, description.isEmpty ? nil : description, selectedFrequency, targetCount, selectedColor, selectedIcon)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

#Preview {
    AddHabitView { name, description, frequency, targetCount, color, icon in
        print("New habit: \(name)")
    }
}