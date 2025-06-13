//
//  JournalRepository.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine

protocol JournalRepositoryProtocol {
    func fetchEntries() async throws -> [JournalEntry]
    func addEntry(_ entry: JournalEntry) async throws
    func updateEntry(_ entry: JournalEntry) async throws
    func deleteEntry(id: String) async throws
    func toggleFavorite(id: String) async throws
    
    var entriesPublisher: AnyPublisher<[JournalEntry], Never> { get }
}

class JournalRepository: JournalRepositoryProtocol, ObservableObject {
    @Published private var entries: [JournalEntry] = []
    
    var entriesPublisher: AnyPublisher<[JournalEntry], Never> {
        $entries.eraseToAnyPublisher()
    }
    
    func fetchEntries() async throws -> [JournalEntry] {
        // For now, return mock data
        // TODO: Implement Firebase Firestore integration
        return entries
    }
    
    func addEntry(_ entry: JournalEntry) async throws {
        // TODO: Implement Firebase Firestore integration
        entries.append(entry)
    }
    
    func updateEntry(_ entry: JournalEntry) async throws {
        // TODO: Implement Firebase Firestore integration
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        }
    }
    
    func deleteEntry(id: String) async throws {
        // TODO: Implement Firebase Firestore integration
        entries.removeAll { $0.id == id }
    }
    
    func toggleFavorite(id: String) async throws {
        // TODO: Implement Firebase Firestore integration
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index].toggleFavorite()
        }
    }
}