//
//  DateFormatter.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation

extension DateFormatter {
    static var dateTimeMedium: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    static func formatListView(_ date: Date?) -> String {
        guard let date = date else {
            return "Unknown"
        }
        
        return dateTimeMedium.string(from: date)
    }
}
