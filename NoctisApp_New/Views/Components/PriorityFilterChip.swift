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
        priority?.color ?? Color("Primary")
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(displayText)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? chipColor : Color("Surface"))
                )
                .foregroundColor(
                    isSelected ? .white : Color("TextPrimary")
                )
                .overlay(
                    Capsule()
                        .stroke(chipColor.opacity(0.3), lineWidth: 1)
                )
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