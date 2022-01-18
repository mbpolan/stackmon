//
//  SQSCreateQueueView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SotoSQS
import SwiftUI

// MARK: - View

struct SQSCreateQueueView: View {
    @StateObject private var viewModel: SQSCreateQueueViewModel = SQSCreateQueueViewModel()
    @Binding var queues: [SQSQueue]
    let onCommit: (_ bucket: SQS.CreateQueueRequest) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            Form {
                Section(header: Text("Basic")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
                        Text("Queue Name")
                        TextField("", text: $viewModel.name)

                        Text("Queue Type")
                        Picker("", selection: $viewModel.queueType) {
                            ForEach(SQSCreateQueueViewModel.QueueType.allCases, id: \.self) { type in
                                Text(type.text)
                            }
                        }
                    }
                }
                .padding([.bottom], 5)

                Section(header: Text("Configuration")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(maximum: 250)),
                        GridItem(.flexible(maximum: 150)),
                        GridItem(.flexible(maximum: 200)),
                    ], alignment: .leading, spacing: 10) {
                        Group {
                            Text("Visibility Timeout")
                            NumericField(value: $viewModel.visibilityTimeout)
                            TimeIntervalPicker(interval: $viewModel.visibilityTimeoutInterval,
                                               allowedIntervals: [.seconds, .minutes, .hours])

                            Text("Message Retention")
                            NumericField(value: $viewModel.messageRetention)
                            TimeIntervalPicker(interval: $viewModel.messageRetentionInterval)

                            Text("Delivery Delay")
                            NumericField(value: $viewModel.deliveryDelay)
                            TimeIntervalPicker(interval: $viewModel.deliveryDelayInterval,
                                               allowedIntervals: [.seconds, .minutes])
                        }

                        Group {
                            Text("Max Message Size")
                            NumericField(value: $viewModel.maxMessageSize)
                            Text("KB")

                            Text("Max Message Size")
                            NumericField(value: $viewModel.receieveWaitTime)
                            Text("Seconds")
                        }
                    }
                    .padding()
                }

                Section(header: Text("Dead-Letter Queue")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
                        Text("Target Queue")
                        Picker("", selection: $viewModel.deadLetterQueueARN) {
                            Text("None")
                                .tag(nil as String?)

                            ForEach(queues, id: \.self) { queue in
                                Text(queue.name)
                                    .tag(queue.queueURL as String?)
                            }
                        }

                        Text("Max Receives")
                        NumericField(value: $viewModel.deadLetterMaxReceives)
                            .disabled(viewModel.deadLetterQueueARN == nil)
                    }
                }

                Spacer()
            }
            .frame(width: geo.size.width / 2, height: nil, alignment: .center)
            .centered(.horizontal)
        }
        .navigationSubtitle("New Queue")
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
        !viewModel.name.isEmpty
    }
    
    private func handleConfirm() {
        let visibilityTimeoutInterval = viewModel.visibilityTimeoutInterval
        let messageRetentionInterval = viewModel.messageRetentionInterval
        let deliveryDelayInterval = viewModel.deliveryDelayInterval
        
        var queueName = viewModel.name
        var attributes: Dictionary<SQS.QueueAttributeName, String> = [
            SQS.QueueAttributeName.visibilitytimeout: String(visibilityTimeoutInterval.toSeconds(viewModel.visibilityTimeout)),
            SQS.QueueAttributeName.messageretentionperiod: String(messageRetentionInterval.toSeconds(viewModel.messageRetention)),
            SQS.QueueAttributeName.delayseconds: String(deliveryDelayInterval.toSeconds(viewModel.deliveryDelay)),
            SQS.QueueAttributeName.maximummessagesize: String(viewModel.maxMessageSize * 1024), // must be in terms of bytes
            SQS.QueueAttributeName.receivemessagewaittimeseconds: String(viewModel.receieveWaitTime)
        ]
        
        if viewModel.queueType == .fifo {
            // suffix the queue name with ".fifo" if needed
            if !queueName.hasSuffix(".fifo") {
                queueName = "\(queueName).fifo"
            }
            
            attributes[SQS.QueueAttributeName.fifoqueue] = "true"
        }
        
        onCommit(SQS.CreateQueueRequest(attributes: attributes,
                                        queueName: queueName))
    }
}

// MARK: - View Model

fileprivate class SQSCreateQueueViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var queueType: QueueType = .standard
    @Published var visibilityTimeout: Int = 30
    @Published var visibilityTimeoutInterval: Interval = .seconds
    @Published var messageRetention: Int = 4
    @Published var messageRetentionInterval: Interval = .days
    @Published var deliveryDelay: Int = 0
    @Published var deliveryDelayInterval: Interval = .seconds
    @Published var maxMessageSize: Int = 256
    @Published var receieveWaitTime: Int = 0
    @Published var deadLetterQueueARN: String?
    @Published var deadLetterMaxReceives: Int = 10
    
    enum QueueType: CaseIterable {
        case standard
        case fifo
        
        var text: String {
            switch self {
            case .standard:
                return "Standard"
            case .fifo:
                return "FIFO"
            }
        }
    }
}

// MARK: - Preview

struct SQSCreateQueueView_Preview: PreviewProvider {
    @State static var queues: [SQSQueue] = []
    
    static var previews: some View {
        SQSCreateQueueView(queues: $queues,
                           onCommit: { _ in },
                           onCancel: {})
    }
}
