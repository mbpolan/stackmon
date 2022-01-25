//
//  SettingsView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/24/22.
//

import SwiftUI

// MARK: - View

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.tab) {
            ProfileSettingsView()
                .tabItem {
                    Label("Profiles", systemImage: "person")
                }
                .tag(SettingsViewModel.Tab.profiles)
        }
        .frame(width: 600, height: 400)
    }
}

// MARK: - View Model

class SettingsViewModel: ObservableObject {
    @Published var tab: Tab = .profiles
    
    enum Tab {
        case profiles
    }
}

// MARK: - Preview

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
