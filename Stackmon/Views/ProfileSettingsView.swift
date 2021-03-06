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
            VStack(spacing: 0) {
                List(appState.profiles, id: \.self, selection: $viewModel.selection) { profile in
                    if viewModel.editing == profile {
                        TextField("", text: editingProfile.name) {
                            viewModel.editing = nil
                        }
                    } else {
                        Text(profile.name)
                            .onTapGesture(count: 2) {
                                viewModel.editing = profile
                            }
                            .onTapGesture {
                                viewModel.selection = profile
                            }
                    }
                }
                .padding(.bottom, 5)
                
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
                .padding(.leading, 10)
                .padding([.top, .bottom], 5)
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
    
    private var editingProfile: Binding<Profile> {
        Binding<Profile>(
            get: { return viewModel.editing ?? Profile(name: "" ) },
            set: { viewModel.editing = $0 }
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
        VStack {
            Section(header: Text("General")) {
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
            .padding(.bottom, 10)
            
            Section(header: Text("Authentication")) {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 80)),
                    GridItem(.flexible(minimum: 150)),
                ], alignment: .center) {
                    Text("Method")
                    Picker("", selection: $profile.authenticationType) {
                        ForEach(Profile.AuthenticationType.allCases, id: \.self) { authenticationType in
                            Text(authenticationType.label)
                                .id(authenticationType)
                        }
                    }
                    
                    switch profile.authenticationType {
                    case .iam:
                        Group {
                            Text("Access Key ID")
                            SecureField("", text: $profile.accessKeyId)
                            
                            Text("Secret Access Key")
                            SecureField("", text: $profile.secretAccessKey)
                            
                            Text("Session Token")
                            SecureField("", text: $profile.sessionToken)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Extensions

extension Profile.AuthenticationType {
    var label: String {
        switch self {
        case .iam:
            return "IAM Credentials"
        }
    }
}

// MARK: - View Model

class ProfileSettingsViewModel: ObservableObject {
    @Published var selection: Profile?
    @Published var editing: Profile?
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
