//
//  AWSServices.swift
//  Stackmon
//
//  Created by Mike Polan on 1/16/22.
//

import Foundation

enum AWSSNSComponent: Hashable {
    case subscriptions
    case topics
}

enum AWSVPCComponent: Hashable {
    case ipams
    case subnets
}

enum AWSService: Hashable {
    case s3
    case sns(component: AWSSNSComponent?)
    case sqs
    case vpc(component: AWSVPCComponent?)
}
