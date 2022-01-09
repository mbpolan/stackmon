//
//  String.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import Foundation

extension String {
    func emptyAsNil() -> String? {
        if self.isEmpty {
            return nil
        }
        
        return self
    }
}
