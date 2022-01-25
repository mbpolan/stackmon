//
//  Profile.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Combine
import SotoCore

class Profile: Identifiable, Hashable, Equatable, ObservableObject {
    static var `default`: Profile = Profile(name: "default")
    
    @Published var name: String
    @Published var region: Region? = .useast1
    @Published var endpoint: String = ""
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name &&
        lhs.endpoint == rhs.endpoint &&
        lhs.region == rhs.region
    }
    
    init(name: String) {
        self.name = name
    }
    
    var id: String {
        name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
