//
//  AppState.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine

public struct AppState: Equatable {
    var userData = UserData()
    public var system = System()
    
    public init() {
    }
}

extension AppState {
    struct UserData: Equatable {
    }
}

public extension AppState {
    struct System: Equatable {
        public var isActive: Bool = false
        public var keyboardHeight: CGFloat = 0
    }
}

public extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isActive = true
        return state
    }
}
