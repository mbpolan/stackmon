//
//  S3ServiceView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SotoS3
import SwiftUI

// MARK: - View

struct S3ServiceView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: S3ServiceViewModel = S3ServiceViewModel()
    let view: AWSService
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .list:
                S3BucketListView(buckets: $viewModel.buckets,
                                 state: tableState,
                                 onAdd: handleAddBucket,
                                 onDelete: handleDeleteBucket)
            case .new:
                S3BucketDetailEditorView(onCommit: handleNewBucket,
                                         onCancel: handleCloseNewBucket)
            }
        }
        .navigationTitle("Simple Storage Service (S3)")
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
    }
    
    private var service: S3Service {
        S3Service(client: appState.client, profile: appState.profile)
    }
    
    private var tableState: TableState {
        if viewModel.loading {
            return .loading
        } else if viewModel.buckets.isEmpty {
            return .noData
        } else {
            return .ready
        }
    }
    
    private func handleLoad() {
        viewModel.loading = true
        
        service.listBuckets(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let buckets):
                    viewModel.buckets = buckets
                case .failure(let error):
                    print(error)
                    viewModel.sheet = .error(error)
                }
                
                viewModel.loading = false
            }
        })
    }
    
    private func handleAddBucket() {
        viewModel.mode = .new
    }
    
    private func handleNewBucket(_ request: S3.CreateBucketRequest) {
        service.createBucket(request) { result in
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
    
    private func handleDeleteBucket(_ bucket: S3Bucket) {
        service.deleteBucket(bucket.name) { result in
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
    
    private func handleCloseNewBucket() {
        viewModel.mode = .list
    }
    
    private func handleCloseSheet() {
        viewModel.sheet = .none
    }
}

// MARK: - View Model

fileprivate class S3ServiceViewModel: ObservableObject {
    @Published var mode: ViewMode = .list
    @Published var buckets: [S3Bucket] = []
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
        case list
        case new
    }
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}

// MARK: - Preview

struct S3ServiceView_Preview: PreviewProvider {
    static var previews: some View {
        S3ServiceView(view: .s3)
    }
}
