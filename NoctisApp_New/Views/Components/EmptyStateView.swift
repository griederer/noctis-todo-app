//
//  EmptyStateView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.padding) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(AppConstants.Colors.textTertiary)
            
            VStack(spacing: AppConstants.Layout.smallPadding) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.textSecondary)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(AppConstants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppConstants.Layout.padding)
    }
}

#Preview {
    EmptyStateView(
        icon: "checklist",
        title: "No tasks",
        subtitle: "Add your first task to get started"
    )
    .background(Color.black)
}