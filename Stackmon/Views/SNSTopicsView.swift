//
//  SNSTopicsView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSNS
import SwiftUI

// MARK: - View

struct SNSTopicsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: SNSTopicsViewModel = SNSTopicsViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.mode {
            case .noRegion:
                NoRegionPlaceholderView()
            case .list:
                SNSTopicListView(region: $appState.region,
                                 topics: $viewModel.topics,
                                 state: tableState,
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
        .onChange(of: appState.region, perform: { _ in handleLoad() })
    }
    
    private var service: SNSService? {
        guard let region = appState.region else { return nil }
        return SNSService(client: appState.client, region: region, profile: appState.profile)
    }
    
    private var tableState: TableState {
        if viewModel.loading {
            return .loading
        } else if viewModel.topics.isEmpty {
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
        guard let service = service else { return }
        service.deleteTopic(topic.topicARN, completion: afterOperation)
    }
    
    private func handleShowPublish(_ topic: SNSTopic) {
        viewModel.mode = .publish(topic)
    }
    
    private func handlePublish(_ request: SNS.PublishInput) {
        guard let service = service else { return }
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

fileprivate class SNSTopicsViewModel: ObservableObject {
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
        case noRegion
        case list
        case publish(_ topic: SNSTopic)
    }
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}

// MARK: - Preview

struct SNSTopicsView_Preview: PreviewProvider {
    static var previews: some View {
        SNSTopicsView()
    }
}
