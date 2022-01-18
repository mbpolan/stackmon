//
//  Interval.swift
//  Stackmon
//
//  Created by Mike Polan on 1/17/22.
//

import Foundation

enum Interval: CaseIterable {
    case seconds
    case minutes
    case hours
    case days
    
    func toSeconds(_ value: Int) -> Int {
        switch self {
        case .seconds:
            return value
        case .minutes:
            return value * 60
        case .hours:
            return value * 60 * 60
        case .days:
            return value * 60 * 60 * 24
        }
    }
}
