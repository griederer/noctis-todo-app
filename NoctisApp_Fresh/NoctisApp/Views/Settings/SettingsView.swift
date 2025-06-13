//
//  SettingsView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppConstants.Colors.textTertiary)
                
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.textSecondary)
                
                Text("Coming soon - Customize your app experience")
                    .font(.body)
                    .foregroundColor(AppConstants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}