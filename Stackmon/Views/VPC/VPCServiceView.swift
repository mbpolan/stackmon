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
                    case .ipams:
                        VPCIPAMsView(view: view)
                        
                    case .subnets:
                        VPCSubnetsView(view: view)
                        
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
                
            case .add:
                VPCCreateView(onCommit: handleAddVPC,
                              onCancel: handleCloseSubView)
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
        ServiceProvider.shared.vpc(appState)
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
        viewModel.mode = .add
    }
    
    private func handleAddVPC(_ request: EC2.CreateVpcRequest) {
        guard let service = service else { return }
        service.createVPC(request, completion: afterOperation)
    }
    
    private func handleDeleteVPC(_ vpc: VPC) {
        guard let service = service else { return }
        service.deleteVPC(vpc.id, completion: afterOperation)
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
        case add
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
