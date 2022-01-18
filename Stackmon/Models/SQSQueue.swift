//
//  SQSQueue.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation

class SQSQueue: Identifiable, Hashable, Equatable, ObservableObject {
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
    
    static func == (lhs: SQSQueue, rhs: SQSQueue) -> Bool {
        return lhs.queueURL == rhs.queueURL &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.numVisibleMessages == rhs.numVisibleMessages
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(queueURL)
    }
}
