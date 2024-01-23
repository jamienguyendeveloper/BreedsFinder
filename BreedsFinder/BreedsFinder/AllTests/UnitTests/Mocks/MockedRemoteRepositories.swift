//
//  MockedRemoteRepositories.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import Combine
import DataAccess
import Models
import Infrastructure
@testable import BreedsFinder

class TestRemoteRepository: RemoteRepository {
    let session: URLSession = .mockedResponsesOnly
    let baseURL = "https://test.com"
    let bgQueue = DispatchQueue(label: "test")
}

final class MockedBreedsRemoteRepository: TestRemoteRepository, Mock, BreedsRemoteRepository {
    
    enum Action: Equatable {
        case loadBreeds
    }
    var actions = MockActions<Action>(expected: [])
    
    var BreedsResponse: Result<[Breed], Error> = .failure(MockError.valueNotSet)
    
    func loadBreeds() -> AnyPublisher<[Breed], Error> {
        register(.loadBreeds)
        return BreedsResponse.publish()
    }
}

final class MockedImageRemoteRepository: TestRemoteRepository, Mock, ImageRemoteRepository {
    
    enum Action: Equatable {
        case loadImage(URL?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var imageResponse: Result<UIImage, Error> = .failure(MockError.valueNotSet)
    
    func loadImage(imageURL: URL) -> AnyPublisher<UIImage, Error> {
        register(.loadImage(imageURL))
        return imageResponse.publish()
    }
}
