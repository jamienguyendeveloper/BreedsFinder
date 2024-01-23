//
//  ImageRemoteRepository.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine
import UIKit

protocol ImageRemoteRepository: RemoteRepository {
    func loadImage(imageURL: URL) -> AnyPublisher<UIImage, Error>
}
