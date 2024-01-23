//
//  ImagesServiceTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import Combine
import DataAccess
import Interactors
import Infrastructure
@testable import BreedsFinder

final class ImagesServiceTests: XCTestCase {
    
    var sut: ImagesServiceImpl!
    var mockedRemoteRepository: MockedImageRemoteRepository!
    var subscriptions = Set<AnyCancellable>()
    let testImageURL = URL(string: "https://test.com/test.png")!
    let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
    
    override func setUp() {
        mockedRemoteRepository = MockedImageRemoteRepository()
        sut = ImagesServiceImpl(remoteRepository: mockedRemoteRepository)
        subscriptions = Set<AnyCancellable>()
    }
    
    func expectRepoActions(_ actions: [MockedImageRemoteRepository.Action]) {
        mockedRemoteRepository.actions = .init(expected: actions)
    }
    
    func verifyRepoActions(file: StaticString = #file, line: UInt = #line) {
        mockedRemoteRepository.verify(file: file, line: line)
    }
    
    func test_loadImage_nilURL() {
        let image = BindingWithPublisher(value: Requestable<UIImage>.notRequested)
        expectRepoActions([])
        sut.load(image: image.binding, url: nil)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .notRequested
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_requestImage_remote_requested() {
        let image = BindingWithPublisher(value: Requestable<UIImage>.notRequested)
        mockedRemoteRepository.imageResponse = .success(testImage)
        expectRepoActions([.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isRequesting(last: nil, cancellableBag: .test),
                .requested(self.testImage)
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_requestImage_failed() {
        let image = BindingWithPublisher(value: Requestable<UIImage>.notRequested)
        let error = NSError.test
        mockedRemoteRepository.imageResponse = .failure(error)
        expectRepoActions([.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isRequesting(last: nil, cancellableBag: .test),
                .failed(error)
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_request_hadRequestedImage() {
        let image = BindingWithPublisher(value: Requestable<UIImage>.requested(testImage))
        let error = NSError.test
        mockedRemoteRepository.imageResponse = .failure(error)
        expectRepoActions([.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .requested(self.testImage),
                .isRequesting(last: self.testImage, cancellableBag: .test),
                .failed(error)
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_stubService() {
        let sut = StubImagesService()
        let image = BindingWithPublisher(value: Requestable<UIImage>.notRequested)
        sut.load(image: image.binding, url: testImageURL)
    }
}
