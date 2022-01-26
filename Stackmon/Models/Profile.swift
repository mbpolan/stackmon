//
//  Profile.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Combine
import Foundation
import SotoCore

class Profile: Identifiable, Hashable, Equatable, ObservableObject {
    static var `default`: Profile = Profile(name: "default")
    
    let profileId: String = UUID().uuidString
    @Published var name: String
    @Published var region: Region? = .useast1
    @Published var endpoint: String = ""
    @Published var authenticationType: AuthenticationType = .iam
    @Published var accessKeyId: String = ""
    @Published var secretAccessKey: String = ""
    @Published var sessionToken: String = ""
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name &&
        lhs.endpoint == rhs.endpoint &&
        lhs.region == rhs.region
    }
    
    init(name: String) {
        self.name = name
    }
    
    var id: String {
        profileId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Profile {
    enum AuthenticationType: CaseIterable {
        case iam
    }
}
