//
//  BreedsServiceTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import SwiftUI
import Combine
import Interactors
import DataAccess
import Infrastructure
import Models
@testable import BreedsFinder

class BreedsServiceTests: XCTestCase {

    let appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedBreedsRemoteRepository: MockedBreedsRemoteRepository!
    var mockedBreedsDataBaseRepository: MockedBreedsDataBaseRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: BreedsServiceImpl!

    override func setUp() {
        appState.value = AppState()
        mockedBreedsRemoteRepository = MockedBreedsRemoteRepository()
        mockedBreedsDataBaseRepository = MockedBreedsDataBaseRepository()
        sut = BreedsServiceImpl(remoteRepository: mockedBreedsRemoteRepository,
                                      databaseRepository: mockedBreedsDataBaseRepository,
                                      applicationState: appState)
    }

    override func tearDown() {
        subscriptions = Set<AnyCancellable>()
    }
}

final class RequestBreedsTests: BreedsServiceTests {
    
    func test_filledDataBase_successfulSearch() {
        let list = Breed.mockedData
        
        mockedBreedsRemoteRepository.actions = .init(expected: [
        ])
        mockedBreedsDataBaseRepository.actions = .init(expected: [
            .hasRequestedBreeds,
            .fetchBreeds(search: "test")
        ])
        
        mockedBreedsDataBaseRepository.hasRequestedBreedsResult = .success(true)
        mockedBreedsDataBaseRepository.fetchBreedsResult = .success(list.requestableList)
        
        let breeds = BindingWithPublisher(value: Requestable<RequestableList<Breed>>.notRequested)
        sut.load(breeds: breeds.binding, search: "test")
        let exp = XCTestExpectation(description: #function)
        breeds.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isRequesting(last: nil, cancellableBag: .test),
                .requested(list.requestableList)
            ], removing: Breed.prefixes)
            self.mockedBreedsRemoteRepository.verify()
            self.mockedBreedsDataBaseRepository.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_filledDB_failedSearch() {
        let error = NSError.test
        
        mockedBreedsRemoteRepository.actions = .init(expected: [
        ])
        
        mockedBreedsDataBaseRepository.actions = .init(expected: [
            .hasRequestedBreeds,
            .fetchBreeds(search: "test")
        ])
        
        mockedBreedsDataBaseRepository.hasRequestedBreedsResult = .success(true)
        mockedBreedsDataBaseRepository.fetchBreedsResult = .failure(error)
        
        let breeds = BindingWithPublisher(value: Requestable<RequestableList<Breed>>.notRequested)
        sut.load(breeds: breeds.binding, search: "test")
        let exp = XCTestExpectation(description: #function)
        breeds.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isRequesting(last: nil, cancellableBag: .test),
                .failed(error)
            ], removing: Breed.prefixes)
            self.mockedBreedsRemoteRepository.verify()
            self.mockedBreedsDataBaseRepository.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_emptyDB_failedRequest() {
        let error = NSError.test
        
        mockedBreedsRemoteRepository.actions = .init(expected: [
            .loadBreeds
        ])
        mockedBreedsDataBaseRepository.actions = .init(expected: [
            .hasRequestedBreeds
        ])
        
        mockedBreedsRemoteRepository.BreedsResponse = .failure(error)
        mockedBreedsDataBaseRepository.hasRequestedBreedsResult = .success(false)
        
        let breeds = BindingWithPublisher(value: Requestable<RequestableList<Breed>>.notRequested)
        sut.load(breeds: breeds.binding, search: "test")
        let exp = XCTestExpectation(description: #function)
        breeds.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isRequesting(last: nil, cancellableBag: .test),
                .failed(error)
            ], removing: Breed.prefixes)
            self.mockedBreedsRemoteRepository.verify()
            self.mockedBreedsDataBaseRepository.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_emptyDataBase_successfulRequest_successfulStoring() {
        let list = Breed.mockedData
        
        mockedBreedsRemoteRepository.actions = .init(expected: [
            .loadBreeds
        ])
        mockedBreedsDataBaseRepository.actions = .init(expected: [
            .hasRequestedBreeds,
            .saveBreedsToDataBase(list),
            .fetchBreeds(search: "test")
        ])
        
        mockedBreedsRemoteRepository.BreedsResponse = .success(list)
        mockedBreedsDataBaseRepository.hasRequestedBreedsResult = .success(false)
        mockedBreedsDataBaseRepository.saveBreedsToDataBaseResult = .success(())
        mockedBreedsDataBaseRepository.fetchBreedsResult = .success(list.requestableList)
        
        let breeds = BindingWithPublisher(value: Requestable<RequestableList<Breed>>.notRequested)
        sut.load(breeds: breeds.binding, search: "test")
        let exp = XCTestExpectation(description: #function)
        breeds.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isRequesting(last: nil, cancellableBag: .test),
                .requested(list.requestableList)
            ], removing: Breed.prefixes)
            self.mockedBreedsRemoteRepository.verify()
            self.mockedBreedsDataBaseRepository.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_emptyDataBase_successfulRequest_failedStoring() {
        let list = Breed.mockedData
        let error = NSError.test
        
        mockedBreedsRemoteRepository.actions = .init(expected: [
            .loadBreeds
        ])
        mockedBreedsDataBaseRepository.actions = .init(expected: [
            .hasRequestedBreeds,
            .saveBreedsToDataBase(list)
        ])
        
        mockedBreedsRemoteRepository.BreedsResponse = .success(list)
        mockedBreedsDataBaseRepository.hasRequestedBreedsResult = .success(false)
        mockedBreedsDataBaseRepository.saveBreedsToDataBaseResult = .failure(error)
        
        let breeds = BindingWithPublisher(value: Requestable<RequestableList<Breed>>.notRequested)
        sut.load(breeds: breeds.binding, search: "test")
        let exp = XCTestExpectation(description: #function)
        breeds.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isRequesting(last: nil, cancellableBag: .test),
                .failed(error)
            ], removing: Breed.prefixes)
            self.mockedBreedsRemoteRepository.verify()
            self.mockedBreedsDataBaseRepository.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
}
