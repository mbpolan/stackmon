//
//  S3BucketListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoS3
import SwiftUI

// MARK: - View

struct S3BucketListView: View {
    @StateObject private var viewModel: S3BucketListViewModel = S3BucketListViewModel()
    @Binding var buckets: [S3Bucket]
    let state: TableState
    let onAdd: () -> Void
    let onDelete: (_ bucket: S3Bucket) -> Void
    let onBrowse: (_ bucket: S3Bucket) -> Void
    
    var body: some View {
        TableListView(data: $buckets,
                      configuration: configuration,
                      state: state,
                      onRowAction: handleRowAction)
        .navigationSubtitle("Buckets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    // buckets are considered global resources
                    AWSRegionPicker(region: $viewModel.region, allowedRegions: [])
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: handleRefresh) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
        }
    }
    
    var configuration: TableListView<S3Bucket, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no buckets",
            columns: Column.allCases,
            gridColumns: [
                GridItem(.flexible(minimum: 150), spacing: 0),
                GridItem(.flexible(minimum: 150), spacing: 0),
            ],
            rowActions: RowAction.allCases)
    }
    
    private func handleRowAction(_ action: RowAction, _ datum: S3Bucket) {
        switch action {
        case .default, .browse:
            onBrowse(datum)
        case .delete:
            onDelete(datum)
        }
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
}

// MARK: - View Model

fileprivate class S3BucketListViewModel: ObservableObject {
    @Published var region: Region?
}

// MARK: - Extensions

extension S3Bucket: TableCellData {
    func getTextForColumn(_ column: S3BucketListView.Column) -> String {
        switch column {
        case .name:
            return self.name
        case .created:
            return DateFormatter.formatListView(self.created)
        }
    }
}

extension S3BucketListView {
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case name
        case created
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .name:
                return "Bucket Name"
            case .created:
                return "Created On"
            }
        }
    }
    
    enum RowAction: TableRowAction, CaseIterable {
        typealias T = Self
        
        case `default`
        case browse
        case delete
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .default:
                return ""
            case .browse:
                return "Browse"
            case .delete:
                return "Delete"
            }
        }
        
        var isDefault: Bool {
            switch self {
            case .default:
                return true
            default:
                return false
            }
        }
        
        var isDivider: Bool {
            return false
        }
    }
}

// MARK: - Preview

struct S3BucketListView_Preview: PreviewProvider {
    @State private static var buckets: [S3Bucket] = [
        S3Bucket(name: "test-bucket", created: Date())
    ]
    
    static var previews: some View {
        S3BucketListView(buckets: $buckets,
                         state: .ready,
                         onAdd: { },
                         onDelete: { _ in },
                         onBrowse: { _ in })
    }
}
