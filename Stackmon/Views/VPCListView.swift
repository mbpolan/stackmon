//
//  VPCListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/18/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCListView: View {
    @Binding var region: Region?
    @Binding var vpcs: [VPC]
    let state: TableState
    let onAdd: () -> Void
    let onDelete: (_ topic: VPC) -> Void
    
    var body: some View {
        TableListView(data: $vpcs,
                      configuration: configuration,
                      state: state,
                      onRowAction: handleRowAction)
            .navigationSubtitle("VPCs")
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
    
    private var configuration: TableListView<VPC, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no VPCs",
            columns: Column.allCases,
            gridColumns: [
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
    
    private func handleRowAction(_ action: RowAction, _ datum: VPC) {
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

extension VPC: TableCellData {
    func getTextForColumn(_ column: VPCListView.Column) -> String {
        switch column {
        case .id:
            return self.id
        case .ipv4CidrBlock:
            return self.ipv4CidrBlock ?? "-"
        case .ipv6CidrBlock:
            return self.ipv6CidrBlockAssociationSet ?? "-"
        case .state:
            return self.state?.description ?? "Unknown"
        case .tenancy:
            return self.tenancy?.description ?? "Unknown"
        case .isDefault:
            guard let isDefault = self.isDefault else { return "Unknown" }
            return isDefault ? "Yes" : "No"
        case .ownerID:
            return self.ownerID ?? "Unknown"
        }
    }
}

extension VPCListView {
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case id
        case ipv4CidrBlock
        case ipv6CidrBlock
        case state
        case tenancy
        case isDefault
        case ownerID
        
        var label: String {
            switch self {
            case .id:
                return "VPC ID"
            case .ipv4CidrBlock:
                return "IPv4 CIDR"
            case .ipv6CidrBlock:
                return "IPv6 CIDR"
            case .state:
                return "State"
            case .tenancy:
                return "Tenant"
            case .isDefault:
                return "Default"
            case .ownerID:
                return "Owner Account ID"
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

struct VPCListView_Preview: PreviewProvider {
    @State private static var region: Region? = .useast1
    @State private static var vpcs: [VPC] = [
        VPC(id: "vpc-123",
            ipv4CidrBlock: "192.168.0.0/24",
            ipv6CidrBlockAssociationSet: nil,
            state: EC2.VpcState.available,
            tenancy: EC2.Tenancy.default,
            isDefault: true,
            ownerID: "123456789")
    ]
    
    static var previews: some View {
        VPCListView(region: $region,
                    vpcs: $vpcs,
                    state: .ready,
                    onAdd: { },
                    onDelete: { _ in })
            .frame(width: 500)
    }
}

