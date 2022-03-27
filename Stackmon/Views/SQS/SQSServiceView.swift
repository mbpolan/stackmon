//
//  SQSServiceView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSQS
import SwiftUI

// MARK: - View

struct SQSServiceView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: SQSServiceViewModel = SQSServiceViewModel()
    let view: AWSService
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .noRegion:
                NoRegionPlaceholderView()
            case .list:
                SQSQueueListView(region: $appState.region,
                                 queues: $viewModel.queues,
                                 state: tableState,
                                 onAdd: handleShowAddQueue,
                                 onSendMessage: handleShowSendMessage,
                                 onDelete: handleDeleteQueue,
                                 onPurge: handlePurgeQueue)
                
            case .add:
                SQSCreateQueueView(queues: $viewModel.queues,
                                   onCommit: handleAddQueue,
                                   onCancel: handleCloseSubView)
                
            case .sendMessage(let queue):
                SQSSendMessageView(queue: queue,
                                   onCommit: handleSendMessage,
                                   onCancel: handleCloseSubView)
            }
        }
        .navigationTitle("Simple Queue Service (SQS)")
        .sheet(isPresented: $viewModel.sheetShown, onDismiss: handleCloseSheet) {
            switch viewModel.sheet {
            case .error(let error):
                ErrorSheetView(error: error, onDismiss: handleCloseSheet)
            default:
                Text("An unknown error has occured")
            }
        }
        .onAppear(perform: handleLoad)
        .onRefresh(perform: handleLoad)
        .onChange(of: appState.region, perform: { _ in handleLoad() })
    }
    
    private var service: SQSService? {
        ServiceProvider.shared.sqs(appState)
    }
    
    private var tableState: TableState {
        if viewModel.loading {
            return .loading
        } else if viewModel.queues.isEmpty {
            return .noData
        } else {
            return .ready
        }
    }
    
    private func handleLoad() {
        guard let service = service else {
            viewModel.mode = .noRegion
            return
        }

        viewModel.loading = true
        
        service.listQueues(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let queues):
                    viewModel.queues = queues
                case .failure(let error):
                    print(error)
                    viewModel.sheet = .error(error)
                }
                
                viewModel.loading = false
            }
        })
    }
    
    private func handleShowAddQueue() {
        viewModel.mode = .add
    }
    
    private func handleAddQueue(_ request: SQS.CreateQueueRequest) {
        guard let service = service else { return }
        service.createQueue(request, completion: afterOperation)
    }
    
    private func handleDeleteQueue(_ queue: SQSQueue) {
        guard let service = service else { return }
        service.deleteQueue(queue.queueURL, completion: afterOperation)
    }
    
    private func handleShowSendMessage(_ queue: SQSQueue) {
        viewModel.mode = .sendMessage(queue)
    }
    
    private func handleSendMessage(_ request: SQS.SendMessageRequest) {
        guard let service = service else { return }
        service.sendMessage(request, completion: afterOperation)
    }
    
    private func handlePurgeQueue(_ queue: SQSQueue) {
        guard let service = service else { return }
        service.purgeQueue(queue.queueURL, completion: afterOperation)
    }
    
    private func handleCloseSubView() {
        viewModel.mode = .list
    }
    
    private func handleCloseSheet() {
        viewModel.sheet = .none
    }
    
    private func afterOperation<T>(_ result: Result<T, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(_):
                viewModel.mode = .list
                handleLoad()
            case .failure(let error):
                viewModel.sheet = .error(error)
            }
        }
    }
}

// MARK: - View Model

fileprivate class SQSServiceViewModel: ObservableObject {
    @Published var mode: ViewMode = .list
    @Published var queues: [SQSQueue] = []
    @Published var loading: Bool = true
    @Published var sheet: Sheet = .none {
        didSet {
            switch sheet {
            case .none:
                sheetShown = false
            default:
                sheetShown = true
            }
        }
    }
    @Published var sheetShown: Bool = false
    
    enum ViewMode {
        case noRegion
        case list
        case add
        case sendMessage(_ queue: SQSQueue)
    }
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}

// MARK: - Preview

struct SQSServiceView_Preview: PreviewProvider {
    static var previews: some View {
        SQSServiceView(view: .sqs)
    }
}
