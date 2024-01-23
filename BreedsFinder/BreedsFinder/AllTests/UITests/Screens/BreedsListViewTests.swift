//
//  BreedsListViewTests.swift
//  BreedsFinderUITests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import ViewInspector
import Interactors
import Infrastructure
import Models
@testable import BreedsFinder

final class BreedsListTests: XCTestCase {
    
    func test_breeds_notRequested() {
        let container = DIContainer(appState: AppState(), services:
                .mocked(
                    breedsService: [.loadBreeds(search: "")]
                ))
        let sut = BreedsListView(viewModel: .init(container: container, Breeds: .notRequested))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().text(0))
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_breeds_isRequesting_initial() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = BreedsListView(viewModel: .init(container: container, Breeds:
                .isRequesting(last: nil, cancellableBag: CancellableBag())))
        let exp = sut.inspection.inspect { view in
            let content = try view.content()
            XCTAssertNoThrow(try content.find(ActivityIndicatorView.self))
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_breeds_isRequesting_refresh() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = BreedsListView(viewModel: .init(container: container, Breeds:
                .isRequesting(last: Breed.mockedData.requestableList, cancellableBag: CancellableBag())))
        let exp = sut.inspection.inspect { view in
            let content = try view.content()
            XCTAssertNoThrow(try content.find(SearchBar.self))
            XCTAssertNoThrow(try content.find(ActivityIndicatorView.self))
            let cell = try content.find(BreedCell.self).actualView()
            XCTAssertEqual(cell.breed, Breed.mockedData[0])
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_breeds_requested() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = BreedsListView(viewModel: .init(container: container, Breeds:
                .requested(Breed.mockedData.requestableList)))
        let exp = sut.inspection.inspect { view in
            let content = try view.content()
            XCTAssertNoThrow(try content.find(SearchBar.self))
            XCTAssertThrowsError(try content.find(ActivityIndicatorView.self))
            let cell = try content.find(BreedCell.self).actualView()
            XCTAssertEqual(cell.breed, Breed.mockedData[0])
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_breeds_failed() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = BreedsListView(viewModel: .init(container: container, Breeds:
                .failed(NSError.test)))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().view(ErrorView.self, 0))
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_breeds_failed_retry() {
        let container = DIContainer(appState: AppState(), services: .mocked(
            breedsService: [.loadBreeds(search: "")]
        ))
        let sut = BreedsListView(viewModel: .init(container: container, Breeds:
                .failed(NSError.test)))
        let exp = sut.inspection.inspect { view in
            let errorView = try view.content().view(ErrorView.self, 0)
            try errorView.vStack().button(2).tap()
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
}

extension InspectableView where View == ViewType.View<BreedsListView> {
    func content() throws -> InspectableView<ViewType.NavigationView> {
        return try geometryReader().navigationView()
    }
}
