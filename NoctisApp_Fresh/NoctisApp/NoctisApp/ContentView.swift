//
//  ContentView.swift
//  NoctisApp
//
//  Created by Gonzalo Riederer on 12-06-25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Dashboard Tab - UserProfileView
            UserProfileView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }
                .tag(1)
            
            // To Do Tab - Real TasksView
            TasksView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("To Do")
                }
                .tag(2)
            
            // Habits Tab - Real HabitsView
            HabitsView()
                .tabItem {
                    Image(systemName: "repeat.circle")
                    Text("Habits")
                }
                .tag(3)
            
            // Journal Tab - Real JournalView
            JournalView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Journal")
                }
                .tag(4)
        }
        .preferredColorScheme(.light)
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
