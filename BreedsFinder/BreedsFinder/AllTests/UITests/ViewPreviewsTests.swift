//
//  ViewPreviewsTests.swift
//  BreedsFinderUITests
//
//  Created by Jamie on 24/01/2024.
//

import XCTest
import ViewInspector
@testable import BreedsFinder

final class ViewPreviewsTests: XCTestCase {

    func test_contentView_previews() {
        _ = AppContentView_Previews.previews
    }
    
    func test_breedsListView_previews() {
        _ = BreedsListView_Previews.previews
    }
    
    func test_breedCell_previews() {
        _ = BreedCell_Previews.previews
    }
    
    func test_errorView_previews() throws {
        let view = ErrorView_Previews.previews
        try view.inspect().view(ErrorView.self).actualView().retryAction()
    }
    
    func test_imageView_previews() {
        _ = ImageView_Previews.previews
    }
}
