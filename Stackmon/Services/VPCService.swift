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
    
    func createVPC(_ request: EC2.CreateVpcRequest, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let operation = ec2.createVpc(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
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
    
    func deleteVPC(_ id: String, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let request = EC2.DeleteVpcRequest(dryRun: false, vpcId: id)
        let operation = ec2.deleteVpc(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func createIPAM(_ request: EC2.CreateIpamRequest, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let operation = ec2.createIpam(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func listIPAMs(completion: @escaping(_ result: Result<[IPAM], Error>) -> Void) {
        let request = EC2.DescribeIpamsRequest()
        let operation = ec2.describeIpams(request)
        
        operation.whenSuccess { result in
            let ipams = (result.ipams ?? []).map { ipam in
                IPAM(id: ipam.ipamId ?? "",
                     description: ipam.description,
                     state: ipam.state,
                     region: ipam.ipamRegion,
                     ownerID: ipam.ownerId,
                     scopeCount: ipam.scopeCount)
            }
        }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func deleteIPAM(_ id: String, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let request = EC2.DeleteIpamRequest(ipamId: id)
        let operation = ec2.deleteIpam(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    private var ec2: EC2 {
        EC2(client: client, region: region, endpoint: "http://localhost:4566")
    }
}
