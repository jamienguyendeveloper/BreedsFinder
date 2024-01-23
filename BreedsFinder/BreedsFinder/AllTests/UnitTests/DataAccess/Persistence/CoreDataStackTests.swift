//
//  CoreDataStackTests.swift
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

class CoreDataStackTests: XCTestCase {
    
    var sut: CoreDataPersistentStore!
    let testDirectory: FileManager.SearchPathDirectory = .cachesDirectory
    var databaseVersion: UInt { fatalError("Override") }
    var cancellableBag = CancellableBag()
    
    override func setUp() {
        eraseDataBaseFiles()
        sut = CoreDataPersistentStore(directory: testDirectory, version: databaseVersion)
    }
    
    override func tearDown() {
        cancellableBag = CancellableBag()
        sut = nil
        eraseDataBaseFiles()
    }
    
    func eraseDataBaseFiles() {
        let version = CoreDataPersistentStore.Version(databaseVersion)
        if let url = version.databaseFileURL(testDirectory, .userDomainMask) {
            try? FileManager().removeItem(at: url)
        }
    }
}

// MARK: - Version 1

final class CoreDataStackV1Tests: CoreDataStackTests {
    
    override var databaseVersion: UInt { 1 }

    func test_initialization() {
        let exp = XCTestExpectation(description: #function)
        let request = BreedMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        request.fetchLimit = 1
        sut.fetch(request) { _ -> Int? in
            return nil
        }
        .resultSink { result in
            result.assertSuccess(value: RequestableList<Int>.empty)
            exp.fulfill()
        }
        .insert(in: cancellableBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_inaccessibleDirectory() {
        let sut = CoreDataPersistentStore(directory: .adminApplicationDirectory,
                                domainMask: .systemDomainMask, version: databaseVersion)
        let exp = XCTestExpectation(description: #function)
        let request = BreedMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        request.fetchLimit = 1
        sut.fetch(request) { _ -> Int? in
            return nil
        }
        .resultSink { result in
            result.assertFailure()
            exp.fulfill()
        }
        .insert(in: cancellableBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_counting_onEmptyStore() {
        let request = BreedMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        let exp = XCTestExpectation(description: #function)
        sut.count(request)
        .resultSink { result in
            result.assertSuccess(value: 0)
            exp.fulfill()
        }
        .insert(in: cancellableBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_saving_and_counting() {
        let Breeds = Breed.mockedData
        
        let request = BreedMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        
        let exp = XCTestExpectation(description: #function)
        sut.update { context in
            Breeds.forEach {
                $0.store(in: context)
            }
        }
        .flatMap { _ in
            self.sut.count(request)
        }
        .resultSink { result in
            result.assertSuccess(value: Breeds.count)
            exp.fulfill()
        }
        .insert(in: cancellableBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_saving_exception() {
        let exp = XCTestExpectation(description: #function)
        sut.update { context in
            throw NSError.test
        }
        .resultSink { result in
            result.assertFailure(NSError.test.localizedDescription)
            exp.fulfill()
        }
        .insert(in: cancellableBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_fetching() {
        let breeds = Breed.mockedData
        let exp = XCTestExpectation(description: #function)
        sut
            .update { context in
                breeds.forEach {
                    $0.store(in: context)
                }
            }
            .flatMap { _ -> AnyPublisher<RequestableList<Breed>, Error> in
                let request = BreedMO.newFetchRequest()
                request.predicate = NSPredicate(format: "name == %@", breeds[0].name)
                return self.sut.fetch(request) {
                    Breed(managedObject: $0)
                }
            }
            .resultSink { result in
                result.assertSuccess(value: RequestableList<Breed>(
                    count: 1, useCache: false, { _ in breeds[0] })
                )
                exp.fulfill()
            }
            .insert(in: cancellableBag)
        wait(for: [exp], timeout: 1)
    }
}
