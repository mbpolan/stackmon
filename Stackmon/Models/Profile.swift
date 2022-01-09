//
//  Profile.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Combine
import SotoCore

class Profile: ObservableObject {
    @Published var region: Region = .useast1
    
    static var `default`: Profile = Profile()
}
