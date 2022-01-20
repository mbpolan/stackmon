//
//  VPCCreateIPAMView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCCreateIPAMView: View {
    @StateObject private var viewModel: VPCCreateIPAMViewModel = VPCCreateIPAMViewModel()
    let onCommit: (_ request: EC2.CreateIpamRequest) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            Form {
                Section(header: Text("Basic")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
                        Text("Name")
                        TextField("", text: $viewModel.name)
                        
                        Text("Description")
                        TextField("", text: $viewModel.description)
                    }
                }
                
                Section(header: Text("Operating Regions")) {
                    ForEach(operatingRegions, id: \.self) { region in
                        Toggle("\(region.rawValue) (\(region.localLocation))", isOn: binding(for: region))
                    }
                }
                
                Spacer()
            }
            .frame(width: geo.size.width / 2, height: nil, alignment: .center)
            .centered(.horizontal)
        }
        .navigationSubtitle("New IPAM")
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                }
                
                Button(action: handleConfirm) {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    private var formValid: Bool {
        !viewModel.operatingRegions.isEmpty && viewModel.operatingRegions.first { $0.value } != nil
    }
    
    private var operatingRegions: [Region] {
        [
            .apnortheast1,
            .apnortheast2,
            .apnortheast3,
            .apsouth1,
            .apsoutheast1,
            .apsoutheast2,
            .cacentral1,
            .eucentral1,
            .eunorth1,
            .euwest1,
            .euwest2,
            .euwest3,
            .saeast1,
            .useast1,
            .useast2,
            .uswest1,
            .uswest2
        ]
    }
    
    private func handleConfirm() {
        var tags: [EC2.TagSpecification]? = nil
        if !viewModel.name.isEmpty {
            tags = [
                EC2.TagSpecification(resourceType: EC2.ResourceType.vpc, tags: [
                    EC2.Tag(key: "Name", value: viewModel.name)
                ])
            ]
        }
        
        let operatingRegions: [EC2.AddIpamOperatingRegion] = viewModel.operatingRegions.compactMap { (region, enabled) in
            guard enabled else { return nil }
            return EC2.AddIpamOperatingRegion(regionName: region.rawValue)
        }
        
        onCommit(EC2.CreateIpamRequest(description: viewModel.description,
                                       operatingRegions: operatingRegions,
                                       tagSpecifications: tags))
    }
    
    private func binding(for region: Region) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                return viewModel.operatingRegions[region, default: false]
            },
            set: { value in
                viewModel.operatingRegions[region] = value
            }
        )
    }
}

// MARK: - View Model

fileprivate class VPCCreateIPAMViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var operatingRegions: [Region: Bool] = [:]
}

// MARK: - Preview

struct VPCCreateIPAMView_Preview: PreviewProvider {
    static var previews: some View {
        VPCCreateIPAMView(onCommit: { _ in },
                          onCancel: {})
    }
}
