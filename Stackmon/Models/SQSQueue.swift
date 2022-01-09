//
//  SQSQueue.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation

class SQSQueue: Identifiable, ObservableObject {
    @Published var queueURL: String
    @Published var name: String
    @Published var type: QueueType
    @Published var numVisibleMessages: Int?
    @Published var numInFlightMessages: Int?
    @Published var created: Date?
    
    enum QueueType {
        case standard
        case fifo
    }
    
    init(queueURL: String) {
        self.queueURL = queueURL
        self.name = queueURL.components(separatedBy: "/").last ?? queueURL
        self.type = queueURL.hasSuffix(".fifo") ? .fifo : .standard
    }
    
    init(queueURL: String, numVisibleMessages: Int?, numInFlightMessages: Int?, created: Date?) {
        self.queueURL = queueURL
        self.name = queueURL.components(separatedBy: "/").last ?? queueURL
        self.type = queueURL.hasSuffix(".fifo") ? .fifo : .standard
        self.numVisibleMessages = numVisibleMessages
        self.numInFlightMessages = numInFlightMessages
        self.created = created
    }
    
    var id: String {
        self.queueURL
    }
}
