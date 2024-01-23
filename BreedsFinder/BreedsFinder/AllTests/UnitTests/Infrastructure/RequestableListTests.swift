//
//  RequestableListTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import Combine
import Infrastructure
import DataAccess
import Models
@testable import BreedsFinder

final class RequestableListTests: XCTestCase {

    func test_empty() {
        let list = RequestableList<Int>.empty
        XCTAssertThrowsError(try list.item(at: 0))
    }
    
    func test_nil_element() {
        let list1 = RequestableList<Int>(count: 1, useCache: false, { _ in nil })
        XCTAssertThrowsError(try list1.item(at: 0))
        let list2 = [0, 1].requestableList
        XCTAssertThrowsError(try list2.item(at: 2))
    }
    
    func test_nil_element_error() {
        let error = RequestableList<Int>.Error.dataIsNil(index: 5)
        XCTAssertEqual(error.localizedDescription, "Item at index 5 is nil")
    }
    
    func test_access_noCache() {
        var counter = 0
        let list = RequestableList<Int>(count: 3, useCache: false) { _ in
            counter += 1
            return counter
        }
        [0, 1, 2, 0, 1, 2].forEach { index in
            _ = list[index]
        }
        XCTAssertEqual(counter, 6)
    }
    
    func test_access_withCache() {
        var counter = 0
        let list = RequestableList<Int>(count: 3, useCache: true) { _ in
            counter += 1
            return counter
        }
        [0, 1, 2, 0, 1, 2].forEach { index in
            _ = list[index]
        }
        XCTAssertEqual(counter, 3)
    }
    
    let bgQueue1 = DispatchQueue(label: "bgQueue1")
    let bgQueue2 = DispatchQueue(label: "bgQueue2")
    
    func test_concurrent_access() {
        let indices = Array(stride(from: 0, to: 100, by: 1))
        var counter = 0
        let list = RequestableList<Int>(count: indices.count, useCache: true) { index in
            counter += 1
            return index
        }
        let exp1 = XCTestExpectation(description: "queue1")
        let exp2 = XCTestExpectation(description: "queue2")
        bgQueue1.async {
            let result1 = indices.map { list[$0] }
            XCTAssertEqual(result1, indices)
            XCTAssertEqual(counter, indices.count)
            exp1.fulfill()
        }
        bgQueue2.async {
            let result2 = indices.map { list[$0] }
            XCTAssertEqual(result2, indices)
            XCTAssertEqual(counter, indices.count)
            exp2.fulfill()
        }
        wait(for: [exp1, exp2], timeout: 0.5)
    }
    
    func test_sequence() {
        let indices = Array(stride(from: 0, to: 10, by: 1))
        let list = RequestableList<Int>(count: indices.count, useCache: true) { $0 }
        XCTAssertEqual(list.underestimatedCount, indices.count)
        XCTAssertEqual(list.reversed(), indices.reversed())
        
        let nilList = RequestableList<Int>(count: 1, useCache: false) { _ in nil }
        var iterator = nilList.makeIterator()
        XCTAssertNil(iterator.next())
    }
    
    func test_randomAccessCollection() {
        let list = RequestableList<Int>(count: 10, useCache: true) { $0 }
        XCTAssertEqual(list.firstIndex(of: 2), 2)
        XCTAssertEqual(list.last, 9)
    }
    
    func test_equatable() {
        let list1 = RequestableList<Int>(count: 10, useCache: true) { $0 }
        let list2 = RequestableList<Int>(count: 11, useCache: true) { $0 }
        let list3 = Array(stride(from: 0, to: 10, by: 1)).requestableList
        XCTAssertNotEqual(list1, list2)
        XCTAssertEqual(list1, list1)
        XCTAssertEqual(list1, list3)
    }
    
    func test_description() {
        let emptyList = RequestableList<Int>.empty
        let oneElementList = RequestableList<Int>(count: 1, useCache: false) { $0 + 1 }
        let nonEmptyList = RequestableList<Int>(count: 3, useCache: false) { $0 * 2 }
        XCTAssertEqual(emptyList.description, "RequestableList<[]>")
        XCTAssertEqual(oneElementList.description, "RequestableList<[1]>")
        XCTAssertEqual(nonEmptyList.description, "RequestableList<[0, 2, 4]>")
    }
}
