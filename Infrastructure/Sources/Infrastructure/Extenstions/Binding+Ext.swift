//
//  Binding+Ext.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import SwiftUI
import Combine

public extension Binding where Value: Equatable {
    
    typealias TClosure = (Value) -> Void
    
    func onSet(_ perform: @escaping TClosure) -> Self {
        return .init(get: { () -> Value in
            self.wrappedValue
        }, set: { value in
            if self.wrappedValue != value {
                self.wrappedValue = value
            }
            perform(value)
        })
    }
}
