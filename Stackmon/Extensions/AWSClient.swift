//
//  AWSClient.swift
//  Stackmon
//
//  Created by Mike Polan on 1/25/22.
//

import SotoCore

extension AWSClient {
    convenience init(for profile: Profile) {
        var credentialProvider: CredentialProviderFactory
        
        switch profile.authenticationType {
        case .iam:
            credentialProvider = .static(accessKeyId: profile.accessKeyId,
                                          secretAccessKey: profile.secretAccessKey,
                                          sessionToken: profile.sessionToken)
        }
        
        self.init(credentialProvider: credentialProvider,
                  httpClientProvider: .createNew)
    }
}
