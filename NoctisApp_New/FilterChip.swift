//
//  FilterChip.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.2) : AppConstants.Colors.accent.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? AppConstants.Colors.accent : AppConstants.Colors.surface)
            )
            .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        FilterChip(title: "All", count: 5, isSelected: true) {}
        FilterChip(title: "Pending", count: 3, isSelected: false) {}
        FilterChip(title: "Completed", count: 0, isSelected: false) {}
    }
    .padding()
    .background(Color.black)
}