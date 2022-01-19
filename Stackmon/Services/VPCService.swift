//
//  VPCService.swift
//  Stackmon
//
//  Created by Mike Polan on 1/18/22.
//

import Foundation
import SotoEC2

struct VPCService {
    let client: AWSClient
    let region: Region
    let profile: Profile
    
    func listVPCs(completion: @escaping(_ result: Result<[VPC], Error>) -> Void) {
        let request = EC2.DescribeVpcsRequest()
        let operation = ec2.describeVpcs(request)
        
        operation.whenSuccess { result in
            let vpcs = (result.vpcs ?? []).map { vpc -> VPC in
                // the name is stored as a tag
                let name = (vpc.tags ?? []).first { $0.key == "Name" }?.value
                
                return VPC(id: vpc.vpcId ?? "",
                           name: name,
                           ipv4CidrBlock: vpc.cidrBlock,
                           ipv6CidrBlockAssociationSet: nil, // TODO
                           state: vpc.state,
                           tenancy: vpc.instanceTenancy,
                           isDefault: vpc.isDefault,
                           ownerID: vpc.ownerId)
            }
            
            completion(.success(vpcs))
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    private var ec2: EC2 {
        EC2(client: client, region: region, endpoint: "http://localhost:4566")
    }
}
