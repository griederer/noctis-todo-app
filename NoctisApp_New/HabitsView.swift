//
//  HabitsView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel = HabitListViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Today's Statistics Header
                if viewModel.activeHabits > 0 {
                    todayStatisticsHeader
                }
                
                // Filter Picker
                filterPicker
                
                // Habits List
                habitsList
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { viewModel.setFilter(.active) }) {
                            Label("Active Habits", systemImage: "checkmark.circle")
                        }
                        
                        Button(action: { viewModel.setFilter(.all) }) {
                            Label("All Habits", systemImage: "list.bullet")
                        }
                        
                        Divider()
                        
                        Button(action: { viewModel.setFilter(.completed) }) {
                            Label("Completed Today", systemImage: "checkmark.circle.fill")
                        }
                        
                        Button(action: { viewModel.setFilter(.pending) }) {
                            Label("Pending Today", systemImage: "circle")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(Color("Primary"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.showAddHabit) {
                        Image(systemName: "plus")
                            .foregroundColor(Color("Primary"))
                    }
                }
            }
            .background(Color("Background"))
            .sheet(isPresented: $viewModel.showingAddHabit) {
                AddHabitFormView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingEditHabit) {
                if let habit = viewModel.selectedHabit {
                    EditHabitFormView(habit: habit, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showingHabitDetail) {
                if let habit = viewModel.selectedHabit {
                    HabitDetailView(habit: habit, viewModel: viewModel)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            AnalyticsService.shared.trackScreen("Habits List")
        }
    }
    
    // MARK: - Today's Statistics Header
    private var todayStatisticsHeader: some View {
        let stats = viewModel.getTodayOverallStatistics()
        
        return VStack(spacing: 12) {
            HStack {
                StatCard(title: "Active", value: "\(stats.totalActive)", color: Color("Primary"))
                StatCard(title: "Completed", value: "\(stats.completed)", color: .green)
                StatCard(title: "Pending", value: "\(stats.pending)", color: .orange)
                StatCard(title: "Progress", value: "\(stats.completionPercentage)%", color: Color("Primary"))
            }
            
            // Progress Bar
            VStack(spacing: 4) {
                HStack {
                    Text("Today's Progress")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                    
                    Text("\(stats.completed)/\(stats.totalActive)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                ProgressView(value: stats.completionRate)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("Primary")))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color("Surface"))
    }
    
    // MARK: - Filter Picker
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HabitFilter.allCases, id: \.self) { filter in
                    HabitFilterChip(
                        filter: filter,
                        selectedFilter: viewModel.selectedFilter,
                        count: getFilterCount(filter)
                    ) {
                        viewModel.setFilter(filter)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Habits List
    private var habitsList: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Primary")))
                    
                    Text("Loading habits...")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background"))
            } else if !viewModel.hasActiveHabits {
                EmptyStateView(
                    icon: "repeat",
                    title: "No Habits",
                    subtitle: viewModel.emptyStateMessage
                )
            } else {
                List {
                    ForEach(viewModel.filteredHabits) { habit in
                        HabitRowView(habit: habit) {
                            viewModel.toggleHabitEntry(habit)
                        } onEdit: {
                            viewModel.showEditHabit(habit)
                        } onDetail: {
                            viewModel.showHabitDetail(habit)
                        } onDelete: {
                            viewModel.deleteHabit(habit)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color("Background"))
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getFilterCount(_ filter: HabitFilter) -> Int {
        switch filter {
        case .active:
            return viewModel.activeHabits
        case .all:
            return viewModel.totalHabits
        case .completed:
            return viewModel.completedTodayCount
        case .pending:
            return viewModel.pendingTodayCount
        }
    }
}

#Preview {
    HabitsView()
}