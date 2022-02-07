//
//  StackmonApp.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SwiftUI

@main
struct StackmonApp: App {
    @StateObject private var appState: AppState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear(perform: handleAppear)
                .onChange(of: appState.region, perform: { _ in handleSaveAppState() })
                .onChange(of: appState.profile, perform: { _ in handleSaveAppState() })
        }
        .windowToolbarStyle(.unifiedCompact)
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
    
    private func handleAppear() {
        print("Loading app state")
        appState.load()
    }
    
    private func handleSaveAppState() {
        print("Persisting app state")
        appState.save()
    }
}
