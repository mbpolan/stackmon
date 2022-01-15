//
//  Region.swift
//  Stackmon
//
//  Created by Mike Polan on 1/14/22.
//

import SotoCore
import Network

extension Region: CaseIterable, Hashable, Identifiable {
    // enumerate all regions
    public static var allCases: [Region] {
        [
            Region.afsouth1,
            Region.apeast1,
            Region.apnortheast1,
            Region.apnortheast2,
            Region.apnortheast3,
            Region.apsouth1,
            Region.apsoutheast1,
            Region.apsoutheast2,
            Region.cacentral1,
            Region.cnnorth1,
            Region.cnnorthwest1,
            Region.eucentral1,
            Region.eunorth1,
            Region.eusouth1,
            Region.euwest1,
            Region.euwest2,
            Region.euwest3,
            Region.mesouth1,
            Region.saeast1,
            Region.useast1,
            Region.useast2,
            Region.usgoveast1,
            Region.usgovwest1,
            Region.usisoeast1,
            Region.usisowest1,
            Region.usisobeast1,
            Region.uswest1,
            Region.uswest2
        ]
    }
    
    public var id: String { self.rawValue }
    
    var globalLocation: String {
        switch self {
        case .afsouth1:
            return "Africa"
        case .apeast1:
            return "Asia Pacific"
        case .apnortheast1:
            return "Asia Pacific"
        case .apnortheast2:
            return "Asia Pacific"
        case .apnortheast3:
            return "Asia Pacific"
        case .apsouth1:
            return "Asia Pacific"
        case .apsoutheast1:
            return "Asia Pacific"
        case .apsoutheast2:
            return "Asia Pacific"
        case .cacentral1:
            return "Canada"
        case .cnnorth1:
            return "China"
        case .cnnorthwest1:
            return "China"
        case .eucentral1:
            return "Europe"
        case .eunorth1:
            return "Europe"
        case .eusouth1:
            return "Europe"
        case .euwest1:
            return "Europe"
        case .euwest2:
            return "Europe"
        case .euwest3:
            return "Europe"
        case .mesouth1:
            return "Middle East"
        case .saeast1:
            return "South America"
        case .useast1:
            return "US East"
        case .useast2:
            return "US East"
        case .usgoveast1:
            return "AWS GovCloud"
        case .usgovwest1:
            return "AWS GovCloud"
        case .usisoeast1:
            return "US ISO"
        case .usisowest1:
            return "US ISO"
        case .usisobeast1:
            return "US ISOB East"
        case .uswest1:
            return "US West"
        case .uswest2:
            return "US West"
        default:
            return "Unknown"
        }
    }
    
    var localLocation: String {
        switch self {
        case .afsouth1:
            return "Cape Town"
        case .apeast1:
            return "Hong Kong"
        case .apnortheast1:
            return "Tokyo"
        case .apnortheast2:
            return "Seoul"
        case .apnortheast3:
            return "Osaka"
        case .apsouth1:
            return "Mumbai"
        case .apsoutheast1:
            return "Singapore"
        case .apsoutheast2:
            return "Sydney"
        case .cacentral1:
            return "Central"
        case .cnnorth1:
            return "Beijing"
        case .cnnorthwest1:
            return "Ningxia"
        case .eucentral1:
            return "Frankfurt"
        case .eunorth1:
            return "Stockholm"
        case .eusouth1:
            return "Milan"
        case .euwest1:
            return "Ireland"
        case .euwest2:
            return "London"
        case .euwest3:
            return "Paris"
        case .mesouth1:
            return "Bahrain"
        case .saeast1:
            return "Sao Paulo"
        case .useast1:
            return "N. Virginia"
        case .useast2:
            return "Ohio"
        case .usgoveast1:
            return "US-East"
        case .usgovwest1:
            return "US-West"
        case .usisoeast1:
            return "N. Virginia"
        case .usisowest1:
            return "Oregon"
        case .usisobeast1:
            return "Ohio"
        case .uswest1:
            return "N. California"
        case .uswest2:
            return "Oregon"
        default:
            return "Unknown"
        }
    }
}
