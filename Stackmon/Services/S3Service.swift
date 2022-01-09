//
//  S3Service.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import Foundation
import SotoCore
import SotoS3

struct S3Service {
    let client: AWSClient
    let profile: Profile
    
    func createBucket(_ request: S3.CreateBucketRequest, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let operation = s3.createBucket(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func deleteBucket(_ name: String, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let operation = s3.deleteBucket(S3.DeleteBucketRequest(bucket: name))
        
        operation.whenSuccess { completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func listBuckets(completion: @escaping(_ result: Result<[S3.Bucket], Error>) -> Void) {
        let operation = s3.listBuckets()
        
        operation.whenSuccess { response in
            completion(.success(response.buckets ?? []))
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    private var s3: S3 {
        S3(client: client, region: profile.region, endpoint: "http://localhost:4566")
    }
}
