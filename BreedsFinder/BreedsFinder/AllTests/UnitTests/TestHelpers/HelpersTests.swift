//
//  HelpersTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
@testable import BreedsFinder

class HelpersTests: XCTestCase {
    
    func test_result_isSuccess() {
        let sut1 = Result<Void, Error>.success(())
        let sut2 = Result<Void, Error>.failure(NSError.test)
        XCTAssertTrue(sut1.isSuccess)
        XCTAssertFalse(sut2.isSuccess)
    }
}
