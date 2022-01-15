//
//  RoundedSpan.swift
//  Stackmon
//
//  Created by Mike Polan on 1/14/22.
//

import AppKit
import SwiftUI

// MARK: - Shape

fileprivate struct RoundedBezierRectangle: Shape {
    let radius: CGFloat
    let corners: [NSBezierPath.Corner]
    
    func path(in rect: CGRect) -> Path {
        return Path(NSBezierPath(rect, byRoundingCorners: corners, cornerRadius: radius).cgPath)
    }
}

// MARK: - Extension

extension View {
    func roundedSpan(_ radius: CGFloat, first: Bool, last: Bool) -> some View {
        // round corners based on the first and last index
        var corners: [NSBezierPath.Corner] = []
        if first {
            corners.append(contentsOf: [.topLeft, .bottomLeft])
        }
        
        if last {
            corners.append(contentsOf: [.topRight, .bottomRight])
        }
        
        return clipShape(RoundedBezierRectangle(radius: radius, corners: corners))
    }
}
