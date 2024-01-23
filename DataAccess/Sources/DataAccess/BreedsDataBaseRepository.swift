//
//  BreedsDataBaseRepository.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import CoreData
import Combine
import Models
import Infrastructure

public protocol BreedsDataBaseRepository {
    func hasRequestedBreeds() -> AnyPublisher<Bool, Error>
    func saveBreedsToDataBase(breeds: [Breed]) -> AnyPublisher<Void, Error>
    func searchBreeds(search: String) -> AnyPublisher<RequestableList<Breed>, Error>
}
