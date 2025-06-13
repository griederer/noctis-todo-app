//
//  User.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var email: String?
    var displayName: String?
    var photoURL: URL?
    var isAnonymous: Bool
    var createdAt: Date
    var lastSignInAt: Date
    var preferences: UserPreferences
    
    init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil,
        isAnonymous: Bool = false,
        createdAt: Date = Date(),
        lastSignInAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isAnonymous = isAnonymous
        self.createdAt = createdAt
        self.lastSignInAt = lastSignInAt
        self.preferences = UserPreferences()
    }
}

struct UserPreferences: Codable {
    var theme: AppTheme
    var notifications: NotificationSettings
    var privacy: PrivacySettings
    
    init() {
        self.theme = .dark
        self.notifications = NotificationSettings()
        self.privacy = PrivacySettings()
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
}

struct NotificationSettings: Codable {
    var todoReminders: Bool
    var habitReminders: Bool
    var journalReminders: Bool
    var dailyReviewTime: Date?
    
    init() {
        self.todoReminders = true
        self.habitReminders = true
        self.journalReminders = false
        self.dailyReviewTime = Calendar.current.date(
            bySettingHour: 21,
            minute: 0,
            second: 0,
            of: Date()
        )
    }
}

struct PrivacySettings: Codable {
    var shareUsageData: Bool
    var shareAnalytics: Bool
    var backupEnabled: Bool
    
    init() {
        self.shareUsageData = false
        self.shareAnalytics = false
        self.backupEnabled = true
    }
}