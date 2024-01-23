//
//  AppDelegateTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import UIKit
@testable import BreedsFinder

final class AppDelegateTests: XCTestCase {

    func test_didFinishLaunching() {
        let sut = AppDelegate()
        _ = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    }
}
