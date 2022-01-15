//
//  NSBezierPath.swift
//  Stackmon
//
//  Created by Mike Polan on 1/14/22.
//

import Foundation
import AppKit

extension NSBezierPath {
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    // create a bezier path containing a shape with rounded corners
    convenience init(_ rect: CGRect, byRoundingCorners corners: [Corner], cornerRadius: CGFloat) {
        self.init()
        let path = CGMutablePath()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        if corners.contains(.topLeft) {
            path.move(to: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y))
        } else {
            path.move(to: topLeft)
        }
        
        if (corners.contains(.topRight)) {
            path.addLine(to: CGPoint(x: topRight.x - cornerRadius, y: topRight.y))
            path.addCurve(to: CGPoint(x: topRight.x, y: topRight.y),
                          control1: CGPoint(x: topRight.x, y: topRight.y + cornerRadius),
                          control2: CGPoint(x: topRight.x, y: topRight.y + cornerRadius))
        } else {
            path.addLine(to: topRight)
        }
        
        if (corners.contains(.bottomRight)) {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadius))
            path.addCurve(to: CGPoint(x: bottomRight.x, y: bottomRight.y),
                          control1: CGPoint(x: bottomRight.x - cornerRadius, y: bottomRight.y),
                          control2: CGPoint(x: bottomRight.x - cornerRadius, y: bottomRight.y))
        } else {
            path.addLine(to: bottomRight)
        }
        
        if (corners.contains(.bottomLeft)) {
            path.addLine(to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y),
                          control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerRadius),
                          control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerRadius))
        } else {
            path.addLine(to: bottomLeft)
        }
        
        if (corners.contains(.topLeft)) {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadius))
            path.addCurve(to: CGPoint(x: topLeft.x, y: topLeft.y),
                          control1: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y),
                          control2: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y))
        } else {
            path.addLine(to: topLeft)
        }
        
        path.closeSubpath()
        
        path.applyWithBlock { ptr in
            let el = ptr.pointee
            let points = el.points
            
            switch el.type {
            case .moveToPoint:
                self.move(to: points.pointee)
            case .addLineToPoint:
                self.line(to: points.pointee)
            case .addCurveToPoint:
                let controlPoint1 = points.pointee
                let controlPoint2 = points.advanced(by: 1).pointee
                let target = points.advanced(by: 2).pointee
                
                self.curve(to: target,
                           controlPoint1: controlPoint1,
                           controlPoint2: controlPoint2)
            case .closeSubpath:
                self.close()
            default:
                fatalError("Unsupported CGPath operation: \(el.type)")
            }
        }
    }
    
    // create a CGPath from this bezier path
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points: [CGPoint] = .init(repeating: .zero, count: 3)
        
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            default:
                fatalError("Unsupported bezier operation: \(type)")
            }
        }
        
        return path
    }
}
