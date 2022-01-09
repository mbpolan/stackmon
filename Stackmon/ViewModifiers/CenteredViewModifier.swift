//
//  CenteredTextViewModifier.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SwiftUI

// MARK: View Modifier

struct CenteredViewModifier: ViewModifier {
    let axis: Axis
    
    enum Axis {
        case horizontal
        case vertical
        case all
    }
    
    func body(content: Content) -> some View {
        Group {
            switch axis {
            case .horizontal:
                HStack {
                    Spacer()
                    content
                    Spacer()
                }
            case .vertical:
                VStack {
                    Spacer()
                    content
                    Spacer()
                }
            case .all:
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        content
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
}

// MARK: Extensions

extension View {
    func centered(_ axis: CenteredViewModifier.Axis) -> some View {
        return modifier(CenteredViewModifier(axis: axis))
    }
}
