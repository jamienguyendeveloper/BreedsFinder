//
//  SceneDelegateTests.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import UIKit
@testable import BreedsFinder

final class SceneDelegateTests: XCTestCase {
    
    private lazy var scene: UIScene = {
        UIApplication.shared.connectedScenes.first!
    }()
}
