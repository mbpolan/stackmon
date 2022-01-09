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
        GeometryReader { geo in
            Form {
                Section(header: Text("Message")) {
                    TextEditor(text: $viewModel.message)
                        .frame(height: geo.size.height / 2)
                        .padding(5)
                }
                .padding([.bottom], 5)
                
                Section(header: Text("Properties")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
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
                }
                
                Spacer()
            }
            .frame(width: geo.size.width / 3, height: nil, alignment: .center)
            .centered(.horizontal)
        }
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

class SQSSendMessageViewModel: ObservableObject {
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
