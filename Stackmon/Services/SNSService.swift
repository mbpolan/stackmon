//
//  SNSService.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation
import SotoSNS

struct SNSService {
    let client: AWSClient
    let region: Region
    let profile: Profile
    
    func listTopics(completion: @escaping(_ result: Result<[SNSTopic], Error>) -> Void) {
        let request = SNS.ListTopicsInput()
        let operation = sns.listTopics(request)
        
        operation.whenSuccess {
            getTopicSummaries($0.topics ?? [], completion: completion)
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func deleteTopic(_ topicARN: String, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let request = SNS.DeleteTopicInput(topicArn: topicARN)
        let operation = sns.deleteTopic(request)
        
        operation.whenSuccess { completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func publish(_ request: SNS.PublishInput, completion: @escaping(_ result: Result<Bool, Error>) -> Void) {
        let operation = sns.publish(request)
        
        operation.whenSuccess { _ in completion(.success(true)) }
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func listSubscriptions(completion: @escaping(_ result: Result<[SNSSubscription], Error>) -> Void) {
        let request = SNS.ListSubscriptionsInput()
        let operation = sns.listSubscriptions(request)
        
        operation.whenSuccess {
            let subs = $0.subscriptions ?? []
            
            completion(.success(subs.filter { $0.subscriptionArn != nil }.map { sub in
                SNSSubscription(arn: sub.subscriptionArn ?? "",
                                topicARN: sub.topicArn,
                                protocol: sub.protocol,
                                endpoint: sub.endpoint)
            }))
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    func listSubscriptions(byTopic topicARN: String, completion: @escaping(_ result: Result<[SNSSubscription], Error>) -> Void) {
        let request = SNS.ListSubscriptionsByTopicInput(topicArn: topicARN)
        let operation = sns.listSubscriptionsByTopic(request)
        
        operation.whenSuccess {
            let subs = $0.subscriptions ?? []
            
            completion(.success(subs.filter { $0.subscriptionArn != nil }.map { sub in
                SNSSubscription(arn: sub.subscriptionArn ?? "",
                                topicARN: sub.topicArn,
                                protocol: sub.protocol,
                                endpoint: sub.endpoint)
            }))
        }
        
        operation.whenFailure { completion(.failure($0)) }
    }
    
    private var sns: SNS {
        SNS(client: client, region: region, endpoint: "http://localhost:4566")
    }
    
    private enum TopicAttributeName: String {
        case displayName = "DisplayName"
        case fifoTopic = "FifoTopic"
    }
    
    private func getTopicSummaries(_ topics: [SNS.Topic], completion: @escaping(_ result: Result<[SNSTopic], Error>) -> Void) {
        let group = DispatchGroup()
        var results: Dictionary<String, Result<SNS.GetTopicAttributesResponse, Error>> = [:]
        
        topics.forEach { topic in
            guard let topicARN = topic.topicArn else { return }
            
            group.enter()
            
            let request = SNS.GetTopicAttributesInput(topicArn: topicARN)
            let operation = sns.getTopicAttributes(request)
            
            operation.whenSuccess {
                results[topicARN] = .success($0)
                group.leave()
            }
            
            operation.whenFailure {
                results[topicARN] = .failure($0)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            var models: [SNSTopic] = []
            
            results.forEach { (topicARN, result) in
                switch result {
                case .success(let response):
                    let displayName = response.attributes?[TopicAttributeName.displayName.rawValue]
                    let fifoFlag = response.attributes?[TopicAttributeName.fifoTopic.rawValue]
                    
                    var type: SNSTopic.TopicType = .standard
                    if let fifoFlag = fifoFlag,
                       let isFifo = Bool(fifoFlag) {
                        type = isFifo ? .fifo : .standard
                    }
                    
                    models.append(SNSTopic(topicARN: topicARN,
                                           name: displayName?.emptyAsNil() ?? topicARN,
                                           type: type))
                    break
                case .failure(let error):
                    print(error)
                    models.append(SNSTopic(topicARN: topicARN))
                }
            }
            
            completion(.success(models))
        }
    }
}
