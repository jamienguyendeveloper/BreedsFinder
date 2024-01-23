//
//  ObservableObject+Ext.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import Combine

public extension ObservableObject {
    
    func requestableSubject<T>(_ keyPath: WritableKeyPath<Self, Requestable<T>>) -> RequestableSubject<T> {
        let defaultValue = self[keyPath: keyPath]
        return .init(get: { [weak self] in
            self?[keyPath: keyPath] ?? defaultValue
        }, set: { [weak self] in
            self?[keyPath: keyPath] = $0
        })
    }
}
