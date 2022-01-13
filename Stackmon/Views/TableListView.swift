//
//  TableListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SwiftUI

// MARK: - View

protocol TableListViewAction { }

protocol TableColumn: Identifiable, Hashable {
    var label: String { get }
}

protocol TableRowAction: Identifiable {
    associatedtype T
    var label: String { get }
    var isDivider: Bool { get }
}

protocol TableCellData: Identifiable {
    associatedtype ColumnType: TableColumn
    func getTextForColumn(_ column: ColumnType) -> String
}

struct TableListView<DataType: TableCellData, ColumnType, RowActionType: TableRowAction>: View where DataType.ColumnType == ColumnType {
    @StateObject private var viewModel: TableListViewModel<DataType> = TableListViewModel<DataType>()
    @Binding var data: [DataType]
    let configuration: Configuration
    let hasNoData: Bool
    let onRowAction: (_ action: RowActionType, _ datum: DataType) -> Void
    
    struct Configuration {
        let noDataText: String
        let columns: [ColumnType]
        let gridColumns: [GridItem]
        let rowActions: [RowActionType]
    }
    
    var body: some View {
        VStack {
            if hasNoData {
                Text(configuration.noDataText)
                    .foregroundColor(Color.secondary)
                    .padding()
                    .centered(.all)
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: configuration.gridColumns, spacing: 0) {
                            // use indicies as id values for headers to avoid conflicts with data
                            ForEach(configuration.columns.indices) { i in
                                HStack {
                                    Text(configuration.columns[i].label)
                                        .bold()
                                        .padding([.leading, .top, .bottom], 3)
                                    
                                    Spacer()
                                }
                            }
                            
                            ForEach(data) { datum in
                                ForEach(configuration.columns, id: \.self) { column in
                                    TableListCellView(datum: datum,
                                                      text: datum.getTextForColumn(column),
                                                      rowActions: configuration.rowActions,
                                                      onTapGesture: { handleSelection(datum) },
                                                      onRowAction: onRowAction)
                                }
                            }
                        }
                    }
                    .padding(5)
                }
            }
        }
    }
    
    private func handleSelection(_ datum: DataType) {
        viewModel.selection = datum.id
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
}

// MARK: - Cell View

fileprivate struct TableListCellView<DataType: TableCellData, RowActionType: TableRowAction>: View {
    let datum: DataType
    let text: String
    let rowActions: [RowActionType]
    let onTapGesture: () -> Void
    let onRowAction: (_ action: RowActionType, _ datum: DataType) -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .padding(4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .contextMenu {
            ForEach(rowActions) { action in
                Button(action.label) { onRowAction(action, datum) }
                if action.isDivider {
                    Divider()
                }
            }
        }
        .onTapGesture(perform: onTapGesture)
    }
}

// MARK: - View Model

class TableListViewModel<T: TableCellData>: ObservableObject {
    @Published var selection: T.ID?
}

// MARK: - Preview

struct TableListView_Preview: PreviewProvider {
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
