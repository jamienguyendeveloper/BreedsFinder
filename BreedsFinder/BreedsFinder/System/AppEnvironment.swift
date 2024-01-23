//
//  AppEnvironment.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import UIKit
import Combine
import Infrastructure
import Interactors
import DataAccess
import Models

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    
    static func setup() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let appRemoteRepositories = appRemoteRepositories(session: appURLSession())
        let appDataBaseRepositories = appDataBaseRepositories(appState: appState)
        let services = appServices(appState: appState,
                                   databaseRepositories: appDataBaseRepositories,
                                   remoteRepositories: appRemoteRepositories)
        let diContainer = DIContainer(appState: appState, services: services)
        return AppEnvironment(container: diContainer)
    }
    
    private static func appURLSession() -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 60
        sessionConfiguration.timeoutIntervalForResource = 120
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.httpMaximumConnectionsPerHost = 5
        sessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
        sessionConfiguration.urlCache = .shared
        return URLSession(configuration: sessionConfiguration)
    }
    
    private static func appRemoteRepositories(session: URLSession) -> DIContainer.remoteRepositories {
        let breedsRemoteRepository = BreedsRemoteRepositoryImpl(session: session, baseURL: "https://api.thecatapi.com/v1")
        let imageRemoteRepository = ImageRemoteRepositoryImpl(session: session, baseURL: "")
        return .init(imageRemoteRepository: imageRemoteRepository,
                     breedsRemoteRepository: breedsRemoteRepository)
    }
    
    private static func appDataBaseRepositories(appState: Store<AppState>) -> DIContainer.databaseRepositories {
        let persistentStore = CoreDataPersistentStore(version: CoreDataPersistentStore.Version.actual)
        let breedsDataBaseRepository = BreedsDataBaseRepositoryImpl(persistentStore: persistentStore)
        return .init(breedsRepository: breedsDataBaseRepository)
    }
    
    private static func appServices(appState: Store<AppState>,
                                    databaseRepositories: DIContainer.databaseRepositories,
                                    remoteRepositories: DIContainer.remoteRepositories) -> DIContainer.Services {
        let breedsService = BreedsServiceImpl(remoteRepository: remoteRepositories.breedsRemoteRepository,
                                              databaseRepository: databaseRepositories.breedsRepository,
                                              applicationState: appState)
        let imagesService = ImagesServiceImpl(remoteRepository: remoteRepositories.imageRemoteRepository)
        
        return .init(breedsService: breedsService,
                     imagesService: imagesService)
    }
}

extension DIContainer {
    
    struct remoteRepositories {
        let imageRemoteRepository: ImageRemoteRepository
        let breedsRemoteRepository: BreedsRemoteRepository
    }
    
    struct databaseRepositories {
        let breedsRepository: BreedsDataBaseRepository
    }
}
