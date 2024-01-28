//
//  Result+Ext.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation

public extension Result {
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
