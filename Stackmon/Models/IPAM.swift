//
//  IPAM.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import Combine
import SotoEC2

class IPAM: ObservableObject {
    @Published var id: String
    @Published var description: String?
    @Published var state: EC2.IpamState?
    @Published var region: String?
    @Published var ownerID: String?
    @Published var scopeCount: Int?
    
    init(id: String, description: String?, state: EC2.IpamState?, region: String?,
         ownerID: String?, scopeCount: Int?) {
        self.id = id
        self.description = description
        self.state = state
        self.region = region
        self.ownerID = ownerID
        self.scopeCount = scopeCount
    }
}
