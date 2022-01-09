//
//  S3BucketDetailEditorView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SotoS3
import SwiftUI

// MARK: - View

struct S3BucketDetailEditorView: View {
    @StateObject private var viewModel: S3BucketDetailEditorViewModel = S3BucketDetailEditorViewModel()
    let onCommit: (_ bucket: S3.CreateBucketRequest) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            Form {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 150)),
                    GridItem(.flexible(minimum: 250)),
                ], spacing: 10) {
                    Text("Bucket Name")
                    TextField("", text: $viewModel.name)
                    
                    Text("Object Ownership")
                    Picker("", selection: $viewModel.objectOwnership) {
                        ForEach(S3BucketDetailEditorViewModel.ObjectOwnership.allCases, id: \.self) { ownership in
                            Text(ownership.text)
                        }
                    }
                }

                Spacer()
            }
            .frame(width: geo.size.width / 3, height: nil, alignment: .center)
            .centered(.horizontal)
        }
        .navigationSubtitle("New Bucket")
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                }
                
                Button(action: handleConfirm) {
                    Image(systemName: "checkmark")
                }
                .disabled(!formValid)
            }
        }
    }
    
    private var formValid: Bool {
        !viewModel.name.isEmpty
    }
    
    private func handleConfirm() {
        onCommit(S3.CreateBucketRequest(bucket: viewModel.name,
                                        objectOwnership: viewModel.objectOwnership.value))
    }
}

// MARK: - View Model

class S3BucketDetailEditorViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var objectOwnership: ObjectOwnership = .bucketOwnerEnforced
    
    enum ObjectOwnership: CaseIterable {
        case bucketOwnerEnforced
        case bucketOwnerPreferred
        case objectWriter
        
        var text: String {
            switch self {
            case .bucketOwnerEnforced:
                return "Bucket owner enforced"
            case .bucketOwnerPreferred:
                return "Bucket owner preferred"
            case .objectWriter:
                return "Object writer"
            }
        }
        
        var value: S3.ObjectOwnership {
            switch self {
            case .bucketOwnerEnforced:
                return .bucketownerenforced
            case .bucketOwnerPreferred:
                return .bucketownerpreferred
            case .objectWriter:
                return .objectwriter
            }
        }
        
        static func from(_ value: S3.ObjectOwnership) -> ObjectOwnership {
            switch value {
            case .bucketownerenforced:
                return .bucketOwnerEnforced
            case .bucketownerpreferred:
                return .bucketOwnerPreferred
            case .objectwriter:
                return .objectWriter
            }
        }
    }
}

// MARK: - Preview

struct S3BucketDetailEditorView_Preview: PreviewProvider {
    static var previews: some View {
        S3BucketDetailEditorView(onCommit: { _ in },
                                 onCancel: {})
            .body.previewDisplayName("Create")
    }
}
