//
//  NoRegionMessageView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/14/22.
//

import SwiftUI

// MARK: - View

struct NoRegionPlaceholderView: View {
    var body: some View {
        Text("Choose a region to view service information")
            .foregroundColor(Color.secondary)
            .centered(.all)
    }
}

// MARK: - Preview

struct NoRegionPlaceholderView_Preview: PreviewProvider {
    static var previews: some View {
        NoRegionPlaceholderView()
    }
}
