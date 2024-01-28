//
//  BreedsListViewModel.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine
import Infrastructure
import Models

// MARK: Search

// MARK: ViewModel

extension BreedsListView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var searchText: String = ""
        @Published var breeds: Requestable<RequestableList<Breed>>
        @Published var selectedBreed: Breed? = nil
        
        // DI
        let container: DIContainer
        private var cancellableBag = CancellableBag()
        
        init(container: DIContainer, Breeds: Requestable<RequestableList<Breed>> = .notRequested) {
            self.container = container
            _breeds = .init(initialValue: Breeds)
        }
        
        // MARK: Side Effects
        
        func reloadBreeds() {
            container.services.breedsService
                .load(breeds: requestableSubject(\.breeds),
                      search: searchText)
        }
    }
}
