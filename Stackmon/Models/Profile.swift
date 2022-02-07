//
//  Profile.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Combine
import Foundation
import SotoCore

class Profile: Identifiable, Hashable, Equatable, ObservableObject, Codable {
    static var `default`: Profile = Profile(name: "default")
    
    let profileId: String = UUID().uuidString
    @Published var name: String
    @Published var region: Region? = .useast1
    @Published var endpoint: String = ""
    @Published var authenticationType: AuthenticationType = .iam
    @Published var accessKeyId: String = ""
    @Published var secretAccessKey: String = ""
    @Published var sessionToken: String = ""
    
    enum CodingKeys: CodingKey {
        case name
        case region
        case endpoint
        case authenticationType
        case accessKeyId
        case secretAccessKey
        case sessionToken
    }
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name &&
        lhs.endpoint == rhs.endpoint &&
        lhs.region == rhs.region
    }
    
    init(name: String) {
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        region = try container.decodeIfPresent(Region.self, forKey: .region)
        endpoint = try container.decode(String.self, forKey: .endpoint)
        authenticationType = try container.decode(AuthenticationType.self, forKey: .authenticationType)
        accessKeyId = try container.decode(String.self, forKey: .accessKeyId)
        secretAccessKey = try container.decode(String.self, forKey: .secretAccessKey)
        sessionToken = try container.decode(String.self, forKey: .sessionToken)
    }
    
    var id: String {
        profileId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(region, forKey: .region)
        try container.encode(endpoint, forKey: .endpoint)
        try container.encode(authenticationType, forKey: .authenticationType)
        try container.encode(accessKeyId, forKey: .accessKeyId)
        try container.encode(secretAccessKey, forKey: .secretAccessKey)
        try container.encode(sessionToken, forKey: .sessionToken)
    }
}

extension Profile {
    enum AuthenticationType: CaseIterable, Codable {
        case iam
    }
}
