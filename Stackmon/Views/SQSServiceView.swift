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
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .list:
                SQSQueueListView(queues: $viewModel.queues,
                                 hasNoData: hasNoData,
                                 onAdd: handleAddQueue,
                                 onSendMessage: handleShowSendMessage,
                                 onDelete: handleDeleteQueue,
                                 onPurge: handlePurgeQueue)
                
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
                Text("An error occured: \(error.localizedDescription)")
            default:
                Text("An unknown error has occured")
            }
        }
        .onAppear(perform: handleLoad)
        .onRefresh(perform: handleLoad)
    }
    
    private var service: SQSService {
        SQSService(client: appState.client, profile: appState.profile)
    }
    
    private var hasNoData: Bool {
        !viewModel.loading && viewModel.queues.isEmpty
    }
    
    private func handleLoad() {
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
    
    private func handleAddQueue() {
        // TODO
    }
    
    private func handleDeleteQueue(_ queue: SQSQueue) {
        service.deleteQueue(queue.queueURL, completion: afterOperation)
    }
    
    private func handleShowSendMessage(_ queue: SQSQueue) {
        viewModel.mode = .sendMessage(queue)
    }
    
    private func handleSendMessage(_ request: SQS.SendMessageRequest) {
        service.sendMessage(request, completion: afterOperation)
    }
    
    private func handlePurgeQueue(_ queue: SQSQueue) {
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

class SQSServiceViewModel: ObservableObject {
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
        case list
        case sendMessage(_ queue: SQSQueue)
    }
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}
