//
//  ProfileSettingsView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/24/22.
//

import SwiftUI

// MARK: - View

struct ProfileSettingsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: ProfileSettingsViewModel = ProfileSettingsViewModel()
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack {
                List(appState.profiles, id: \.self, selection: $viewModel.selection) { profile in
                    Text(profile.name)
                }
                
                Divider()
                
                HStack {
                    Button(action: handleAdd) {
                        Image(systemName: "plus")
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: handleRemove) {
                        Image(systemName: "minus")
                            .frame(width: 16, height: 16)
                    }
                    .disabled(viewModel.selection == nil)
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Spacer()
                }
                .padding(.leading, 5)
                .padding(.bottom, 3)
            }
            .frame(width: 150)
            
            Divider()
            
            Group {
                if let _ = viewModel.selection {
                    ProfileEditorView(profile: selectedProfile)
                        .padding()
                } else {
                    Text("Select or create a profile")
                        .foregroundColor(.secondary)
                        .centered(.all)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var selectedProfile: Binding<Profile> {
        Binding<Profile>(
            get: { return viewModel.selection ?? Profile(name: "" ) },
            set: { viewModel.selection = $0 }
        )
    }
    
    private func handleAdd() {
        appState.profiles.append(Profile(name: generateProfileName()))
    }
    
    private func handleRemove() {
        guard let selection = viewModel.selection,
              let index = appState.profiles.firstIndex(of: selection) else { return }
        
        viewModel.selection = nil
        appState.profiles.remove(at: index)
    }
    
    private func generateProfileName(_ count: Int = 1) -> String {
        let name = "New Profile \(count)"
        
        guard !appState.profiles.contains(where: { $0.name == name }) else {
            return generateProfileName(count + 1)
        }
        
        return name
    }
}

// MARK: - Editor View

fileprivate struct ProfileEditorView: View {
    @Binding var profile: Profile
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(minimum: 80)),
            GridItem(.flexible(minimum: 150)),
        ], alignment: .center) {
            Text("Default Region")
            AWSRegionPicker(region: $profile.region)
            
            Text("Service URL")
            TextField("", text: $profile.endpoint)
        }
    }
}

// MARK: - View Model

class ProfileSettingsViewModel: ObservableObject {
    @Published var selection: Profile?
}

// MARK: - Preview

struct ProfileSettingsView_Preview: PreviewProvider {
    static var appState: AppState {
        let appState = AppState()
        appState.profiles = [
            Profile(name: "Test")
        ]
        
        return appState
    }
    
    static var previews: some View {
        ProfileSettingsView()
            .frame(width: 400, height: 300)
            .environmentObject(appState)
    }
}
