//
//  TimeIntervalPicker.swift
//  Stackmon
//
//  Created by Mike Polan on 1/17/22.
//

import SwiftUI

// MARK: - View

struct TimeIntervalPicker: View {
    @Binding var interval: Interval
    var allowedIntervals: [Interval]? = nil
    
    var body: some View {
        Picker("", selection: $interval) {
            ForEach(intervals, id: \.self) { interval in
                Text(interval.text)
            }
        }
    }
    
    private var intervals: [Interval] {
        guard let allowedIntervals = allowedIntervals else { return Interval.allCases }
        return Interval.allCases.filter { allowedIntervals.contains($0) }
    }
}

// MARK: - Extensions

extension Interval {
    var text: String {
        switch self {
        case .seconds:
            return "Seconds"
        case .minutes:
            return "Minutes"
        case .hours:
            return "Hours"
        case .days:
            return "Days"
        }
    }
}

// MARK: - Preview

struct TimeIntervalPicker_Preview: PreviewProvider {
    @State static var interval: Interval = .seconds
    
    static var previews: some View {
        TimeIntervalPicker(interval: $interval)
    }
}
