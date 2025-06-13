//
//  NoctisAppApp.swift
//  NoctisApp
//
//  Created by Gonzalo Riederer on 12-06-25.
//

import SwiftUI
import FirebaseCore

@main
struct NoctisAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
