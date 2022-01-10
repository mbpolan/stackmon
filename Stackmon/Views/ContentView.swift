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
            
            Group {
                if appState.serviceView == .s3 {
                    S3ServiceView()
                } else if appState.serviceView == .sns {
                    SNSServiceView()
                } else if appState.serviceView == .sqs {
                    SQSServiceView()
                } else {
                    Text("Select a service to view")
                        .foregroundColor(Color.secondary)
                }
            }
        }
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

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
