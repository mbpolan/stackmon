//
//  SQSQueueListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSQS
import SwiftUI

// MARK: - View

struct SQSQueueListView: View {
    @Binding var region: Region?
    @Binding var queues: [SQSQueue]
    let hasNoData: Bool
    let onAdd: () -> Void
    let onSendMessage: (_ queue: SQSQueue) -> Void
    let onDelete: (_ queue: SQSQueue) -> Void
    let onPurge: (_ queue: SQSQueue) -> Void
    
    var body: some View {
        TableListView(data: $queues,
                      configuration: configuration,
                      hasNoData: hasNoData,
                      onRowAction: handleRowAction)
        .navigationSubtitle("Queues")
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
    
    var configuration: TableListView<SQSQueue, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no queues",
            columns: Column.allCases,
            gridColumns: [
                GridItem(.flexible(minimum: 150), spacing: 0),
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
                GridItem(.flexible(minimum: 150), spacing: 0),
            ],
            rowActions: RowAction.allCases)
    }
    
    private func handleRowAction(_ action: RowAction, _ datum: SQSQueue) {
        switch action {
        case .sendMessage:
            onSendMessage(datum)
        case .purge:
            onPurge(datum)
        case .delete:
            onDelete(datum)
        }
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
}

// MARK: - Extensions

extension SQSQueue: TableCellData {
    func getTextForColumn(_ column: SQSQueueListView.Column) -> String {
        switch column {
        case .queueName:
            return self.name
        case .numVisibleMessages:
            return textForNumber(self.numVisibleMessages)
        case .numInFlightMessages:
            return textForNumber(self.numInFlightMessages)
        case .type:
            return textForType
        case .created:
            return DateFormatter.formatListView(self.created)
        }
    }
    
    private var textForType: String {
        switch type {
        case .standard:
            return "Standard"
        case .fifo:
            return "FIFO"
        }
    }
    
    private func textForNumber(_ value: Int?) -> String {
        guard let value = value else { return "" }
        return String(value)
    }
}

extension SQSQueueListView {
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case queueName
        case numVisibleMessages
        case numInFlightMessages
        case type
        case created
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .queueName:
                return "Queue Name"
            case .numVisibleMessages:
                return "Visible Messages"
            case .numInFlightMessages:
                return "In-Flight Messages"
            case .type:
                return "Type"
            case .created:
                return "Created On"
            }
        }
    }
    
    enum RowAction: TableRowAction, CaseIterable {
        typealias T = Self
        
        case sendMessage
        case purge
        case delete
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .sendMessage:
                return "Send Message"
            case .purge:
                return "Purge"
            case .delete:
                return "Delete"
            }
        }
        
        var isDivider: Bool {
            switch self {
            case .purge:
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Preview

struct SQSQueueListView_Preview: PreviewProvider {
    @State private static var region: Region? = .useast1
    @State private static var queues: [SQSQueue] = [
        SQSQueue(queueURL: "http://localhost:4566/test-queue")
    ]
    
    static var previews: some View {
        SQSQueueListView(region: $region,
                         queues: $queues,
                         hasNoData: false,
                         onAdd: { },
                         onSendMessage: { _ in },
                         onDelete: { _ in },
                         onPurge: { _ in })
    }
}
