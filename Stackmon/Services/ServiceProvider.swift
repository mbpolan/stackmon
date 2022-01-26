//
//  ServiceProvider.swift
//  Stackmon
//
//  Created by Mike Polan on 1/25/22.
//

import Foundation

struct ServiceProvider {
    static let shared = ServiceProvider()
    
    func s3(_ appState: AppState) -> S3Service? {
        guard let params = appState.createServiceParams(regional: false) else { return nil }
        return S3Service(client: params.client, profile: params.profile)
    }
    
    func sns(_ appState: AppState) -> SNSService? {
        guard let params = appState.createServiceParams(),
              let region = params.region else { return nil }
        
        return SNSService(client: params.client, region: region, profile: params.profile)
    }
    
    func sqs(_ appState: AppState) -> SQSService? {
        guard let params = appState.createServiceParams(),
              let region = params.region else { return nil }
        
        return SQSService(client: params.client, region: region, profile: params.profile)
    }
    
    func vpc(_ appState: AppState) -> VPCService? {
        guard let params = appState.createServiceParams(),
              let region = params.region else { return nil }
        
        return VPCService(client: params.client, region: region, profile: params.profile)
    }
}
