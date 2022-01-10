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
    @StateObject private var viewModel: SNSTopicListViewModel = SNSTopicListViewModel()
    @Binding var topics: [SNSTopic]
    let hasNoData: Bool
    let onAdd: () -> Void
    let onPublish: (_ topic: SNSTopic) -> Void
    let onDelete: (_ topic: SNSTopic) -> Void
    
    var body: some View {
        VStack {
            if hasNoData {
                Text("There are no topics")
                    .foregroundColor(Color.secondary)
                    .padding()
                    .centered(.all)
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 150), spacing: 0),
                            GridItem(.flexible(minimum: 100), spacing: 0),
                        ], spacing: 0) {
                            Text("Topic Name")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            
                            Text("Type")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            
                            ForEach(topics) { topic in
                                SNSTopicListCellView(text: topic.name,
                                                     onTapGesture: { handleSelection(topic) },
                                                     onPublish: { onPublish(topic) },
                                                     onDelete: { onDelete(topic) })
                                    .background(viewModel.selection == topic.topicARN ? Color.accentColor : nil)
                                
                                SNSTopicListCellView(text: textForType(topic.type),
                                                     onTapGesture: { handleSelection(topic) },
                                                     onPublish: { onPublish(topic) },
                                                     onDelete: { onDelete(topic) })
                                    .background(viewModel.selection == topic.topicARN ? Color.accentColor : nil)
                            }
                        }
                    }
                    .padding(5)
                }
            }
        }
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
    
    private func handleSelection(_ topic: SNSTopic) {
        viewModel.selection = topic.topicARN
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
    
    private func textForType(_ type: SNSTopic.TopicType) -> String {
        switch type {
        case .standard:
            return "Standard"
        case .fifo:
            return "FIFO"
        }
    }
}

// MARK: - Cell View

fileprivate struct SNSTopicListCellView: View {
    let text: String
    let onTapGesture: () -> Void
    let onPublish: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .padding(4)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Publish", action: onPublish)
            Divider()
            Button("Delete", action: onDelete)
        }
        .onTapGesture(perform: onTapGesture)
    }
}

// MARK: - View Model

class SNSTopicListViewModel: ObservableObject {
    @Published var selection: String?
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
    }
}
