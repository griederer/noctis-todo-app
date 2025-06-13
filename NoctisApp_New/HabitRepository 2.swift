//
//  HabitRepository.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine

protocol HabitRepositoryProtocol {
    func fetchHabits() async throws -> [Habit]
    func addHabit(_ habit: Habit) async throws
    func updateHabit(_ habit: Habit) async throws
    func deleteHabit(id: String) async throws
    func toggleHabitEntry(habitId: String, date: Date) async throws
    
    var habitsPublisher: AnyPublisher<[Habit], Never> { get }
}

class HabitRepository: HabitRepositoryProtocol, ObservableObject {
    @Published private var habits: [Habit] = []
    
    var habitsPublisher: AnyPublisher<[Habit], Never> {
        $habits.eraseToAnyPublisher()
    }
    
    func fetchHabits() async throws -> [Habit] {
        // For now, return mock data
        // TODO: Implement Firebase Firestore integration
        return habits
    }
    
    func addHabit(_ habit: Habit) async throws {
        // TODO: Implement Firebase Firestore integration
        habits.append(habit)
    }
    
    func updateHabit(_ habit: Habit) async throws {
        // TODO: Implement Firebase Firestore integration
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        }
    }
    
    func deleteHabit(id: String) async throws {
        // TODO: Implement Firebase Firestore integration
        habits.removeAll { $0.id == id }
    }
    
    func toggleHabitEntry(habitId: String, date: Date) async throws {
        // TODO: Implement Firebase Firestore integration
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].toggleEntry(for: date)
        }
    }
}