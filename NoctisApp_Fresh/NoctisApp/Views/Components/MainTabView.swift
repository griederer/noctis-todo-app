//
//  MainTabView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1 // Start with Dashboard tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab (First tab)
            UserProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "chart.bar.fill" : "chart.bar")
                    Text("Dashboard")
                }
                .tag(1)
            
            // To Do Tab (renamed from Today)
            TasksView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "checkmark.circle.fill" : "checkmark.circle")
                    Text("To Do")
                }
                .tag(2)
            
            // Habits Tab
            HabitsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "repeat.circle.fill" : "repeat.circle")
                    Text("Habits")
                }
                .tag(3)
            
            // Journal Tab
            JournalView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "book.fill" : "book")
                    Text("Journal")
                }
                .tag(4)
        }
        .preferredColorScheme(.light)
        .accentColor(.blue)
        .onAppear {
            // Configure light theme tab bar appearance with rounded corners
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.selectionIndicatorTintColor = UIColor.systemBlue
            
            // Style the selected tab
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium)
            ]
            
            // Style the normal tabs
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 12, weight: .regular)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
}