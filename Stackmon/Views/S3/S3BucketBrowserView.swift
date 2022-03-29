//
//  S3BucketBrowserView.swift
//  Stackmon
//
//  Created by Mike Polan on 3/26/22.
//

import SotoS3
import SwiftUI

// MARK: - View

struct S3BucketBrowserView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: S3BucketBrowserViewModel = S3BucketBrowserViewModel()
    let bucket: S3Bucket
    
    var body: some View {
        TableListView(data: $viewModel.objects,
                      configuration: configuration,
                      state: tableState,
                      onRowAction: handleRowAction)
        .navigationSubtitle(bucket.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: handleAdd) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: handleRefresh) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
        }
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
    
    private var service: S3Service? {
        ServiceProvider.shared.s3(appState)
    }
    
    private var tableState: TableState {
        if viewModel.loading {
            return .loading
        } else if viewModel.objects.isEmpty {
            return .noData
        } else {
            return .ready
        }
    }
    
    var configuration: TableListView<S3Object, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no objects in this bucket",
            columns: Column.allCases,
            gridColumns: [
                GridItem(.flexible(minimum: 150), spacing: 0),
                GridItem(.flexible(minimum: 150), spacing: 0),
            ],
            rowActions: RowAction.allCases)
    }
    
    private func handleRowAction(_ action: RowAction, _ datum: S3Object) {
        switch action {
        case .open:
            break
        case .delete:
            handleDelete(datum)
        }
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
    
    private func handleAdd() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK,
           let url = panel.url,
           let body = try? AWSPayload.byteBuffer(ByteBuffer(data: Data(contentsOf: url))) {
            
            let request = S3.PutObjectRequest(body: body,
                                              bucket: bucket.name,
                                              key: url.lastPathComponent)
            service?.putObject(request) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        handleLoad()
                    case .failure(let error):
                        viewModel.sheet = .error(error)
                    }
                }
            }
        }
    }
    
    private func handleDelete(_ object: S3Object) {
        
    }
    
    private func handleLoad() {
        viewModel.loading = true
        
        service?.listObjects(S3.ListObjectsV2Request(bucket: bucket.name)) { result in
            DispatchQueue.main.async {
                viewModel.loading = false
                
                switch result {
                case .success(let data):
                    viewModel.objects = data.data
                case .failure(let error):
                    viewModel.sheet = .error(error)
                }
            }
        }
    }
    
    private func handleCloseSheet() {
        viewModel.sheet = .none
    }
}

// MARK: - View Model

fileprivate class S3BucketBrowserViewModel: ObservableObject {
    @Published var objects: [S3Object] = []
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
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}

// MARK: - Extensions

extension S3Object: TableCellData {
    func getTextForColumn(_ column: S3BucketBrowserView.Column) -> String {
        switch column {
        case .name:
            return self.key
        case .modified:
            return DateFormatter.formatListView(self.modified)
        }
    }
}

extension S3BucketBrowserView {
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case name
        case modified
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .name:
                return "Object"
            case .modified:
                return "Last Modified"
            }
        }
    }
    
    enum RowAction: TableRowAction, CaseIterable {
        typealias T = Self
        
        case open
        case delete
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .open:
                return "Open"
            case .delete:
                return "Delete"
            }
        }
        
        var isDivider: Bool {
            return false
        }
    }
}

// MARK: - Preview

struct S3BucketBrowserView_Preview: PreviewProvider {
    static var previews: some View {
        S3BucketBrowserView(bucket: S3Bucket(
            name: "mike-test",
            created: nil
        ))
    }
}
