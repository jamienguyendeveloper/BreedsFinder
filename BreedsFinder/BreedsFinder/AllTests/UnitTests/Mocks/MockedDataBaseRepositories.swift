//
//  MockedBreedsDataBaseRepository.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import Combine
import Models
import Infrastructure
import DataAccess
@testable import BreedsFinder

final class MockedBreedsDataBaseRepository: Mock, BreedsDataBaseRepository {
    
    enum Action: Equatable {
        case hasRequestedBreeds
        case saveBreedsToDataBase([Breed])
        case fetchBreeds(search: String)
    }
    var actions = MockActions<Action>(expected: [])
    
    var hasRequestedBreedsResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var saveBreedsToDataBaseResult: Result<Void, Error> = .failure(MockError.valueNotSet)
    var fetchBreedsResult: Result<RequestableList<Breed>, Error> = .failure(MockError.valueNotSet)
    
    func hasRequestedBreeds() -> AnyPublisher<Bool, Error> {
        register(.hasRequestedBreeds)
        return hasRequestedBreedsResult.publish()
    }
    
    func saveBreedsToDataBase(breeds: [Breed]) -> AnyPublisher<Void, Error> {
        register(.saveBreedsToDataBase(breeds))
        return saveBreedsToDataBaseResult.publish()
    }
    
    func searchBreeds(search: String) -> AnyPublisher<RequestableList<Breed>, Error> {
        register(.fetchBreeds(search: search))
        return fetchBreedsResult.publish()
    }
}
