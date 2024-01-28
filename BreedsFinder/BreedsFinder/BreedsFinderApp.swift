//
//  BreedsFinderApp.swift
//  BreedsFinder
//
//  Created by Jamie on 29/01/2024.
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct BreedsFinderApp: App {
    
    init() {
        IQKeyboardManager.shared.enable = true
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                let environment = AppEnvironment.setup()
                let viewModel = AppContentView.ViewModel(container: environment.container)
                AppContentView(viewModel: viewModel)
            }
        }
    }
}
