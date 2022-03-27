//
//  VPCCreateView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/18/22.
//

import SotoEC2
import SwiftUI

// MARK: - View

struct VPCCreateView: View {
    @StateObject private var viewModel: VPCCreateViewModel = VPCCreateViewModel()
    let onCommit: (_ bucket: EC2.CreateVpcRequest) -> Void
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
                        
                        Text("Tenant")
                        Picker("", selection: $viewModel.tenancy) {
                            ForEach(VPCCreateViewModel.Tenancy.allCases, id: \.self) { type in
                                Text(type.text)
                            }
                        }
                    }
                }
                .padding([.bottom], 5)
                
                Section(header: Text("IPv4 CIDR Block")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
                        Text("Method")
                        Picker("", selection: $viewModel.ipv4CidrType) {
                            ForEach(VPCCreateViewModel.IPv4CidrType.allCases, id: \.self) { type in
                                Text(type.text)
                            }
                        }
                        
                        Text("CIDR Block")
                        TextField("", text: $viewModel.ipv4CidrBlock)
                    }
                }
                .padding([.bottom], 5)
                
                Section(header: Text("IPv6 CIDR Block")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 150)),
                        GridItem(.flexible(minimum: 250)),
                    ], spacing: 10) {
                        Text("Method")
                        Picker("", selection: $viewModel.ipv6CidrType) {
                            ForEach(VPCCreateViewModel.IPv6CidrType.allCases, id: \.self) { type in
                                Text(type.text)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .frame(width: geo.size.width / 2, height: nil, alignment: .center)
            .centered(.horizontal)
        }
        .navigationSubtitle("New VPC")
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
        !viewModel.ipv4CidrBlock.isEmpty
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
        
        var ipv4CidrBlock: String?
        if viewModel.ipv4CidrType == .manual {
            ipv4CidrBlock = viewModel.ipv4CidrBlock
        }
        
        onCommit(EC2.CreateVpcRequest(cidrBlock: ipv4CidrBlock,
                                      dryRun: false,
                                      instanceTenancy: viewModel.tenancy.ec2Tenancy,
                                      tagSpecifications: tags))
    }
}

// MARK: - View Model

fileprivate class VPCCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var tenancy: Tenancy = .default
    @Published var ipv4CidrType: IPv4CidrType = .manual
    @Published var ipv4CidrBlock: String = ""
    @Published var ipv6CidrType: IPv6CidrType = .none
    
    enum Tenancy: CaseIterable {
        case `default`
        case dedicated
        
        var text: String {
            switch self {
            case .dedicated:
                return "Dedicated"
            case .default:
                return "Default"
            }
        }
        
        var ec2Tenancy: EC2.Tenancy {
            switch self {
            case .dedicated:
                return .dedicated
            case .default:
                return .default
            }
        }
    }
    
    enum IPv4CidrType: CaseIterable {
        case manual
        
        var text: String {
            switch self {
            case .manual:
                return "Manually Specify"
            }
        }
    }
    
    enum IPv6CidrType: CaseIterable {
        case none
        
        var text: String {
            switch self {
            case .none:
                return "None"
            }
        }
    }
}

// MARK: - Preview

struct VPCCreateView_Preview: PreviewProvider {
    static var previews: some View {
        VPCCreateView(onCommit: { _ in },
                      onCancel: {})
    }
}
