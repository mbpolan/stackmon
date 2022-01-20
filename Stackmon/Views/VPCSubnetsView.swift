//
//  VPCSubnetsView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCSubnetsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: VPCSubnetsViewModel = VPCSubnetsViewModel()
    let view: AWSService
    
    var body: some View {
        Group {
            switch viewModel.mode {
            case .noRegion:
                NoRegionPlaceholderView()
                
            case .list:
                VPCSubnetListView(region: $appState.region,
                                  subnets: $viewModel.subnets,
                                  state: tableState,
                                  onAdd: handleShowAddSubnet,
                                  onDelete: handleDeleteSubnet)
                
            case .add:
                VPCCreateSubnetView(onCommit: handleAddSubnet,
                                    onCancel: handleCloseSubView)
            }
        }
        .navigationSubtitle("Subnets")
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
        } else if viewModel.subnets.isEmpty {
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
        
        service.listSubnets(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let subnets):
                    viewModel.subnets = subnets
                case .failure(let error):
                    print(error)
                    viewModel.sheet = .error(error)
                }
                
                viewModel.loading = false
            }
        })
    }
    
    private func handleShowAddSubnet() {
        viewModel.mode = .add
    }
    
    private func handleAddSubnet(_ request: EC2.CreateSubnetRequest) {
        guard let service = service else { return }
        service.createSubnet(request, completion: afterOperation)
    }
    
    private func handleDeleteSubnet(_ subnet: Subnet) {
        guard let service = service else { return }
        service.deleteSubnet(subnet.id, completion: afterOperation)
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

fileprivate class VPCSubnetsViewModel: ObservableObject {
    @Published var mode: ViewMode = .list
    @Published var zones: [AvailabilityZone] = []
    @Published var subnets: [Subnet] = []
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

struct VPCSubnetsView_Preview: PreviewProvider {
    static var previews: some View {
        VPCSubnetsView(view: .vpc(component: .subnets))
    }
}
