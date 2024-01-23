//
//  RequestableTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import Combine
import Infrastructure
@testable import BreedsFinder

final class RequestableTests: XCTestCase {

    func test_equality() {
        let possibleValues: [Requestable<Int>] = [
            .notRequested,
            .isRequesting(last: nil, cancellableBag: CancellableBag()),
            .isRequesting(last: 9, cancellableBag: CancellableBag()),
            .requested(5),
            .requested(6),
            .failed(NSError.test)
        ]
        possibleValues.enumerated().forEach { (index1, value1) in
            possibleValues.enumerated().forEach { (index2, value2) in
                if index1 == index2 {
                    XCTAssertEqual(value1, value2)
                } else {
                    XCTAssertNotEqual(value1, value2)
                }
            }
        }
    }
    
    func test_cancelRequesting() {
        let cancenBag1 = CancellableBag(), cancenBag2 = CancellableBag()
        let subject = PassthroughSubject<Int, Never>()
        subject.sink { _ in }
            .insert(in: cancenBag1)
        subject.sink { _ in }
            .insert(in: cancenBag2)
        var sut1 = Requestable<Int>.isRequesting(last: nil, cancellableBag: cancenBag1)
        XCTAssertEqual(cancenBag1.cancelables.count, 1)
        sut1.cancelRequesting()
        XCTAssertEqual(cancenBag1.cancelables.count, 0)
        XCTAssertNotNil(sut1.error)
        var sut2 = Requestable<Int>.isRequesting(last: 7, cancellableBag: cancenBag2)
        XCTAssertEqual(cancenBag2.cancelables.count, 1)
        sut2.cancelRequesting()
        XCTAssertEqual(cancenBag2.cancelables.count, 0)
        XCTAssertEqual(sut2.value, 7)
    }
    
    func test_map() {
        let values: [Requestable<Int>] = [
            .notRequested,
            .isRequesting(last: nil, cancellableBag: CancellableBag()),
            .isRequesting(last: 5, cancellableBag: CancellableBag()),
            .requested(7),
            .failed(NSError.test)
        ]
        let expect: [Requestable<String>] = [
            .notRequested,
            .isRequesting(last: nil, cancellableBag: .test),
            .isRequesting(last: "5", cancellableBag: .test),
            .requested("7"),
            .failed(NSError.test)
        ]
        let sut = values.map { value in
            value.map { "\($0)" }
        }
        XCTAssertEqual(sut, expect)
    }

    func test_helperFunctions() {
        let notRequested = Requestable<Int>.notRequested
        let requestingNil = Requestable<Int>.isRequesting(last: nil, cancellableBag: CancellableBag())
        let requestingValue = Requestable<Int>.isRequesting(last: 9, cancellableBag: CancellableBag())
        let requested = Requestable<Int>.requested(5)
        let failedErrValue = Requestable<Int>.failed(NSError.test)
        [notRequested, requestingNil].forEach {
            XCTAssertNil($0.value)
        }
        [requestingValue, requested].forEach {
            XCTAssertNotNil($0.value)
        }
        [notRequested, requestingNil, requestingValue, requested].forEach {
            XCTAssertNil($0.error)
        }
        XCTAssertNotNil(failedErrValue.error)
    }
    
    func test_throwingMap() {
        let value = Requestable<Int>.requested(5)
        let sut = value.map { _ in throw NSError.test }
        XCTAssertNotNil(sut.error)
    }
    
    func test_valueIsMissing() {
        XCTAssertEqual(DataIsMissingError().localizedDescription, "Missing data")
    }
}

extension CancellableBag {
    static var test: CancellableBag {
        return CancellableBag(equalToAny: true)
    }
}
