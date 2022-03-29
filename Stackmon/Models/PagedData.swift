//
//  PagedData.swift
//  Stackmon
//
//  Created by Mike Polan on 3/26/22.
//

import Foundation

struct PagedData<T> {
    let hasMore: Bool
    let total: Int?
    let nextToken: String?
    let data: [T]
}
