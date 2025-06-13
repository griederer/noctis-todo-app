//
//  JournalEntry.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import SwiftUI

enum Mood: String, CaseIterable, Codable {
    case veryBad = "very_bad"
    case bad = "bad"
    case neutral = "neutral"
    case good = "good"
    case veryGood = "very_good"
    case happy = "happy"
    case stressed = "stressed"
    case excited = "excited"
    case calm = "calm"
    case grateful = "grateful"
    
    var emoji: String {
        switch self {
        case .veryBad:
            return "😢"
        case .bad:
            return "😔"
        case .neutral:
            return "😐"
        case .good:
            return "😊"
        case .veryGood:
            return "😁"
        case .happy:
            return "😄"
        case .stressed:
            return "😰"
        case .excited:
            return "🤩"
        case .calm:
            return "😌"
        case .grateful:
            return "🙏"
        }
    }
    
    var color: Color {
        switch self {
        case .veryBad:
            return .red
        case .bad:
            return .orange
        case .neutral:
            return .gray
        case .good:
            return .green
        case .veryGood:
            return .blue
        case .happy:
            return .yellow
        case .stressed:
            return .red
        case .excited:
            return .purple
        case .calm:
            return .mint
        case .grateful:
            return .pink
        }
    }
    
    var icon: String {
        switch self {
        case .veryBad:
            return "face.frowning"
        case .bad:
            return "face.dashed"
        case .neutral:
            return "face.neutral"
        case .good:
            return "face.smiling"
        case .veryGood:
            return "face.laughing"
        case .happy:
            return "heart.fill"
        case .stressed:
            return "bolt.fill"
        case .excited:
            return "star.fill"
        case .calm:
            return "leaf.fill"
        case .grateful:
            return "hands.sparkles.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .veryBad:
            return "Very Bad"
        case .bad:
            return "Bad"
        case .neutral:
            return "Neutral"
        case .good:
            return "Good"
        case .veryGood:
            return "Very Good"
        case .happy:
            return "Happy"
        case .stressed:
            return "Stressed"
        case .excited:
            return "Excited"
        case .calm:
            return "Calm"
        case .grateful:
            return "Grateful"
        }
    }
}

struct JournalEntry: Identifiable, Codable {
    let id: String
    var title: String
    var content: String
    var mood: Mood?
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        mood: Mood? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.mood = mood
        self.tags = tags
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = false
    }
    
    mutating func update(title: String? = nil, content: String? = nil, mood: Mood? = nil, tags: [String]? = nil) {
        if let title = title { self.title = title }
        if let content = content { self.content = content }
        if let mood = mood { self.mood = mood }
        if let tags = tags { self.tags = tags }
        self.updatedAt = Date()
    }
    
    mutating func toggleFavorite() {
        isFavorite.toggle()
        updatedAt = Date()
    }
}