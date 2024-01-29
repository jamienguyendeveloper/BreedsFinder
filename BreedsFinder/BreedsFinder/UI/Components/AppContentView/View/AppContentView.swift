//
//  ContentView.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine

struct AppContentView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    var body: some View {
        Group {
            if viewModel.isForTests {
                Text("Tests")
            } else {
                BreedsListView(viewModel: .init(container: viewModel.container))
                    .modifier(RootViewAppearance(viewModel: .init(container: viewModel.container)))
            }
        }
    }
}

struct AppContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppContentView(viewModel: AppContentView.ViewModel(container: .preview))
    }
}
