//
//  StackmonApp.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SwiftUI

@main
struct StackmonApp: App {
    private let appState: AppState
    
    init() {
        self.appState = AppState()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowToolbarStyle(.unifiedCompact)
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
