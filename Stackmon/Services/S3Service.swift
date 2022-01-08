//
//  ClientService.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Foundation
import SotoCore
import SotoS3

struct S3Service {
    static let instance = S3Service()
    
    private let client: AWSClient
    
    init() {
        self.client = AWSClient(
            credentialProvider: .static(accessKeyId: "my", secretAccessKey: "key"),
            httpClientProvider: .createNew)
    }
    
    func listBuckets(completion: @escaping(_ result: Result<[S3.Bucket], Error>) -> Void) {
        let s3 = S3(client: client, region: .useast1)
        
        let request = s3.listBuckets()
        request.whenSuccess { response in
            completion(.success(response.buckets ?? []))
        }
        request.whenFailure { completion(.failure($0)) }
    }
}
