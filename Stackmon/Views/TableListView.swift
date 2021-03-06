//
//  TableListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SwiftUI

// MARK: - Protocols

protocol TableListViewAction { }

protocol TableColumn: Identifiable, Hashable {
    var label: String { get }
}

protocol TableRowAction: Identifiable {
    associatedtype T
    var label: String { get }
    var isDefault: Bool { get }
    var isDivider: Bool { get }
}

extension TableRowAction {
    var isDefault: Bool { false }
}

protocol TableCellData: Identifiable {
    associatedtype ColumnType: TableColumn
    func getTextForColumn(_ column: ColumnType) -> String
}

enum TableState {
    case loading
    case noData
    case ready
}

// MARK: - View

struct TableListView<DataType: TableCellData, ColumnType, RowActionType: TableRowAction>: View where DataType.ColumnType == ColumnType {
    @StateObject private var viewModel: TableListViewModel<DataType> = TableListViewModel<DataType>()
    @Binding var data: [DataType]
    let configuration: Configuration
    let state: TableState
    let onRowAction: (_ action: RowActionType, _ datum: DataType) -> Void
    
    struct Configuration {
        let noDataText: String
        let columns: [ColumnType]
        let gridColumns: [GridItem]
        let rowActions: [RowActionType]
    }
    
    var body: some View {
        VStack {
            if state == .loading {
              ProgressView()
                    .padding()
                    .centered(.all)
            } else if state == .noData {
                Text(configuration.noDataText)
                    .foregroundColor(Color.secondary)
                    .padding()
                    .centered(.all)
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: configuration.gridColumns, spacing: 0) {
                            ForEach(configuration.columns) { column in
                                VStack {
                                    HStack {
                                        Text(column.label)
                                            .bold()
                                            .padding([.leading, .top, .bottom], 3)
                                        
                                        Spacer()
                                    }
                                    
                                    Divider()
                                }
                                .id("header\(column.id)")
                            }
                            
                            // lay out the data by building each row independently
                            ForEach(data.indices, id: \.self) { rowIndex in
                                ForEach(configuration.columns.indices, id: \.self) { columnIndex in
                                    VStack(spacing: 0) {
                                        TableListCellView(datum: data[rowIndex],
                                                          text: data[rowIndex].getTextForColumn(configuration.columns[columnIndex]),
                                                          rowActions: configuration.rowActions,
                                                          onTapGesture: { handleSelection(data[rowIndex]) },
                                                          onRowAction: onRowAction)
                                            .padding([.top, .bottom], 3)
                                        
                                        Divider()
                                            .padding(0)
                                            .frame(height: 1)
                                        
                                    }
                                    .id("cell\(rowIndex)\(columnIndex)")
                                    .background(viewModel.selection == data[rowIndex].id
                                                ? Color.accentColor.roundedSpan(3,
                                                                                first: columnIndex == 0,
                                                                                last: columnIndex == configuration.columns.count - 1)
                                                : nil)
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
                .lineLimit(1)
                .padding(4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .contextMenu {
            ForEach(contextMenuActions) { action in
                Button(action.label) { onRowAction(action, datum) }
                if action.isDivider {
                    Divider()
                }
            }
        }
        .onTapGesture(count: 2, perform: {
            guard let `default` = rowActions.first(where: { $0.isDefault }) else { return }
            
            onRowAction(`default`, datum)
        })
        .onTapGesture(perform: onTapGesture)
    }
    
    private var contextMenuActions: [RowActionType] {
        return rowActions.filter { !$0.isDefault }
    }
}

// MARK: - View Model

class TableListViewModel<T: TableCellData>: ObservableObject {
    @Published var selection: T.ID?
}

// MARK: - Preview

struct TableListView_Preview: PreviewProvider {
    @State static var data: [CellData] = [
        CellData(name: "Foo", description: "This is some foo", count: 5),
        CellData(name: "Bar", description: "This is some bar", count: 15),
        CellData(name: "Fizz Buzz", description: "Fizz buzz and some jazz", count: 255),
    ]
    
    enum Column: TableColumn, CaseIterable {
        typealias ColumnType = Self
        
        case name
        case description
        case count
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .name:
                return "Name"
            case .description:
                return "Description"
            case .count:
                return "Created On"
            }
        }
    }
    
    enum RowAction: TableRowAction, CaseIterable {
        typealias T = Self
        
        case delete
        
        var id: Self { self }
        
        var label: String {
            "Delete"
        }
        
        var isDivider: Bool {
            false
        }
    }
    
    struct CellData: TableCellData {
        let name: String
        let description: String
        let count: Int
        
        var id: String { name }
        
        func getTextForColumn(_ column: TableListView_Preview.Column) -> String {
            switch column {
            case .name:
                return name
            case .description:
                return description
            case .count:
                return String(count)
            }
        }
    }
    
    static var configuration: TableListView<CellData, Column, RowAction>.Configuration {
        TableListView.Configuration(
            noDataText: "No data found",
            columns: Column.allCases,
            gridColumns: [
                GridItem(.flexible(minimum: 100), spacing: 0),
                GridItem(.flexible(minimum: 150), spacing: 0),
                GridItem(.flexible(minimum: 50), spacing: 0),
            ],
            rowActions: RowAction.allCases)
    }
    
    static var previews: some View {
        TableListView(data: $data,
                      configuration: configuration,
                      state: .loading,
                      onRowAction: { _, _ in })
            .previewDisplayName("Loading")
            .frame(width: 500)
    }
}
