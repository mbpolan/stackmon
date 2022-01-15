//
//  AWSRegionPicker.swift
//  Stackmon
//
//  Created by Mike Polan on 1/14/22.
//

import SwiftUI
import SotoCore

// MARK: - View

struct AWSRegionPicker: View {
    @Binding var region: Region?
    var allowedRegions: [Region] = Region.allCases
    
    var body: some View {
        Picker("", selection: $region) {
            Text("Global")
                .tag(nil as Region?)
            
            ForEach(regions) { region in
                Text("\(region.rawValue) (\(region.localLocation))")
                    .tag(region as Region?)
            }
        }
        .frame(width: 200)
    }
    
    private var regions: [Region] {
        Region.allCases.filter { allowedRegions.contains($0) }
    }
}

// MARK: - Preview

struct AWSRegionPicker_Preview: PreviewProvider {
    @State static var region: Region? = .useast1
    @State static var global: Region?
    
    static var previews: some View {
        AWSRegionPicker(region: $region)
            .previewDisplayName("Selected Region")
        
        AWSRegionPicker(region: $global)
            .previewDisplayName("Global")
    }
}
