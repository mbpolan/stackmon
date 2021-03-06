//
//  SQSSendMessageView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Combine
import SotoSQS
import SwiftUI

// MARK: - View

struct SQSSendMessageView: View {
    @StateObject private var viewModel: SQSSendMessageViewModel = SQSSendMessageViewModel()
    let queue: SQSQueue
    let onCommit: (_ request: SQS.SendMessageRequest) -> Void
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
                    Text("Delay (seconds)")
                    TextField("", text: $viewModel.delaySeconds)
                        .onReceive(Just(viewModel.delaySeconds)) { value in
                            let numeric = value.filter { "0123456789".contains($0) }
                            if numeric != value {
                                viewModel.delaySeconds = numeric
                            }
                        }
                    
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
        .navigationSubtitle("\(queue.name) > Send Message")
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
        let request = SQS.SendMessageRequest(delaySeconds: Int(viewModel.delaySeconds) ?? 0,
                                             messageBody: viewModel.message,
                                             messageDeduplicationId: viewModel.dedupeID.emptyAsNil(),
                                             messageGroupId: viewModel.groupID.emptyAsNil(),
                                             queueUrl: queue.queueURL)
        
        onCommit(request)
    }
}

// MARK: - View Model

fileprivate class SQSSendMessageViewModel: ObservableObject {
    @Published var delaySeconds: String = "0" // beacuse swiftui >:(
    @Published var dedupeID: String = ""
    @Published var groupID: String = ""
    @Published var message: String = ""
}

// MARK: - Preview

struct SQSSendMessageView_Preview: PreviewProvider {
    static var previews: some View {
        SQSSendMessageView(queue: SQSQueue(queueURL: "http://localhost:4567/test-queue"),
                           onCommit: { _ in },
                           onCancel: { })
    }
}
