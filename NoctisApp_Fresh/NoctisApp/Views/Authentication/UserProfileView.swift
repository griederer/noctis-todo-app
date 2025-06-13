import SwiftUI

struct UserProfileView: View {
    @StateObject private var dataStore = SharedDataStore.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack(spacing: 0) {
                        Text("T")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("hr")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                        Text("3")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                        Text("e ")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                        Text("T")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("hings")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                    }
                    .padding(.top)
                    
                    // Current Date
                    Text(Date().formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Daily Goals Summary
                    Text("Today's Goals")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    // Daily Goals Cards
                    VStack(spacing: 12) {
                        // Daily Task Goal
                        HStack(spacing: 16) {
                            Image(systemName: dataStore.allDailyTasksCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(dataStore.allDailyTasksCompleted ? .green : .blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Tasks")
                                    .font(.headline)
                                Text(dataStore.allDailyTasksCompleted ? "All Completed" : "\(dataStore.pendingTodosCount) Pending")
                                    .font(.caption)
                                    .foregroundColor(dataStore.allDailyTasksCompleted ? .green : .secondary)
                            }
                            
                            Spacer()
                            
                            if dataStore.allDailyTasksCompleted {
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.green)
                            } else {
                                Text(dataStore.dailyTasksStatus)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Daily Journal Goal
                        HStack(spacing: 16) {
                            Image(systemName: dataStore.hasDailyJournalCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(dataStore.hasDailyJournalCompleted ? .green : .purple)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Journal")
                                    .font(.headline)
                                Text(dataStore.hasDailyJournalCompleted ? "Completed" : "Pending")
                                    .font(.caption)
                                    .foregroundColor(dataStore.hasDailyJournalCompleted ? .green : .secondary)
                            }
                            
                            Spacer()
                            
                            if !dataStore.hasDailyJournalCompleted {
                                Text("1")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Daily Habits Goal
                        HStack(spacing: 16) {
                            Image(systemName: dataStore.allDailyHabitsCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(dataStore.allDailyHabitsCompleted ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Habits")
                                    .font(.headline)
                                Text(dataStore.allDailyHabitsCompleted ? "All Completed" : "\(dataStore.pendingHabitsToday) Pending")
                                    .font(.caption)
                                    .foregroundColor(dataStore.allDailyHabitsCompleted ? .green : .secondary)
                            }
                            
                            Spacer()
                            
                            if dataStore.allDailyHabitsCompleted {
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.green)
                            } else {
                                Text(dataStore.dailyHabitsStatus)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    UserProfileView()
}