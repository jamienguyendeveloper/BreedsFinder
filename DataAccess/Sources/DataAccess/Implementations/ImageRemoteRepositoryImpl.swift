//
//  ImageRemoteRepositoryImpl.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine
import UIKit
import Infrastructure

public struct ImageRemoteRepositoryImpl: ImageRemoteRepository {
    
    public let session: URLSession
    public let baseURL: String
    public let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    public init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    public func loadImage(imageURL: URL) -> AnyPublisher<UIImage, Error> {
        return download(rawImageURL: imageURL)
            .subscribe(on: bgQueue)
            .receive(on: DispatchQueue.main)
            .extractUnderlyingError()
            .eraseToAnyPublisher()
    }
    
    private func download(rawImageURL: URL) -> AnyPublisher<UIImage, Error> {
        let urlRequest = URLRequest(url: rawImageURL)
        return session.dataTaskPublisher(for: urlRequest)
            .requestData()
            .tryMap { data -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw APIRequestError.imageDeserialization
                }
                return image
            }
            .eraseToAnyPublisher()
    }
}
