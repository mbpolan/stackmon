//
//  AppState.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Foundation
import SotoCore

class AppState: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var region: Region? = .useast1
    @Published var client: AWSClient?
    @Published var currentView: AWSService?
    @Published var profile: Profile? {
        didSet {
            handleUpdateClient()
        }
    }
    
    var hasNoProfiles: Bool {
        profiles.isEmpty
    }
    
    var hasNoCurrentProfile: Bool {
        profile == nil
    }
    
    func createServiceParams(regional: Bool = true) -> ServiceParameters? {
        // a client and profile must be available
        guard let client = client,
              let profile = profile else {
                  return nil
              }
        
        // if regional parameters were requested but no region is selected,
        // then bail out early
        if regional && region == nil {
            return nil
        }
        
        return ServiceParameters(client: client,
                                 profile: profile,
                                 region: region)
    }
    
    private func handleUpdateClient() {
        // shut down any existing client before creating a new one
        if let client = client {
            do {
                try client.syncShutdown()
            } catch {
                print("Failed to shutdown client: \(error)")
            }
        }
        
        guard let profile = profile else {
            client = nil
            return
        }
        
        client = AWSClient(for: profile)
    }
}
