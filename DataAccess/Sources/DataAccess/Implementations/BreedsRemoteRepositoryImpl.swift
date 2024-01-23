//
//  BreedsRemoteRepositoryImpl.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine
import Foundation
import Models
import Infrastructure

public struct BreedsRemoteRepositoryImpl: BreedsRemoteRepository {
    
    public let session: URLSession
    public let baseURL: String
    public let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    public init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    public func loadBreeds() -> AnyPublisher<[Breed], Error> {
        return call(endpoint: API.allBreeds)
    }
}
