//
//  S3BucketListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SotoS3
import SwiftUI

struct S3ServiceView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: S3BucketListViewModel = S3BucketListViewModel()
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 150)),
                GridItem(.flexible(minimum: 150)),
            ]) {
                Text("Bucket Name")
                Text("Created On")
                
                ForEach(viewModel.buckets) { bucket in
                    Text(bucket.name ?? "")
                    Text("Date")
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $viewModel.sheetShown, onDismiss: handleCloseSheet) {
            switch viewModel.sheet {
            case .error(let error):
                Text("An error occured: \(error.localizedDescription)")
            default:
                Text("An unknown error has occured")
            }
        }
        .onAppear(perform: handleLoad)
    }
    
    private var service: S3Service {
        return S3Service(client: appState.client, profile: appState.profile)
    }
    
    private func handleLoad() {
        service.listBuckets(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let buckets):
                    viewModel.buckets = buckets
                case .failure(let error):
                    print(error)
                    viewModel.sheetShown = true
                    viewModel.sheet = .error(error)
                }
            }
        })
    }
    
    private func handleCloseSheet() {
        viewModel.sheet = nil
        viewModel.sheetShown = false
    }
}

class S3BucketListViewModel: ObservableObject {
    @Published var buckets: [S3.Bucket] = []
    @Published var sheet: Sheet?
    @Published var sheetShown: Bool = false
    
    enum Sheet {
        case error(_ error: Error)
    }
}

extension S3.Bucket: Identifiable {
    public var id: String {
        self.name ?? ""
    }
}
