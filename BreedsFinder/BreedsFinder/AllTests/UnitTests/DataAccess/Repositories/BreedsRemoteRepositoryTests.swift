//
//  BreedsRemoteRepositoryTests.swift
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

final class BreedsRemoteRepositoryTests: XCTestCase {
    
    private var sut: BreedsRemoteRepositoryImpl!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = BreedsRemoteRepositoryImpl.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = BreedsRemoteRepositoryImpl(session: .mockedResponsesOnly,
                                         baseURL: "https://test.com")
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }

    func test_allBreeds() throws {
        let data = Breed.mockedData
        try mock(.allBreeds, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        sut.loadBreeds().resultSink { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>,
                         httpCode: HTTPCode = 200) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
}
