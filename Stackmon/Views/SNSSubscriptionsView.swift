//
//  SNSSubscriptionsView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSNS
import SwiftUI

// MARK: - View

struct SNSSubscriptionsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: SNSSubscriptionsViewModel = SNSSubscriptionsViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .noRegion:
                NoRegionPlaceholderView()
            case .list:
                SNSSubscriptionListView(region: $appState.region,
                                        subscriptions: $viewModel.subscriptions,
                                        state: tableState,
                                        onAdd: handleAddSubscription,
                                        onDelete: handleDeleteSubscription)
            }
        }
        .navigationSubtitle("Subscriptions")
        .sheet(isPresented: $viewModel.sheetShown, onDismiss: handleCloseSheet) {
            switch viewModel.sheet {
            case .error(let error):
                Text("An error occured: \(error.localizedDescription)")
            default:
                Text("An unknown error has occured")
            }
        }
        .onAppear(perform: handleLoad)
        .onRefresh(perform: handleLoad)
        .onChange(of: appState.region, perform: { _ in handleLoad() })
    }
    
    private var service: SNSService? {
        guard let region = appState.region else { return nil }
        return SNSService(client: appState.client, region: region, profile: appState.profile)
    }
    
    private var tableState: TableState {
        if viewModel.loading {
            return .loading
        } else if viewModel.subscriptions.isEmpty {
            return .noData
        } else {
            return .ready
        }
    }
    
    private func handleLoad() {
        guard let service = service else {
            viewModel.mode = .noRegion
            return
        }
        
        viewModel.loading = true
        
        service.listSubscriptions(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let subscriptions):
                    viewModel.subscriptions = subscriptions
                case .failure(let error):
                    print(error)
                    viewModel.sheet = .error(error)
                }
                
                viewModel.loading = false
            }
        })
    }
    
    private func handleAddSubscription() {
        // TODO
    }
    
    private func handleDeleteSubscription(_ subscription: SNSSubscription) {
        // TODO
    }
    
    private func handleCloseSubView() {
        viewModel.mode = .list
    }
    
    private func handleCloseSheet() {
        viewModel.sheet = .none
    }
    
    private func afterOperation<T>(_ result: Result<T, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(_):
                viewModel.mode = .list
                handleLoad()
            case .failure(let error):
                viewModel.sheet = .error(error)
            }
        }
    }
}

// MARK: - View Model

fileprivate class SNSSubscriptionsViewModel: ObservableObject {
    @Published var mode: ViewMode = .list
    @Published var subscriptions: [SNSSubscription] = []
    @Published var loading: Bool = true
    @Published var sheet: Sheet = .none {
        didSet {
            switch sheet {
            case .none:
                sheetShown = false
            default:
                sheetShown = true
            }
        }
    }
    @Published var sheetShown: Bool = false
    
    enum ViewMode {
        case noRegion
        case list
    }
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}

// MARK: - Preview

struct SNSSubscriptionsView_Preview: PreviewProvider {
    static var previews: some View {
        SNSSubscriptionsView()
    }
}
