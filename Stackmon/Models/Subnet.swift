//
//  Subnet.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import Combine
import SotoEC2

class Subnet: ObservableObject {
    @Published var id: String
    @Published var name: String?
    @Published var state: EC2.SubnetState?
    @Published var vpcID: String?
    @Published var ipv4Cidr: String?
    @Published var ipv6Cidr: String?
    
    init(id: String, name: String?, state: EC2.SubnetState?, vpcID: String?,
         ipv4Cidr: String?, ipv6Cidr: String?) {
        self.id = id
        self.name = name
        self.state = state
        self.vpcID = vpcID
        self.ipv4Cidr = ipv4Cidr
        self.ipv6Cidr = ipv6Cidr
    }
}
