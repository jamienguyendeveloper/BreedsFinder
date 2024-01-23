//
//  BreedsListView.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine
import Infrastructure
import Models

struct BreedsListView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    let inspection = Inspection<Self>()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                self.content
                    .navigationBarTitle("Breeds")
                    .navigationBarHidden(self.viewModel.breedsSearch.keyboardHeight > 0)
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    @ViewBuilder private var content: some View {
        switch viewModel.breeds {
        case .notRequested:
            notRequestedView
        case let .isRequesting(last, _):
            requestingView(last)
        case let .requested(breeds):
            requestedView(breeds, showSearch: true, showLoading: false)
        case let .failed(error):
            failedView(error)
        }
    }
}

private extension BreedsListView {
    var notRequestedView: some View {
        Text("").onAppear(perform: self.viewModel.reloadBreeds)
    }
    
    func requestingView(_ previouslyRequested: RequestableList<Breed>?) -> some View {
        if let breeds = previouslyRequested {
            return AnyView(requestedView(breeds, showSearch: true, showLoading: true))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.viewModel.reloadBreeds()
        })
    }
}

private extension BreedsListView {
    func requestedView(_ breeds: RequestableList<Breed>, showSearch: Bool, showLoading: Bool) -> some View {
        VStack {
            if showSearch {
                SearchBar(text: $viewModel.breedsSearch.searchText.onSet({ _ in
                    self.viewModel.reloadBreeds()
                }))
            }
            if showLoading {
                ActivityIndicatorView().padding()
            }
            List(breeds) { breed in
                NavigationLink {
                    BreedDetailView(breed: breed)
                } label: {
                    BreedCell(breed: breed)
                }
            }
        }.padding(.bottom, bottomInset)
    }
    
    var bottomInset: CGFloat {
        if #available(iOS 14, *) {
            return 0
        } else {
            return self.viewModel.breedsSearch.keyboardHeight
        }
    }
}

struct BreedsListView_Previews: PreviewProvider {
    static var previews: some View {
        BreedsListView(viewModel: .init(container: .preview))
    }
}
