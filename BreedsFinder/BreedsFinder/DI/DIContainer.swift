//
//  DIContainer.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Interactors
import Infrastructure

extension DIContainer {
    struct Services {
        let breedsService: BreedsService
        let imagesService: ImagesService
        
        init(breedsService: BreedsService,
             imagesService: ImagesService) {
            self.breedsService = breedsService
            self.imagesService = imagesService
        }
        
        static var stub: Self {
            .init(breedsService: StubBreedsService(),
                  imagesService: StubImagesService())
        }
    }
}


struct DIContainer: EnvironmentKey {
    
    let appState: Store<AppState>
    let services: Services
    
    static var defaultValue: Self { Self.default }
    
    private static let `default` = DIContainer(appState: AppState(), services: .stub)
    
    init(appState: Store<AppState>, services: DIContainer.Services) {
        self.appState = appState
        self.services = services
    }
    
    init(appState: AppState, services: DIContainer.Services) {
        self.init(appState: Store(appState), services: services)
    }
}

extension DIContainer {
    static var preview: Self {
        .init(appState: AppState.preview, services: .stub)
    }
}
