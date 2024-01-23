//
//  BreedsRemoteRepository.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine
import Foundation
import Infrastructure
import Models

public protocol BreedsRemoteRepository: RemoteRepository {
    func loadBreeds() -> AnyPublisher<[Breed], Error>
}
