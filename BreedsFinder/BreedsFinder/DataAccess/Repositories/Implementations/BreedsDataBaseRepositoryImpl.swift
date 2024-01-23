//
//  BreedsDataBaseRepositoryImpl.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import Combine

struct BreedsDataBaseRepositoryImpl: BreedsDataBaseRepository {
    
    let persistentStore: PersistentStore
    
    func hasRequestedBreeds() -> AnyPublisher<Bool, Error> {
        let fetchRequest = BreedMO.justOneBreed()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }
    
    func saveBreedsToDataBase(breeds: [Breed]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                breeds.forEach {
                    $0.store(in: context)
                }
            }
    }
    
    func searchBreeds(search: String) -> AnyPublisher<RequestableList<Breed>, Error> {
        let fetchRequest = BreedMO.searchBreeds(search: search)
        return persistentStore
            .fetch(fetchRequest) {
                Breed(managedObject: $0)
            }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Endpoints

extension BreedsRemoteRepositoryImpl {
    enum API {
        case allBreeds
    }
}

extension BreedsRemoteRepositoryImpl.API: APIRequest {
    var path: String {
        switch self {
        case .allBreeds:
            return "/breeds"
        }
    }
    var method: String {
        switch self {
        case .allBreeds:
            return "GET"
        }
    }
    var headers: [String: String]? {
        return ["Accept": "application/json",
                "x-api-key" : "DEMO-API-KEY"]
    }
    func requestBody() throws -> Data? {
        return nil
    }
}
