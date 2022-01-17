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
        List(viewModel.items, id: \.self, children: \.children, selection: $viewModel.currentItem) { item in
            HStack {
                Text(item.label)
                    .padding(.leading, 3)
                Spacer()
            }
        }
        .onChange(of: viewModel.currentItem, perform: handleUpdateSelection)
    }
    
    private func handleUpdateSelection(_ item: SidebarViewModel.ListItem?) {
        appState.currentView = item?.service
    }
}

// MARK: - View Model

class SidebarViewModel: ObservableObject {
    @Published var currentItem: ListItem?
    @Published var items: [ListItem] = [
        ListItem("S3", service: .s3),
        ListItem("SNS", service: .sns(component: nil), children: [
            ListItem("Subscriptions", service: .sns(component: .subscriptions)),
            ListItem("Topics", service: .sns(component: .topics))
        ]),
        ListItem("SQS", service: .sqs)
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
