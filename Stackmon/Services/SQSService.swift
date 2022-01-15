//
//  SQSService.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation
import SotoSQS

struct SQSService {
    let client: AWSClient
    let region: Region
    let profile: Profile
    
    func listQueues(completion: @escaping(_ result: Result<[SQSQueue], Error>) -> Void) {
        let request = SQS.ListQueuesRequest(maxResults: 1000)
        let operation = sqs.listQueues(request)
        
        operation.whenSuccess {
            getQueueSummaries($0.queueUrls ?? [], completion: completion)
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func deleteQueue(_ queueURL: String, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let request = SQS.DeleteQueueRequest(queueUrl: queueURL)
        let operation = sqs.deleteQueue(request)
        
        operation.whenSuccess { completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func sendMessage(_ request: SQS.SendMessageRequest, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let operation = sqs.sendMessage(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func purgeQueue(_ queueURL: String, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let request = SQS.PurgeQueueRequest(queueUrl: queueURL)
        let operation = sqs.purgeQueue(request)
        
        operation.whenSuccess { completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    private var sqs: SQS {
        SQS(client: client, region: region, endpoint: "http://localhost:4566")
    }
    
    private func getQueueSummaries(_ queueURLs: [String], completion: @escaping(_ result: Result<[SQSQueue], Error>) -> Void) {
        let group = DispatchGroup()
        var results: Dictionary<String, Result<SQS.GetQueueAttributesResult, Error>> = [:]
        
        queueURLs.forEach { queueURL in
            group.enter()
            
            let request = SQS.GetQueueAttributesRequest(attributeNames: [
                SQS.QueueAttributeName.approximatenumberofmessages,
                SQS.QueueAttributeName.approximatenumberofmessagesnotvisible,
                SQS.QueueAttributeName.createdtimestamp,
            ], queueUrl: queueURL)
            
            let operation = sqs.getQueueAttributes(request)
            operation.whenSuccess {
                results[queueURL] = .success($0)
                group.leave()
            }
            
            operation.whenFailure {
                results[queueURL] = .failure($0)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            var models: [SQSQueue] = []
            
            results.forEach { (queueURL, result) in
                switch result {
                case .success(let response):
                    let numVisibleMessages = response.attributes?[SQS.QueueAttributeName.approximatenumberofmessages] ?? ""
                    let numInFlightMessages = response.attributes?[SQS.QueueAttributeName.approximatenumberofmessagesnotvisible] ?? ""
                    let createdTimestamp = response.attributes?[SQS.QueueAttributeName.createdtimestamp]
                    
                    var createdOn: Date?
                    if let createdTimestamp = createdTimestamp,
                       let timestamp = Double(createdTimestamp) {
                        createdOn = Date(timeIntervalSince1970: timestamp)
                    }
                    
                    models.append(SQSQueue(queueURL: queueURL,
                                           numVisibleMessages: Int(numVisibleMessages),
                                          numInFlightMessages: Int(numInFlightMessages),
                                          created: createdOn))
                    break
                case .failure(let error):
                    print(error)
                    models.append(SQSQueue(queueURL: queueURL))
                }
            }
            
            completion(.success(models))
        }
    }
}
