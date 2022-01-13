//
//  S3Bucket.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Foundation

class S3Bucket: ObservableObject, Identifiable {
    @Published var name: String
    @Published var created: Date?
    
    init(name: String, created: Date?) {
        self.name = name
        self.created = created
    }
    
    public var id: String {
        self.name
    }
}
