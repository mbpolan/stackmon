//
//  SNSSubscriptionListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSNS
import SwiftUI

// MARK: - View

struct SNSSubscriptionListView: View {
    @Binding var region: Region?
    @Binding var subscriptions: [SNSSubscription]
    let hasNoData: Bool
    let onAdd: () -> Void
    let onDelete: (_ topic: SNSSubscription) -> Void
    
    var body: some View {
        TableListView(data: $subscriptions,
                      configuration: configuration,
                      hasNoData: hasNoData,
                      onRowAction: handleRowAction)
            .navigationSubtitle("Subscriptions")
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
    
    private var configuration: TableListView<SNSSubscription, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no subscriptions",
            columns: Column.allCases,
            gridColumns: [
                GridItem(.flexible(minimum: 150), spacing: 0),
                GridItem(.flexible(minimum: 150), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 150), spacing: 0),
            ],
            rowActions: RowAction.allCases)
    }
    
    private func handleRowAction(_ action: RowAction, _ datum: SNSSubscription) {
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

extension SNSSubscription: TableCellData {
    func getTextForColumn(_ column: SNSSubscriptionListView.Column) -> String {
        switch column {
        case .id:
            return self.id
        case .endpoint:
            return self.endpoint ?? "Unknown"
        case .protocol:
            return self.protocol ?? "Unknown"
        case .topic:
            return self.topicARN ?? "Unknown"
        }
    }
}

extension SNSSubscriptionListView {
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case id
        case endpoint
        case `protocol`
        case topic
        
        var label: String {
            switch self {
            case .id:
                return "ID"
            case .endpoint:
                return "Endpoint"
            case .protocol:
                return "Protocol"
            case .topic:
                return "Topic"
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

struct SNSSubscriptionListView_Preview: PreviewProvider {
    @State private static var region: Region? = .useast1
    @State private static var subscriptions: [SNSSubscription] = [
        SNSSubscription(arn: "arn:aws:sns:/test-sub",
                        topicARN: "arn:aws:sns:/test-topic",
                        protocol: "SMS",
                        endpoint: "arn:aws:subscription:/endpoint")
    ]
    
    static var previews: some View {
        SNSSubscriptionListView(region: $region,
                                subscriptions: $subscriptions,
                                hasNoData: false,
                                onAdd: { },
                                onDelete: { _ in })
            .frame(width: 500)
    }
}
