//
//  VPCIPAMsView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCIPAMsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: VPCIPAMViewModel = VPCIPAMViewModel()
    let view: AWSService
    
    var body: some View {
        Group {
            switch viewModel.mode {
            case .noRegion:
                NoRegionPlaceholderView()
                
            case .list:
                VPCIPAMListView(region: $appState.region,
                                ipams: $viewModel.ipams,
                                state: tableState,
                                onAdd: handleShowAddIPAM,
                                onDelete: handleDeleteIPAM)
            case .add:
                VPCCreateIPAMView(onCommit: handleAddIPAM,
                                  onCancel: handleCloseSubView)
            }
        }
        .navigationSubtitle("IPAMs")
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
        } else if viewModel.ipams.isEmpty {
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
        
        service.listIPAMs(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ipams):
                    viewModel.ipams = ipams
                case .failure(let error):
                    print(error)
                    viewModel.sheet = .error(error)
                }
                
                viewModel.loading = false
            }
        })
    }
    
    private func handleShowAddIPAM() {
        viewModel.mode = .add
    }
    
    private func handleAddIPAM(_ request: EC2.CreateIpamRequest) {
        guard let service = service else { return }
        service.createIPAM(request, completion: afterOperation)
    }
    
    private func handleDeleteIPAM(_ ipam: IPAM) {
        guard let service = service else { return }
        service.deleteIPAM(ipam.id, completion: afterOperation)
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

fileprivate class VPCIPAMViewModel: ObservableObject {
    @Published var mode: ViewMode = .list
    @Published var ipams: [IPAM] = []
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

struct VPCIPAMView_Preview: PreviewProvider {
    static var previews: some View {
        VPCIPAMsView(view: .vpc(component: .ipams))
    }
}
