//
//  SNSServiceView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSNS
import SwiftUI

// MARK: - View

struct SNSServiceView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: SNSServiceViewModel = SNSServiceViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .list:
                SNSTopicListView(topics: $viewModel.topics,
                                 hasNoData: hasNoData,
                                 onAdd: handleAddTopic,
                                 onPublish: handleShowPublish,
                                 onDelete: handleDeleteTopic)
            
            case .publish(let topic):
                SNSTopicPublishView(topic: topic,
                                    onCommit: handlePublish,
                                    onCancel: handleCloseSubView)
            }
        }
        .navigationTitle("Simple Notification Service (SNS)")
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
    
    private var service: SNSService {
        SNSService(client: appState.client, profile: appState.profile)
    }
    
    private var hasNoData: Bool {
        !viewModel.loading && viewModel.topics.isEmpty
    }
    
    private func handleLoad() {
        viewModel.loading = true
        
        service.listTopics(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let topics):
                    viewModel.topics = topics
                case .failure(let error):
                    print(error)
                    viewModel.sheet = .error(error)
                }
                
                viewModel.loading = false
            }
        })
    }
    
    private func handleAddTopic() {
        // TODO
    }
    
    private func handleDeleteTopic(_ topic: SNSTopic) {
        service.deleteQueue(topic.topicARN, completion: afterOperation)
    }
    
    private func handleShowPublish(_ topic: SNSTopic) {
        viewModel.mode = .publish(topic)
    }
    
    private func handlePublish(_ request: SNS.PublishInput) {
        service.publish(request, completion: afterOperation)
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

class SNSServiceViewModel: ObservableObject {
    @Published var mode: ViewMode = .list
    @Published var topics: [SNSTopic] = []
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
        case publish(_ topic: SNSTopic)
    }
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}