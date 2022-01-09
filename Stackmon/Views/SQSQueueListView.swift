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
    @StateObject private var viewModel: SQSQueueListViewModel = SQSQueueListViewModel()
    @Binding var queues: [SQSQueue]
    let hasNoData: Bool
    let onAdd: () -> Void
    let onSendMessage: (_ queue: SQSQueue) -> Void
    let onDelete: (_ queue: SQSQueue) -> Void
    let onPurge: (_ queue: SQSQueue) -> Void
    
    var body: some View {
        VStack {
            if hasNoData {
                Text("There are no queues")
                    .foregroundColor(Color.secondary)
                    .padding()
                    .centered(.all)
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 150)),
                            GridItem(.flexible(minimum: 100)),
                            GridItem(.flexible(minimum: 50)),
                            GridItem(.flexible(minimum: 50)),
                            GridItem(.flexible(minimum: 150)),
                        ], spacing: 0) {
                            Text("Queue Name")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            
                            Text("Type")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            
                            Text("Visible Messages")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            
                            Text("In-Flight Messages")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            
                            Text("Created")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            
                            ForEach(queues) { queue in
                                // this is so awful
                                SQSQueueListCellView(text: queue.name,
                                                     onTapGesture: { handleSelection(queue) },
                                                     onSendMessage: { onSendMessage(queue) },
                                                     onDelete: { onDelete(queue) },
                                                     onPurge: { onPurge(queue) })
                                
                                SQSQueueListCellView(text: textForType(queue.type),
                                                     onTapGesture: { handleSelection(queue) },
                                                     onSendMessage: { onSendMessage(queue) },
                                                     onDelete: { onDelete(queue) },
                                                     onPurge: { onPurge(queue) })
                                
                                SQSQueueListCellView(text: textForNumber(queue.numVisibleMessages),
                                                     onTapGesture: { handleSelection(queue) },
                                                     onSendMessage: { onSendMessage(queue) },
                                                     onDelete: { onDelete(queue) },
                                                     onPurge: { onPurge(queue) })
                                
                                SQSQueueListCellView(text: textForNumber(queue.numVisibleMessages),
                                                     onTapGesture: { handleSelection(queue) },
                                                     onSendMessage: { onSendMessage(queue) },
                                                     onDelete: { onDelete(queue) },
                                                     onPurge: { onPurge(queue) })
                                
                                SQSQueueListCellView(text: DateFormatter.formatListView(queue.created),
                                                     onTapGesture: { handleSelection(queue) },
                                                     onSendMessage: { onSendMessage(queue) },
                                                     onDelete: { onDelete(queue) },
                                                     onPurge: { onPurge(queue) })
                            }
                        }
                    }
                    .padding(5)
                }
            }
        }
        .navigationSubtitle("Queues")
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
    
    private func handleSelection(_ queue: SQSQueue) {
        viewModel.selection = queue.queueURL
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
    
    private func textForType(_ type: SQSQueue.QueueType) -> String {
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

// MARK: - Cell View

fileprivate struct SQSQueueListCellView: View {
    let text: String
    let onTapGesture: () -> Void
    let onSendMessage: () -> Void
    let onDelete: () -> Void
    let onPurge: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .padding([.trailing, .top, .bottom], 3)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Send Message", action: onSendMessage)
            Divider()
            Button("Purge", action: onPurge)
            Button("Delete", action: onDelete)
        }
        .onTapGesture(perform: onTapGesture)
    }
}

// MARK: - View Model

class SQSQueueListViewModel: ObservableObject {
    @Published var selection: String?
}

// MARK: - Preview

struct SQSQueueListView_Preview: PreviewProvider {
    @State private static var queues: [SQSQueue] = [
        SQSQueue(queueURL: "http://localhost:4566/test-queue")
    ]
    
    static var previews: some View {
        SQSQueueListView(queues: $queues,
                         hasNoData: false,
                         onAdd: { },
                         onSendMessage: { _ in },
                         onDelete: { _ in },
                         onPurge: { _ in })
    }
}
