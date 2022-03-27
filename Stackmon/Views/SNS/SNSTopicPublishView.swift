//
//  SNSTopicPublishView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Combine
import SotoSNS
import SwiftUI

// MARK: - View

struct SNSTopicPublishView: View {
    @StateObject private var viewModel: SNSTopicPublishViewModel = SNSTopicPublishViewModel()
    let topic: SNSTopic
    let onCommit: (_ request: SNS.PublishInput) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Message")) {
                TextEditor(text: $viewModel.message)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .disableAutocorrection(true)
                    .padding()
            }
            .padding([.bottom], 5)
            
            Section(header: Text("Properties")) {
                LazyVGrid(columns: [
                    GridItem(.flexible(maximum: 150)),
                    GridItem(.flexible(maximum: 250)),
                ], alignment: .leading, spacing: 10) {
                    Text("Subject")
                    TextField("", text: $viewModel.structure)
                    
                    Text("Message Structure")
                    TextField("", text: $viewModel.structure)
                    
                    Text("Message Group ID")
                    TextField("", text: $viewModel.groupID)
                    
                    Text("Deduplication ID")
                    TextField("", text: $viewModel.dedupeID)
                }
                .padding()
            }
            
            Spacer()
        }
        .centered(.horizontal)
        .navigationSubtitle("\(topic.name) > Publish")
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                }
                
                Button(action: handleConfirm) {
                    Image(systemName: "checkmark")
                }
                .disabled(!formValid)
            }
        }
    }
    
    private var formValid: Bool {
        !viewModel.message.isEmpty
    }
    
    private func handleConfirm() {
        let request = SNS.PublishInput(message: viewModel.message,
                                       messageDeduplicationId: viewModel.dedupeID.emptyAsNil(),
                                       messageGroupId: viewModel.groupID.emptyAsNil(),
                                       messageStructure: viewModel.structure.emptyAsNil(),
                                       subject: viewModel.subject.emptyAsNil(),
                                       topicArn: topic.topicARN)
        
        onCommit(request)
    }
}

// MARK: - View Model

fileprivate class SNSTopicPublishViewModel: ObservableObject {
    @Published var dedupeID: String = ""
    @Published var groupID: String = ""
    @Published var message: String = ""
    @Published var subject: String = ""
    @Published var structure: String = ""
}

// MARK: - Preview

struct SNSTopicPublishView_Preview: PreviewProvider {
    static var previews: some View {
        SNSTopicPublishView(topic: SNSTopic(topicARN: "arn:aws:sns::/test"),
                            onCommit: { _ in },
                            onCancel: { })
    }
}
