//
//  AppContentViewTests.swift
//  BreedsFinderUITests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import ViewInspector
@testable import BreedsFinder

final class AppContentViewTests: XCTestCase {

    func test_content_for_tests() throws {
        let viewModel = AppContentView.ViewModel(container: .defaultValue, isRunningTests: true)
        let sut = AppContentView(viewModel: viewModel)
        XCTAssertNoThrow(try sut.inspect().group().text(0))
    }
    
    func test_content_for_build() throws {
        let viewModel = AppContentView.ViewModel(container: .defaultValue, isRunningTests: false)
        let sut = AppContentView(viewModel: viewModel)
        XCTAssertNoThrow(try sut.inspect().group().view(BreedsListView.self, 0))
    }
}
