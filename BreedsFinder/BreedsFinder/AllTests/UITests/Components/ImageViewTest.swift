//
//  ImageViewTest.swift
//  BreedsFinderUITests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import SwiftUI
import ViewInspector
import Infrastructure
@testable import BreedsFinder

final class ImageViewTests: XCTestCase {

    let url = URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!
    
    func imageView(_ image: Requestable<UIImage>,
                   _ services: DIContainer.Services) -> ImageView {
        let container = DIContainer(appState: AppState(), services: services)
        let viewModel = ImageView.ViewModel(
            container: container, imageURL: url, image: image)
        return ImageView(viewModel: viewModel)
    }

    func test_imageView_notRequested() {
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(url)])
        let sut = imageView(.notRequested, services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: ""))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isRequesting_initial() {
        let services = DIContainer.Services.mocked()
        let sut = imageView(.isRequesting(last: nil, cancellableBag: CancellableBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isRequesting_refresh() {
        let services = DIContainer.Services.mocked()
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = imageView(.isRequesting(last: image, cancellableBag: CancellableBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_requested() {
        let services = DIContainer.Services.mocked()
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = imageView(.requested(image), services)
        let exp = sut.inspection.inspect { view in
            let requestedImage = try view.find(ViewType.Image.self).actualImage().uiImage()
            XCTAssertEqual(requestedImage, image)
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3)
    }
    
    func test_imageView_failed() {
        let services = DIContainer.Services.mocked()
        let sut = imageView(.failed(NSError.test), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: "Failed to load image"))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
}
