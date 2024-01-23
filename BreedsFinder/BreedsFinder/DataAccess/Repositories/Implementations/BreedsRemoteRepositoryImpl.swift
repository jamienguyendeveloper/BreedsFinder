//
//  BreedsRemoteRepositoryImpl.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine
import Foundation

struct BreedsRemoteRepositoryImpl: BreedsRemoteRepository {
    
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func loadBreeds() -> AnyPublisher<[Breed], Error> {
        return call(endpoint: API.allBreeds)
    }
}
