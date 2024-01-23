//
//  BreedsDataBaseRepositoryTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import Combine
import DataAccess
import Infrastructure
import Models
@testable import BreedsFinder

class BreedsDataBaseRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: BreedsDataBaseRepositoryImpl!
    var cancellableBag = CancellableBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = BreedsDataBaseRepositoryImpl(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancellableBag = CancellableBag()
        sut = nil
        mockedStore = nil
    }
}
    
final class _BreedsDataBaseRepositoryTests: BreedsDataBaseRepositoryTests {

    func test_hasRequestedBreeds() {
        mockedStore.actions = .init(expected: [
            .count,
            .count
        ])
        let exp = XCTestExpectation(description: #function)
        mockedStore.countResult = 0
        sut.hasRequestedBreeds()
            .flatMap { value -> AnyPublisher<Bool, Error> in
                XCTAssertFalse(value)
                self.mockedStore.countResult = 10
                return self.sut.hasRequestedBreeds()
            }
            .resultSink { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .insert(in: cancellableBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_storeBreeds() {
        let Breeds = Breed.mockedData
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: Breeds.count, updated: 0, deleted: 0))
        ])
        let exp = XCTestExpectation(description: #function)
        sut.saveBreedsToDataBase(breeds: Breeds)
            .resultSink { result in
                result.assertSuccess()
                self.mockedStore.verify()
                exp.fulfill()
            }
            .insert(in: cancellableBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_fetchAllBreeds() throws {
        let Breeds = Breed.mockedData
        let sortedBreeds = Breeds.sorted(by: { $0.name < $1.name })
        mockedStore.actions = .init(expected: [
            .fetchBreeds(.init(inserted: 0, updated: 0, deleted: 0))
        ])
        try mockedStore.preloadData { context in
            Breeds.forEach { $0.store(in: context) }
        }
        let exp = XCTestExpectation(description: #function)
        sut
            .searchBreeds(search: "")
            .resultSink { result in
                result.assertSuccess(value: sortedBreeds.requestableList)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .insert(in: cancellableBag)
        wait(for: [exp], timeout: 0.5)
    }
}

extension Breed: PrefixRemovable { }
