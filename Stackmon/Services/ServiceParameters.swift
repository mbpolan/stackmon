//
//  ServiceParameters.swift
//  Stackmon
//
//  Created by Mike Polan on 1/25/22.
//

import SotoCore

struct ServiceParameters {
    let client: AWSClient
    let profile: Profile
    let region: Region?
}
