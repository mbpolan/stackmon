//
//  SNSSubscription.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation

class SNSSubscription: Identifiable, ObservableObject {
    @Published var arn: String
    @Published var topicARN: String?
    @Published var `protocol`: String?
    @Published var endpoint: String?
    
    init(arn: String, topicARN: String?, `protocol`: String?, endpoint: String?) {
        self.arn = arn
        self.topicARN = topicARN
        self.protocol = `protocol`
        self.endpoint = endpoint
    }
    
    var id: String {
        self.arn
    }
}
