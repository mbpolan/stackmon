//
//  SidebarView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SwiftUI

// MARK: - View

struct SidebarView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        List(StackService.allCases, selection: $appState.serviceView) { service in
            HStack {
                Text(textForService(service))
                Spacer()
            }
            .onTapGesture {
                handleSelectService(service)
            }
        }
    }
    
    private func handleSelectService(_ service: StackService) {
        appState.serviceView = service
    }
    
    private func textForService(_ service: StackService) -> String {
        switch service {
        case .s3:
            return "S3"
        case .sqs:
            return "SQS"
        }
    }
}

// MARK: - Previews

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
