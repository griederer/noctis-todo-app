//
//  AppConstants.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import SwiftUI

struct AppConstants {
    
    // MARK: - App Info
    static let appName = "Noctis"
    static let appVersion = "2.0.0"
    static let buildNumber = "1"
    
    // MARK: - API
    struct API {
        static let timeout: TimeInterval = 30.0
        static let retryAttempts = 3
    }
    
    // MARK: - Storage
    struct Storage {
        static let userDefaultsPrefix = "com.noctis.app"
        static let keychainService = "com.noctis.app.keychain"
    }
    
    // MARK: - Animations
    struct Animations {
        static let defaultDuration: Double = 0.3
        static let fastDuration: Double = 0.15
        static let slowDuration: Double = 0.5
        static let springDamping: Double = 0.8
        static let springResponse: Double = 0.4
    }
    
    // MARK: - Layout
    struct Layout {
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Double = 0.1
    }
    
    // MARK: - Typography
    struct Typography {
        static let titleSize: CGFloat = 28
        static let headlineSize: CGFloat = 22
        static let bodySize: CGFloat = 16
        static let captionSize: CGFloat = 12
    }
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color("Primary")
        static let secondary = Color("Secondary")
        static let accent = Color("Accent")
        
        // Background Colors
        static let background = Color("Background")
        static let surface = Color("Surface")
        static let surfaceSecondary = Color("SurfaceSecondary")
        
        // Text Colors
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let textTertiary = Color("TextTertiary")
        
        // System Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
    }
    
    // MARK: - Icons
    struct Icons {
        // Tab Bar Icons
        static let tasks = "checklist"
        static let habits = "repeat"
        static let journal = "book"
        static let settings = "gearshape"
        
        // Common Icons
        static let add = "plus"
        static let edit = "pencil"
        static let delete = "trash"
        static let complete = "checkmark"
        static let star = "star"
        static let starFilled = "star.fill"
        static let calendar = "calendar"
        static let clock = "clock"
        
        // Priority Icons
        static let lowPriority = "circle.fill"
        static let mediumPriority = "circle.fill"
        static let highPriority = "exclamationmark.circle.fill"
        
        // Mood Icons
        static let moodVeryBad = "face.dashed"
        static let moodBad = "face.dashed.fill"
        static let moodNeutral = "face.smiling"
        static let moodGood = "face.smiling.fill"
        static let moodVeryGood = "face.smiling.inverse"
        
        // Authentication Icons
        static let email = "envelope"
        static let password = "lock"
        static let user = "person"
        static let google = "globe"
        static let signOut = "rectangle.portrait.and.arrow.right"
    }
    
    // MARK: - Limits
    struct Limits {
        static let maxTitleLength = 100
        static let maxDescriptionLength = 500
        static let maxJournalContentLength = 5000
        static let maxHabitNameLength = 50
        static let maxTagLength = 20
        static let maxTagCount = 10
    }
    
    // MARK: - URLs
    struct URLs {
        static let privacyPolicy = "https://noctis.app/privacy"
        static let termsOfService = "https://noctis.app/terms"
        static let support = "https://noctis.app/support"
        static let website = "https://noctis.app"
    }
}