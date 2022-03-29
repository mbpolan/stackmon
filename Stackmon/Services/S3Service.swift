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
    
    func listBuckets(completion: @escaping(_ result: Result<[S3Bucket], Error>) -> Void) {
        let operation = s3.listBuckets()
        
        operation.whenSuccess { response in
            let buckets = response.buckets ?? []
            completion(.success(buckets.map {
                S3Bucket(name: $0.name ?? "", created: $0.creationDate)
            }))
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func listObjects(_ request: S3.ListObjectsV2Request, completion: @escaping(_ result: Result<PagedData<S3Object>, Error>) -> Void) {
        let operation = s3.listObjectsV2(request)
        
        operation.whenSuccess { response in
            completion(.success(PagedData<S3Object>(
                hasMore: response.isTruncated ?? false,
                total: nil,
                nextToken: response.continuationToken,
                data: (response.contents ?? []).map { obj in
                    S3Object(key: obj.key ?? "", modified: obj.lastModified)
                })))
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func putObject(_ request: S3.PutObjectRequest, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let operation = s3.putObject(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    private var s3: S3 {
        S3(client: client,
           region: profile.region,
           endpoint: profile.endpoint.emptyAsNil())
    }
}
