//
//  VPCIPAMListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCIPAMListView: View {
    @Binding var region: Region?
    @Binding var ipams: [IPAM]
    let state: TableState
    let onAdd: () -> Void
    let onDelete: (_ ipam: IPAM) -> Void
    
    var body: some View {
        TableListView(data: $ipams,
                      configuration: configuration,
                      state: state,
                      onRowAction: handleRowAction)
            .navigationSubtitle("IPAMs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        AWSRegionPicker(region: $region)
                        
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
    
    private var configuration: TableListView<IPAM, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no IPAMs",
            columns: Column.allCases,
            gridColumns: [
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
            ],
            rowActions: RowAction.allCases)
    }
    
    private func handleRowAction(_ action: RowAction, _ datum: IPAM) {
        switch action {
        case .delete:
            onDelete(datum)
        }
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
}

// MARK: - Extensions

extension IPAM: TableCellData {
    func getTextForColumn(_ column: VPCIPAMListView.Column) -> String {
        switch column {
        case .id:
            return self.id
        case .description:
            return self.description ?? "-"
        case .state:
            return self.state?.description ?? "-"
        case .region:
            return self.region ?? "Unknown"
        case .ownerID:
            return self.ownerID ?? "Unknown"
        case .scopeCount:
            guard let scopeCount = self.scopeCount else { return "-" }
            return String(scopeCount)
        }
    }
}

extension VPCIPAMListView {
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case id
        case description
        case state
        case region
        case ownerID
        case scopeCount
        
        var label: String {
            switch self {
            case .id:
                return "ID"
            case .description:
                return "Description"
            case .state:
                return "State"
            case .region:
                return "Region"
            case .ownerID:
                return "Owner ID"
            case .scopeCount:
                return "Scope Count"
            }
        }
        
        var id: Self { self }
    }
    
    enum RowAction: TableRowAction, CaseIterable {
        typealias T = Self
        
        case delete
        
        var id: RowAction { self }
        
        var label: String {
            switch self {
            case .delete:
                return "Delete"
            }
        }
        
        var isDivider: Bool {
            switch self {
            default:
                return false
            }
        }
    }
}

// MARK: - Preview

struct VPCIPAMListView_Preview: PreviewProvider {
    @State private static var region: Region? = .useast1
    @State private static var ipams: [IPAM] = [
        IPAM(id: "ipam-123",
             description: "Foo",
             state: EC2.IpamState.createComplete,
             region: "us-east-1",
             ownerID: "000000000",
             scopeCount: 42)
    ]
    
    static var previews: some View {
        VPCIPAMListView(region: $region,
                        ipams: $ipams,
                        state: .ready,
                        onAdd: { },
                        onDelete: { _ in })
            .frame(width: 500)
    }
}
