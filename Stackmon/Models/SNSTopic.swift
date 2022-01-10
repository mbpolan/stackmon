//
//  SNSTopic.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation

class SNSTopic: Identifiable, ObservableObject {
    @Published var topicARN: String
    @Published var name: String
    @Published var type: TopicType
    
    enum TopicType {
        case standard
        case fifo
    }
    
    init(topicARN: String) {
        self.topicARN = topicARN
        self.name = topicARN
        self.type = .standard
    }
    
    init(topicARN: String, name: String, type: TopicType) {
        self.topicARN = topicARN
        self.name = name
        self.type = type
    }
    
    var id: String {
        self.topicARN
    }
}
