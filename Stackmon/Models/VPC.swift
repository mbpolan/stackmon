//
//  VPC.swift
//  Stackmon
//
//  Created by Mike Polan on 1/18/22.
//

import Combine
import SotoEC2

class VPC: ObservableObject {
    @Published var id: String
    @Published var name: String?
    @Published var ipv4CidrBlock: String?
    @Published var ipv6CidrBlockAssociationSet: String?
    @Published var state: EC2.VpcState?
    @Published var tenancy: EC2.Tenancy?
    @Published var isDefault: Bool?
    @Published var ownerID: String?
    
    init(id: String, name: String?, ipv4CidrBlock: String?, ipv6CidrBlockAssociationSet: String?,
         state: EC2.VpcState?, tenancy: EC2.Tenancy?, isDefault: Bool?, ownerID: String?) {
        
        self.id = id
        self.name = name
        self.ipv4CidrBlock = ipv4CidrBlock
        self.ipv6CidrBlockAssociationSet = ipv6CidrBlockAssociationSet
        self.state = state
        self.tenancy = tenancy
        self.isDefault = isDefault
        self.ownerID = ownerID
    }
}
