//
//  ImageRemoteRepositoryTests.swift
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

final class ImageRemoteRepositoryTests: XCTestCase {

    private var sut: ImageRemoteRepositoryImpl!
    private var subscriptions = Set<AnyCancellable>()
    private lazy var testImage = UIColor.red.image(CGSize(width: 40, height: 40))
    
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = ImageRemoteRepositoryImpl(session: .mockedResponsesOnly,
                                     baseURL: "https://test.com")
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_loadImage_success() throws {
        
        let imageURL = try XCTUnwrap(URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"))
        let responseData = try XCTUnwrap(testImage.pngData())
        let mock = Mock(url: imageURL, result: .success(responseData))
        RequestMocking.add(mock: mock)
        
        let exp = XCTestExpectation(description: "Completion")
        sut.loadImage(imageURL: imageURL).resultSink { result in
            switch result {
            case let .success(resultValue):
                XCTAssertEqual(resultValue.size, self.testImage.size)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_failure() throws {
        let imageURL = try XCTUnwrap(URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"))
        let mocks = [Mock(url: imageURL, result: .failure(APIRequestError.unexpectedResponse))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        sut.loadImage(imageURL: imageURL).resultSink { result in
            result.assertFailure(APIRequestError.unexpectedResponse.localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
}
