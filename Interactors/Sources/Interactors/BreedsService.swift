//
//  BreedsService.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine
import Foundation
import Infrastructure
import Models

public protocol BreedsService {
    func refreshBreeds() -> AnyPublisher<Void, Error>
    func load(breeds: RequestableSubject<RequestableList<Breed>>, search: String)
}

public struct StubBreedsService: BreedsService {
    
    public init() {
    }
    
    public func refreshBreeds() -> AnyPublisher<Void, Error> {
        return Just<Void>.withErrorType(Error.self)
    }
    
    public func load(breeds: RequestableSubject<RequestableList<Breed>>, search: String) {
    }
}
