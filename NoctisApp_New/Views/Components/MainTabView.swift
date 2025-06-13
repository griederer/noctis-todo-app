//
//  MainTabView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Tasks Tab
            TasksView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Tasks")
                }
                .tag(1)
            
            // Habits Tab
            HabitsView()
                .tabItem {
                    Image(systemName: "repeat")
                    Text("Habits")
                }
                .tag(2)
            
            // Journal Tab
            JournalView()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Journal")
                }
                .tag(3)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .preferredColorScheme(.dark)
        .tint(Color("Primary"))
        .onAppear {
            AnalyticsService.shared.trackScreen("Main Tab View")
        }
        .onChange(of: selectedTab) { _, newTab in
            let tabNames = ["Dashboard", "Tasks", "Habits", "Journal", "Settings"]
            AnalyticsService.shared.trackCustomEvent(name: "tab_switched", parameters: [
                "tab_index": newTab,
                "tab_name": tabNames[safe: newTab] ?? "Unknown"
            ])
        }
    }
}

#Preview {
    MainTabView()
}