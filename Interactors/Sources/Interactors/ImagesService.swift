//
//  ImagesService.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine
import Foundation
import SwiftUI
import Infrastructure

public protocol ImagesService {
    func load(image: RequestableSubject<UIImage>, url: URL?)
}

public struct StubImagesService: ImagesService {
    
    public init() {
    }
    
    public func load(image: RequestableSubject<UIImage>, url: URL?) {
    }
}
