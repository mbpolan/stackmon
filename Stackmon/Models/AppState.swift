//
//  AppState.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Foundation
import SotoCore

class AppState: ObservableObject, Equatable, Codable {
    @Published var profiles: [Profile] = []
    @Published var region: Region? = .useast1
    @Published var client: AWSClient? {
        willSet {
            handleShutdownClient(client)
        }
    }
    @Published var currentView: AWSService?
    @Published var profile: Profile? {
        didSet {
            handleUpdateProfile()
        }
    }
    
    enum CodingKeys: CodingKey {
        case profiles
        case region
        case currentView
        case profile
    }
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        // ignore the client since it can change over time
        return lhs.profiles == rhs.profiles &&
        lhs.region == rhs.region &&
        lhs.currentView == rhs.currentView &&
        lhs.profile == rhs.profile
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        profiles = try container.decode([Profile].self, forKey: .profiles)
        region = try container.decodeIfPresent(Region.self, forKey: .region)
        currentView = try container.decodeIfPresent(AWSService.self, forKey: .currentView)
        profile = try container.decodeIfPresent(Profile.self, forKey: .profile)
    }
    
    deinit {
        handleShutdownClient(client)
    }
    
    var hasNoProfiles: Bool {
        profiles.isEmpty
    }
    
    var hasNoCurrentProfile: Bool {
        profile == nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(profiles, forKey: .profiles)
        try container.encode(region, forKey: .region)
        try container.encode(currentView, forKey: .currentView)
        try container.encode(profile, forKey: .profile)
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
    
    private func handleShutdownClient(_ client: AWSClient?) {
        // shut down any existing client before creating a new one
        if let client = client {
            do {
                try client.syncShutdown()
            } catch {
                print("Failed to shutdown client: \(error)")
            }
        }
    }
    
    private func handleUpdateProfile() {
        guard let profile = profile else {
            client = nil
            return
        }
        
        client = AWSClient(for: profile)
    }
}

extension AppState {
    func save() {
        perform(action: {
            let data = try JSONEncoder().encode(self)
            try data.write(to: try self.getStateLocation())
        }, completion: { result in
            switch result {
            case .failure(let error):
                print("Failed to save app state: \(error)")
            default:
                break
            }
        })
    }
    
    func load() {
        perform(action: { () -> AppState in
            let data = try Data(contentsOf: try self.getStateLocation())
            return try JSONDecoder().decode(AppState.self, from: data)
        }, completion: { result in
            switch result {
            case .success(let appState):
                self.profiles = appState.profiles
                self.region = appState.region
                self.currentView = appState.currentView
                self.profile = appState.profile
                
            case .failure(let error):
                print("Failed to load app state: \(error)")
            }
        })
    }
    
    private func getStateLocation() throws -> URL {
        let url = try FileManager.default.url(for: .documentDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil,
                                                 create: false)
        
        return url.appendingPathComponent("stackmon.json")
    }
    
    private func perform<T>(action: @escaping() throws -> T, completion: @escaping(_ result: Result<T, Error>) -> Void) {
        DispatchQueue.main.async {
            do {
                completion(.success(try action()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
