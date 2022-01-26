//
//  ContentView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SotoS3
import SwiftUI

// MARK: - View

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            SidebarView()
                .disabled(appState.hasNoProfiles)
            
            if appState.hasNoProfiles {
                Text("No connection profiles have been created. To get started, create one in the settings panel.")
                    .foregroundColor(Color.secondary)
                    .centered(.all)
            } else if appState.hasNoCurrentProfile {
                Text("Choose a connection profile from the sidebar to view services.")
                    .foregroundColor(Color.secondary)
                    .centered(.all)
            } else {
                ServiceView(currentView: appState.currentView)
            }
        }
        .frame(minWidth: 640, minHeight: 480)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: handleSidebar) {
                    Image(systemName: "sidebar.leading")
                }
            }
        }
    }
    
    private func handleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil)
    }
}

// MARK: - Service View

fileprivate struct ServiceView: View {
    let currentView: AWSService?
    
    var body: some View {
        Group {
            switch currentView {
            case .some(let view):
                switch view {
                case .s3:
                    S3ServiceView(view: view)
                case .sns(_):
                    SNSServiceView(view: view)
                case .sqs:
                    SQSServiceView(view: view)
                case .vpc:
                    VPCServiceView(view: view)
                }
            default:
                Text("Select a service to view")
                    .foregroundColor(Color.secondary)
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
