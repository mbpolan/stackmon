//
//  S3Bucket.swift
//  Stackmon
//
//  Created by Mike Polan on 1/8/22.
//

import SotoS3

// use existing s3 bucket model with extensions to support usage in lists
extension S3.Bucket: Identifiable {
    public var id: String {
        self.name ?? ""
    }
}
