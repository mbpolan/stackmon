//
//  SNSTopicListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSNS
import SwiftUI

// MARK: - View

struct SNSTopicListView: View {
    @Binding var topics: [SNSTopic]
    let hasNoData: Bool
    let onAdd: () -> Void
    let onPublish: (_ topic: SNSTopic) -> Void
    let onDelete: (_ topic: SNSTopic) -> Void
    
    var body: some View {
        TableListView(data: $topics,
                      configuration: configuration,
                      hasNoData: hasNoData,
                      onRowAction: handleRowAction)
            .navigationSubtitle("Topics")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
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
    
    private var configuration: TableListView<SNSTopic, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "There are no topics",
            columns: [.topic, .type],
            gridColumns: [
                GridItem(.flexible(minimum: 150), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
            ],
            rowActions: [
                .publish,
                .delete
            ])
    }
    
    private func handleRowAction(_ action: RowAction, _ datum: SNSTopic) {
        switch action {
        case .publish:
            onPublish(datum)
        case .delete:
            onDelete(datum)
        }
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
}

// MARK: - Extensions

extension SNSTopic: TableCellData {
    func getTextForColumn(_ column: SNSTopicListView.Column) -> String {
        switch column {
        case .topic:
            return self.topicARN
        case .type:
            return getTextForType()
        }
    }
    
    private func getTextForType() -> String {
        switch type {
        case .standard:
            return "Standard"
        case .fifo:
            return "FIFO"
        }
    }
}

extension SNSTopicListView {
    enum Column: TableColumn {
        typealias ColumnType = Self
        
        case topic
        case type
        
        var label: String {
            switch self {
            case .topic:
                return "Topic"
            case .type:
                return "Type"
            }
        }
        
        var id: Self { self }
    }
    
    enum RowAction: TableRowAction {
        typealias T = Self
        
        case publish
        case delete
        
        var id: RowAction { self }
        
        var label: String {
            switch self {
            case .publish:
                return "Publish"
            case .delete:
                return "Delete"
            }
        }
        
        var isDivider: Bool {
            switch self {
            case .publish:
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Preview

struct SNSTopicListView_Preview: PreviewProvider {
    @State private static var topics: [SNSTopic] = [
        SNSTopic(topicARN: "arn:aws:sns::/test")
    ]
    
    static var previews: some View {
        SNSTopicListView(topics: $topics,
                         hasNoData: false,
                         onAdd: { },
                         onPublish: { _ in },
                         onDelete: { _ in })
            .frame(width: 500)
    }
}
