//
//  ImagesServiceImpl.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import UIKit
import Combine
import Infrastructure
import DataAccess

public struct ImagesServiceImpl: ImagesService {
    
    let remoteRepository: ImageRemoteRepository
    
    public init(remoteRepository: ImageRemoteRepository) {
        self.remoteRepository = remoteRepository
    }
    
    public func load(image: RequestableSubject<UIImage>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested; return
        }
        let cancellableBag = CancellableBag()
        image.wrappedValue = .isRequesting(last: image.wrappedValue.value, cancellableBag: cancellableBag)
        remoteRepository.loadImage(imageURL: url)
            .sinkToRequestable {
                image.wrappedValue = $0
            }
            .insert(in: cancellableBag)
    }
}
