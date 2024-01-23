//
//  CancellableBag.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Combine

public final class CancellableBag {
    
    public var cancelables = Set<AnyCancellable>()
    private let equalToAny: Bool
    
    public init(equalToAny: Bool = false) {
        self.equalToAny = equalToAny
    }
    
    public func isEqual(to other: CancellableBag) -> Bool {
        return other === self || other.equalToAny || equalToAny
    }
    
    public func cancel() {
        cancelables.removeAll()
    }
}

extension AnyCancellable {
    
    public func insert(in cancellableBag: CancellableBag) {
        cancellableBag.cancelables.insert(self)
    }
}
