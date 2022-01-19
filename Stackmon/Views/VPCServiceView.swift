//
//  VPCServiceView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/18/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCServiceView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: VPCServiceViewModel = VPCServiceViewModel()
    let view: AWSService
    
    var body: some View {
        Group {
            switch viewModel.mode {
            case .noRegion:
                NoRegionPlaceholderView()
            case .list:
                switch view {
                case .vpc(let component):
                    switch component {
                    default:
                        VPCListView(region: $appState.region,
                                    vpcs: $viewModel.vpcs,
                                    state: tableState,
                                    onAdd: handleShowAddVPC,
                                    onDelete: handleDeleteVPC)
                    }
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle("Virtual Private Cloud (VPC)")
        .sheet(isPresented: $viewModel.sheetShown, onDismiss: handleCloseSheet) {
            switch viewModel.sheet {
            case .error(let error):
                ErrorSheetView(error: error, onDismiss: handleCloseSheet)
            default:
                Text("An unknown error has occured")
            }
        }
        .onAppear(perform: handleLoad)
        .onRefresh(perform: handleLoad)
        .onChange(of: appState.region, perform: { _ in handleLoad() })
    }
    
    private var service: VPCService? {
        guard let region = appState.region else { return nil }
        return VPCService(client: appState.client, region: region, profile: appState.profile)
    }
    
    private var tableState: TableState {
        if viewModel.loading {
            return .loading
        } else if viewModel.vpcs.isEmpty {
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
        
        service.listVPCs(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let vpcs):
                    viewModel.vpcs = vpcs
                case .failure(let error):
                    print(error)
                    viewModel.sheet = .error(error)
                }
                
                viewModel.loading = false
            }
        })
    }
    
    private func handleShowAddVPC() {
        // TODO
    }
    
    private func handleDeleteVPC(_ vpc: VPC) {
        // TODO
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

fileprivate class VPCServiceViewModel: ObservableObject {
    @Published var mode: ViewMode = .list
    @Published var vpcs: [VPC] = []
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

struct VPCServiceView_Preview: PreviewProvider {
    static var previews: some View {
        VPCServiceView(view: .sns(component: .subscriptions))
    }
}
