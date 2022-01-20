//
//  VPCCreateSubnetView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/19/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCCreateSubnetView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: VPCCreateSubnetViewModel = VPCCreateSubnetViewModel()
    let onCommit: (_ request: EC2.CreateSubnetRequest) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            Form {
                Section(header: Text("VPC")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
                        Text("Owning VPC")
                        Picker("", selection: $viewModel.vpc) {
                            ForEach(viewModel.vpcs, id: \.self) { vpc in
                                Text(vpc.id)
                                    .tag(vpc as VPC?)
                            }
                        }
                        
                        Text("IPv4 CIDRs")
                        Text(viewModel.vpc?.ipv4CidrBlock ?? "-")
                        
                        Text("IPv6 CIDRs")
                        Text("-")
                    }
                }
                
                Section(header: Text("Subnet")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
                        Text("Name")
                        TextField("", text: $viewModel.name)
                        
                        Text("Availability Zone")
                        Picker("", selection: $viewModel.zone) {
                            Text("No preference")
                                .tag(nil as AvailabilityZone?)
                            
                            ForEach(viewModel.zones, id: \.self) { zone in
                                Text("\(zone.id)")
                                    .tag(zone as AvailabilityZone?)
                            }
                        }
                        
                        Text("IPv4 CIDR")
                        TextField("", text: $viewModel.ipv4Cidr)
                    }
                }
                
                Spacer()
            }
            .frame(width: geo.size.width / 2, height: nil, alignment: .center)
            .centered(.horizontal)
        }
        .navigationSubtitle("New Subnet")
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
        .onAppear(perform: handleLoad)
    }
    
    private var formValid: Bool {
        true
    }
    
    private var service: VPCService? {
        guard let region = appState.region else { return nil }
        return VPCService(client: appState.client, region: region, profile: appState.profile)
    }
    
    private func handleLoad() {
        guard let service = service else { return }
        
        let group = DispatchGroup()
        viewModel.loading = true
        
        group.enter()
        service.listVPCs { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let vpcs):
                    viewModel.vpcs = vpcs
                case .failure(let error):
                    print(error)
                }
                
                group.leave()
            }
        }
        
        group.enter()
        service.listZones { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let zones):
                    viewModel.zones = zones
                case .failure(let error):
                    print(error)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            viewModel.loading = false
        }
    }
    
    private func handleConfirm() {
        guard let zone = viewModel.zone,
              let vpc = viewModel.vpc else { return }
        
        var tags: [EC2.TagSpecification]? = nil
        if !viewModel.name.isEmpty {
            tags = [
                EC2.TagSpecification(resourceType: EC2.ResourceType.vpc, tags: [
                    EC2.Tag(key: "Name", value: viewModel.name)
                ])
            ]
        }
        
        onCommit(EC2.CreateSubnetRequest(availabilityZone: zone.name,
                                         availabilityZoneId: zone.id,
                                         cidrBlock: viewModel.ipv4Cidr,
                                         tagSpecifications: tags,
                                         vpcId: vpc.id))
    }
}

// MARK: - View Model

fileprivate class VPCCreateSubnetViewModel: ObservableObject {
    @Published var loading: Bool = true
    @Published var name: String = ""
    @Published var ipv4Cidr: String = ""
    @Published var vpc: VPC?
    @Published var vpcs: [VPC] = []
    @Published var zone: AvailabilityZone?
    @Published var zones: [AvailabilityZone] = []
}

// MARK: - Preview

struct VPCCreateSubView_Preview: PreviewProvider {
    static var previews: some View {
        VPCCreateSubnetView(onCommit: { _ in },
                            onCancel: {})
    }
}
