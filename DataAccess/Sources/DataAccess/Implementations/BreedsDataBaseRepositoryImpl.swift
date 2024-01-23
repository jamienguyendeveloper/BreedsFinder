//
//  BreedsDataBaseRepositoryImpl.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import Combine
import Infrastructure
import Models

public struct BreedsDataBaseRepositoryImpl: BreedsDataBaseRepository {
    
    let persistentStore: PersistentStore
    
    public init(persistentStore: PersistentStore) {
        self.persistentStore = persistentStore
    }
    
    public func hasRequestedBreeds() -> AnyPublisher<Bool, Error> {
        let fetchRequest = BreedMO.justOneBreed()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }
    
    public func saveBreedsToDataBase(breeds: [Breed]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                breeds.forEach {
                    $0.store(in: context)
                }
            }
    }
    
    public func searchBreeds(search: String) -> AnyPublisher<RequestableList<Breed>, Error> {
        let fetchRequest = BreedMO.searchBreeds(search: search)
        return persistentStore
            .fetch(fetchRequest) {
                Breed(managedObject: $0)
            }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Endpoints

public extension BreedsRemoteRepositoryImpl {
    enum API {
        case allBreeds
    }
}

extension BreedsRemoteRepositoryImpl.API: APIRequest {
    
    public var path: String {
        switch self {
        case .allBreeds:
            return "/breeds"
        }
    }
    
    public var method: String {
        switch self {
        case .allBreeds:
            return "GET"
        }
    }
    
    public var headers: [String: String]? {
        return ["Accept": "application/json",
                "x-api-key" : "DEMO-API-KEY"]
    }
    
    public func requestBody() throws -> Data? {
        return nil
    }
}
