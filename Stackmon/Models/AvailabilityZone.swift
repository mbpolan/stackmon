//
//  AvailabilityZone.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import Foundation

class AvailabilityZone: Hashable, ObservableObject {
    @Published var id: String
    @Published var name: String
    
    static func == (lhs: AvailabilityZone, rhs: AvailabilityZone) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
