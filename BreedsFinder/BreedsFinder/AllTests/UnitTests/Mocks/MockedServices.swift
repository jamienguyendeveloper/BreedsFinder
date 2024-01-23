//
//  MockedServices.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import SwiftUI
import Combine
import DataAccess
import Models
import Infrastructure
import Interactors
import ViewInspector
@testable import BreedsFinder

extension DIContainer.Services {
    static func mocked(
        breedsService: [MockedBreedsService.Action] = [],
        imagesService: [MockedImagesService.Action] = []
    ) -> DIContainer.Services {
        .init(breedsService: MockedBreedsService(expected: breedsService),
              imagesService: MockedImagesService(expected: imagesService))
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (breedsService as? MockedBreedsService)?
            .verify(file: file, line: line)
        (imagesService as? MockedImagesService)?
            .verify(file: file, line: line)
    }
}

struct MockedBreedsService: Mock, BreedsService {
    
    enum Action: Equatable {
        case refreshBreeds
        case loadBreeds(search: String)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func refreshBreeds() -> AnyPublisher<Void, Error> {
        register(.refreshBreeds)
        return Just<Void>.withErrorType(Error.self)
    }
    
    func load(breeds: RequestableSubject<RequestableList<Breed>>, search: String) {
        register(.loadBreeds(search: search))
    }
}

struct MockedImagesService: Mock, ImagesService {
    
    enum Action: Equatable {
        case loadImage(URL?)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func load(image: RequestableSubject<UIImage>, url: URL?) {
        register(.loadImage(url))
    }
}
