//
//  S3Object.swift
//  Stackmon
//
//  Created by Mike Polan on 3/26/22.
//

import Foundation

class S3Object: ObservableObject, Identifiable {
    @Published var key: String
    @Published var modified: Date?
    
    init(key: String, modified: Date?) {
        self.key = key
        self.modified = modified
    }
    
    public var id: String {
        key
    }
}
