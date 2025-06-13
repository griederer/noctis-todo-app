//
//  PriorityFilterChip.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct PriorityFilterChip: View {
    let priority: Priority?
    let selectedPriority: Priority?
    let onTap: () -> Void
    
    private var isSelected: Bool {
        priority == selectedPriority
    }
    
    private var displayText: String {
        priority?.displayName ?? "All"
    }
    
    private var chipColor: Color {
        priority?.color ?? .gray
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(displayText)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? chipColor.opacity(0.2) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? chipColor : Color.clear, lineWidth: 1)
                        )
                )
                .foregroundColor(isSelected ? chipColor : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        PriorityFilterChip(priority: nil, selectedPriority: nil) { }
        PriorityFilterChip(priority: .high, selectedPriority: .high) { }
        PriorityFilterChip(priority: .medium, selectedPriority: .high) { }
    }
}