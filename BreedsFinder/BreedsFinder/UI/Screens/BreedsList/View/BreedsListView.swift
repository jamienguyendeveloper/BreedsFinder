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
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            self.content
            .onReceive(inspection.notice) {
                self.inspection.visit(self, $0)
            }
        }.accentColor(.white)
    }
    
    @ViewBuilder private var content: some View {
        ZStack {
            Colors.main.ignoresSafeArea()
            VStack {
                VStack {
                    Text("Breeds")
                        .foregroundColor(.white)
                        .font(Fonts.regular(20))
                        .padding()
                        
                }.frame(maxWidth: .infinity)
                    .background(Colors.main)
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
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Colors.main)
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
                HStack {
                    let binding = Binding<String>(get: {
                        viewModel.searchText
                    }, set: {
                        viewModel.searchText = $0
                    })
                    TextField("", text: binding, onCommit: {
                        viewModel.reloadBreeds()
                    })
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { isFocused in
                        if !isFocused {
                            if viewModel.searchText.isEmpty {
                                viewModel.reloadBreeds()
                            }
                        }
                    }
                    .font(Fonts.regular(18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: 35)
                    .padding(4)
                    .submitLabel(.search)
                    .placeholder(when: viewModel.searchText.isEmpty) {
                        Text("Search breeds...").font(Fonts.italic(18)).foregroundColor(.white.opacity(0.5))
                    }
                }.cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Colors.background ?? Color.white, lineWidth: 1)
                    ).background(Color.clear)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 0)
                    .padding(.bottom, 20)
            }
            if showLoading {
                VStack {
                    ActivityIndicatorView().padding()
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<breeds.count, id:\.self) { idx in
                            let breed = breeds[idx]
                            NavigationLink {
                                BreedDetailView(breed: breed)
                            } label: {
                                BreedCell(breed: breed)
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                                    .cornerRadius(20)
                            }

                        }
                    }
                }.background(Colors.main)
            }
        }
    }
}

struct BreedsListView_Previews: PreviewProvider {
    static var previews: some View {
        BreedsListView(viewModel: .init(container: .preview))
    }
}
