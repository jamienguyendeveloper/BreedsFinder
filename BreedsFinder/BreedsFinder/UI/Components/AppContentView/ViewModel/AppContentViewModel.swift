//
//  ContentViewModel.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine

extension AppContentView {
    class ViewModel: ObservableObject {
        
        let container: DIContainer
        let isForTests: Bool
        
        init(container: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isForTests) {
            self.container = container
            self.isForTests = isRunningTests
        }
    }
}
