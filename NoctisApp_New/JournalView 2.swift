//
//  JournalView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct JournalView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "book")
                    .font(.system(size: 64))
                    .foregroundColor(AppConstants.Colors.textTertiary)
                
                Text("Journal")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.textSecondary)
                
                Text("Coming soon - Write and reflect on your thoughts")
                    .font(.body)
                    .foregroundColor(AppConstants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

    // MARK: - Statistics Header
    private var statisticsHeader: some View {
        let stats = viewModel.statistics
        
        return VStack(spacing: 12) {
            HStack {
                StatCard(title: "Entries", value: "\(stats.totalEntries)", color: Color("Primary"))
                StatCard(title: "This Week", value: "\(stats.thisWeekEntries)", color: .blue)
                StatCard(title: "Streak", value: "\(stats.currentStreak)", color: .orange)
                StatCard(title: "Avg Words", value: "\(stats.averageWordsPerEntry)", color: .green)
            }
            
            if let mood = stats.mostCommonMood {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                    
                    Text("Most common mood: \(mood.displayName)")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color("Surface"))
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(spacing: 8) {
            if !viewModel.hasEntryForToday() {
                Button(action: {
                    viewModel.showAddEntry()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("Primary"))
                        
                        Text("Write today's entry")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Primary").opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Primary").opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("You've written today's entry!")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Search and Filters
    private var searchAndFiltersSection: some View {
        VStack(spacing: 8) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("TextSecondary"))
                
                TextField("Search entries...", text: $viewModel.searchText)
                    .foregroundColor(Color("TextPrimary"))
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("Surface"))
            )
            .padding(.horizontal)
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Date filter chip
                    FilterChip(
                        title: viewModel.selectedDateFilter.displayName,
                        isSelected: viewModel.selectedDateFilter != .all,
                        icon: "calendar"
                    ) {
                        // Toggle date filter
                    }
                    
                    // Mood filter chips
                    if let selectedMood = viewModel.selectedMoodFilter {
                        FilterChip(
                            title: selectedMood.displayName,
                            isSelected: true,
                            icon: selectedMood.icon
                        ) {
                            viewModel.setMoodFilter(nil)
                        }
                    }
                    
                    // Clear filters if any are active
                    if viewModel.selectedDateFilter != .all || viewModel.selectedMoodFilter != nil || !viewModel.searchText.isEmpty {
                        Button("Clear") {
                            viewModel.clearFilters()
                        }
                        .font(.caption)
                        .foregroundColor(Color("Primary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .stroke(Color("Primary"), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Entries List
    private var entriesList: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Primary")))
                    
                    Text("Loading entries...")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background"))
            } else if !viewModel.hasEntries {
                EmptyStateView(
                    icon: "book.closed",
                    title: "No Journal Entries",
                    subtitle: viewModel.emptyStateMessage
                )
            } else {
                List {
                    ForEach(viewModel.filteredEntries) { entry in
                        JournalEntryRowView(entry: entry) {
                            viewModel.showEntryDetail(entry)
                        } onEdit: {
                            viewModel.showEditEntry(entry)
                        } onDelete: {
                            viewModel.deleteEntry(entry)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color("Background"))
            }
        }
    }
}

// MARK: - Supporting Views
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String?
    let onTap: () -> Void
    
    init(title: String, isSelected: Bool, icon: String? = nil, onTap: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.icon = icon
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white : Color("TextSecondary"))
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : Color("TextPrimary"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color("Primary") : Color("Surface"))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    JournalView()
}