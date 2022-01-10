//
//  S3BucketListView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoS3
import SwiftUI

// MARK: - View

struct S3BucketListView: View {
    @StateObject private var viewModel: S3BucketListViewModel = S3BucketListViewModel()
    @Binding var buckets: [S3.Bucket]
    let hasNoBuckets: Bool
    let onAdd: () -> Void
    let onDelete: (_ bucket: S3.Bucket) -> Void
    
    var body: some View {
        VStack {
            if hasNoBuckets {
                Text("There are no buckets")
                    .foregroundColor(Color.secondary)
                    .padding()
                    .centered(.all)
            } else {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 150), spacing: 0),
                            GridItem(.flexible(minimum: 150), spacing: 0),
                        ], spacing: 0) {
                            Text("Bucket Name")
                                .bold()
                                .padding([.leading, .top, .bottom], 3)
                            Text("Created On")
                                .bold()
                                .padding([.trailing, .top, .bottom], 3)
                            
                            ForEach(buckets) { bucket in
                                S3BucketListCellView(text: bucket.name ?? "",
                                                     onTapGesture: { handleSelection(bucket) },
                                                     onDelete: { onDelete(bucket) })
                                    .background(viewModel.selection == bucket.name ? Color.accentColor : nil)
                                
                                S3BucketListCellView(text: DateFormatter.formatListView(bucket.creationDate),
                                                     onTapGesture: { handleSelection(bucket) },
                                                     onDelete: { onDelete(bucket) })
                                    .background(viewModel.selection == bucket.name ? Color.accentColor : nil)
                            }
                        }
                    }
                    .padding(5)
                }
            }
        }
        .navigationSubtitle("Buckets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: handleRefresh) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
        }
    }
    
    private func handleSelection(_ bucket: S3.Bucket) {
        guard let name = bucket.name else { return }
        viewModel.selection = name
    }
    
    private func handleRefresh() {
        RefreshViewNotification().notify()
    }
}

// MARK: - Cell View

fileprivate struct S3BucketListCellView: View {
    let text: String
    let onTapGesture: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .padding(4)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Delete", action: onDelete)
        }
        .onTapGesture(perform: onTapGesture)
    }
}

// MARK: - View Model

class S3BucketListViewModel: ObservableObject {
    @Published var selection: String?
}

// MARK: - Preview

struct S3BucketListView_Preview: PreviewProvider {
    @State private static var buckets: [S3.Bucket] = [
        S3.Bucket(creationDate: Date(), name: "test-bucket")
    ]
    
    static var previews: some View {
        S3BucketListView(buckets: $buckets,
                         hasNoBuckets: false,
                         onAdd: { },
                         onDelete: { _ in })
    }
}
