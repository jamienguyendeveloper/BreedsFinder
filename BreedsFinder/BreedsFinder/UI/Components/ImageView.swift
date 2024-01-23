//
//  ImageView.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine
import Infrastructure

struct ImageView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    let inspection = Inspection<Self>()
    
    var body: some View {
        content.onReceive(inspection.notice) {
            self.inspection.visit(self, $0)
        }
    }
    
    @ViewBuilder private var content: some View {
        switch viewModel.image {
        case .notRequested:
            notRequestedView
        case .isRequesting:
            requestingView
        case let .requested(image):
            requestedView(image)
        case let .failed(error):
            failedView(error)
        }
    }
}

private extension ImageView.ViewModel {
    func loadImage() {
        container.services.imagesService.load(image: requestableSubject(\.image),
                                              url: imageURL)
    }
}

private extension ImageView {
    var notRequestedView: some View {
        Text("").onAppear {
            self.viewModel.loadImage()
        }
    }
    
    var requestingView: some View {
        ActivityIndicatorView()
    }
    
    func failedView(_ error: Error) -> some View {
        Text("Failed to load image")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    func requestedView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

extension ImageView {
    class ViewModel: ObservableObject {
        
        let imageURL: URL
        @Published var image: Requestable<UIImage>
        
        let container: DIContainer
        private var cancellableBag = CancellableBag()
        
        init(container: DIContainer, imageURL: URL, image: Requestable<UIImage> = .notRequested) {
            self.imageURL = imageURL
            self._image = .init(initialValue: image)
            self.container = container
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(viewModel: ImageView.ViewModel(
            container: .preview, imageURL: URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!))
    }
}
