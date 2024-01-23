//
//  ProcessInfo+Ext.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation

public extension ProcessInfo {
    public var isForTests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}
