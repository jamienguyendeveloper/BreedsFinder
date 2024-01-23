//
//  RemoteRepositoryTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import Combine
import Infrastructure
import Models
@testable import BreedsFinder

final class RemoteRepositoryTests: XCTestCase {
    
    private var sut: TestRemoteRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    private typealias API = TestRemoteRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = TestRemoteRepository()
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_remoteRepository_success() throws {
        let data = TestRemoteRepository.TestData()
        try mock(.test, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        sut.load(.test).resultSink { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_remoteRepository_parseError() throws {
        let data = Breed.mockedData
        try mock(.test, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        sut.load(.test).resultSink { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure("The data couldn’t be read because it isn’t in the correct format.")
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_remoteRepository_httpCodeFailure() throws {
        let data = TestRemoteRepository.TestData()
        try mock(.test, result: .success(data), httpCode: 500)
        let exp = XCTestExpectation(description: "Completion")
        sut.load(.test).resultSink { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure("Failed with HTTP code: 500")
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_remoteRepository_networkingError() throws {
        let error = NSError.test
        try mock(.test, result: Result<TestRemoteRepository.TestData, Error>.failure(error))
        let exp = XCTestExpectation(description: "Completion")
        sut.load(.test).resultSink { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure(error.localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_remoteRepository_requestURLError() {
        let exp = XCTestExpectation(description: "Completion")
        sut.load(.urlError).resultSink { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure(APIRequestError.invalidURL.localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_remoteRepository_requestBodyError() {
        let exp = XCTestExpectation(description: "Completion")
        sut.load(.bodyError).resultSink { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure(TestRemoteRepository.APIError.fail.localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_remoteRepository_loadableError() {
        let exp = XCTestExpectation(description: "Completion")
        let expected = APIRequestError.invalidURL.localizedDescription
        sut.load(.urlError)
            .sinkToRequestable { loadable in
                XCTAssertTrue(Thread.isMainThread)
                XCTAssertEqual(loadable.error?.localizedDescription, expected)
                exp.fulfill()
            }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_remoteRepository_noHttpCodeError() throws {
        let response = URLResponse(url: URL(fileURLWithPath: ""),
                                   mimeType: "example", expectedContentLength: 0, textEncodingName: nil)
        let mock = try Mock(apiCall: API.test, baseURL: sut.baseURL, customResponse: response)
        RequestMocking.add(mock: mock)
        let exp = XCTestExpectation(description: "Completion")
        sut.load(.test).resultSink { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure(APIRequestError.unexpectedResponse.localizedDescription)
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

private extension TestRemoteRepository {
    func load(_ api: API) -> AnyPublisher<TestData, Error> {
        call(endpoint: api)
    }
}

extension TestRemoteRepository {
    enum API: APIRequest {
        
        case test
        case urlError
        case bodyError
        case noHttpCodeError
        
        var path: String {
            if self == .urlError {
                return "\\"
            }
            return "/test/path"
        }
        var method: String { "POST" }
        var headers: [String: String]? { nil }
        func requestBody() throws -> Data? {
            if self == .bodyError { throw APIError.fail }
            return nil
        }
    }
}

extension TestRemoteRepository {
    enum APIError: Swift.Error, LocalizedError {
        case fail
        var errorDescription: String? { "fail" }
    }
}

extension TestRemoteRepository {
    struct TestData: Codable, Equatable {
        let string: String
        let integer: Int
        
        init() {
            string = "Test"
            integer = 1
        }
    }
}
