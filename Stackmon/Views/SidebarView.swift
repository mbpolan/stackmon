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
    @StateObject private var viewModel: SidebarViewModel = SidebarViewModel()
    
    var body: some View {
        VStack {
            Picker("", selection: $appState.profile) {
                if appState.profiles.isEmpty {
                    Text("No profiles available")
                        .tag(nil as Profile?)
                }
                
                ForEach(appState.profiles, id: \.self) { profile in
                    Text(profile.name)
                        .tag(profile as Profile?)
                }
            }
            .padding(.trailing, 5)
            
            Divider()
            
            if appState.hasNoCurrentProfile {
                Spacer()
            } else {
                List(viewModel.items, id: \.self, children: \.children, selection: $viewModel.currentItem) { item in
                    HStack {
                        Text(item.label)
                            .padding(.leading, 3)
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: viewModel.currentItem, perform: handleUpdateSelection)
    }
    
    private func handleUpdateSelection(_ item: SidebarViewModel.ListItem?) {
        appState.currentView = item?.service
    }
}

// MARK: - View Model

fileprivate class SidebarViewModel: ObservableObject {
    @Published var currentItem: ListItem?
    @Published var items: [ListItem] = [
        ListItem("S3", service: .s3),
        ListItem("SNS", service: .sns(component: nil), children: [
            ListItem("Subscriptions", service: .sns(component: .subscriptions)),
            ListItem("Topics", service: .sns(component: .topics))
        ]),
        ListItem("SQS", service: .sqs),
        ListItem("VPC", service: .vpc(component: nil), children: [
            ListItem("IPAM", service: .vpc(component: .ipams)),
            ListItem("Subnets", service: .vpc(component: .subnets))
        ])
    ]
    
    struct ListItem: Hashable {
        let label: String
        let service: AWSService
        let children: [ListItem]?
        
        init(_ label: String, service: AWSService, children: [ListItem]? = nil) {
            self.label = label
            self.service = service
            self.children = children
        }
    }
}

// MARK: - Previews

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
