//
//  VPCSubnetListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCSubnetListView: View {
    @Binding var region: Region?
    @Binding var subnets: [Subnet]
    let state: TableState
    let onAdd: () -> Void
    let onDelete: (_ subnet: Subnet) -> Void
    
    var body: some View {
        TableListView(data: $subnets,
                      configuration: configuration,
                      state: state,
                      onRowAction: handleRowAction)
            .navigationSubtitle("Subnets")
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
    
    private var configuration: TableListView<Subnet, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no subnets",
            columns: Column.allCases,
            gridColumns: [
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 100), spacing: 0)
            ],
            rowActions: RowAction.allCases)
    }
    
    private func handleRowAction(_ action: RowAction, _ datum: Subnet) {
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

extension Subnet: TableCellData {
    func getTextForColumn(_ column: VPCSubnetListView.Column) -> String {
        switch column {
        case .id:
            return self.id
        case .name:
            return self.name ?? "-"
        case .state:
            return self.state?.description ?? "-"
        case .vpcID:
            return self.vpcID ?? "Unknown"
        case .ipv4Cidr:
            return self.ipv4Cidr ?? "-"
        case .ipv6Cidr:
            return self.ipv6Cidr ?? "-"
        }
    }
}

extension VPCSubnetListView {
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case id
        case name
        case state
        case vpcID
        case ipv4Cidr
        case ipv6Cidr
        
        var label: String {
            switch self {
            case .id:
                return "ID"
            case .name:
                return "Name"
            case .state:
                return "State"
            case .vpcID:
                return "VPC ID"
            case .ipv4Cidr:
                return "IPv4 CIDR"
            case .ipv6Cidr:
                return "IPv6 CIDR"
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

struct VPCSubnetList_Preview: PreviewProvider {
    @State private static var region: Region? = .useast1
    @State private static var subnets: [Subnet] = [
        Subnet(id: "subnet-123",
               name: nil,
               state: EC2.SubnetState.available,
               vpcID: "vpc-123",
               ipv4Cidr: "192.168.0.0/24",
               ipv6Cidr: nil)
    ]
    
    static var previews: some View {
        VPCSubnetListView(region: $region,
                          subnets: $subnets,
                          state: .ready,
                          onAdd: { },
                          onDelete: { _ in })
            .frame(width: 500)
    }
}
