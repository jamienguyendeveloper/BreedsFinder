//
//  StubBreedsService.swift
//  
//
//  Created by Jamie on 29/01/2024.
//

import Foundation
import Combine
import Infrastructure
import Models

public struct StubBreedsService: BreedsService {
    
    public init() {
    }
    
    public func refreshBreeds() -> AnyPublisher<Void, Error> {
        return Just<Void>.withErrorType(Error.self)
    }
    
    public func load(breeds: RequestableSubject<RequestableList<Breed>>, search: String) {
    }
}
