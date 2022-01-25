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
    @Published var client: AWSClient = AWSClient(credentialProvider: .static(accessKeyId: "test", secretAccessKey: "test"),
                                                 httpClientProvider: .createNew)
    @Published var profile: Profile = .default
    @Published var currentView: AWSService?
}
