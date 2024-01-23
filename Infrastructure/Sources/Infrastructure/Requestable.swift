//
//  Requestable.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import SwiftUI

public typealias RequestableSubject<Value> = Binding<Requestable<Value>>

public enum Requestable<T> {
    
    case notRequested
    case isRequesting(last: T?, cancellableBag: CancellableBag)
    case requested(T)
    case failed(Error)
    
    public var value: T? {
        switch self {
        case let .requested(value):
            return value
        case let .isRequesting(last, _):
            return last
        default:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case let .failed(error):
            return error
        default:
            return nil
        }
    }
}

public extension Requestable {
    
    mutating func setIsRequesting(cancellableBag: CancellableBag) {
        self = .isRequesting(last: value, cancellableBag: cancellableBag)
    }
    
    mutating func cancelRequesting() {
        switch self {
        case let .isRequesting(last, cancellableBag):
            cancellableBag.cancel()
            if let last = last {
                self = .requested(last)
            } else {
                let error = NSError(domain: NSCocoaErrorDomain,
                                    code: NSUserCancelledError,
                                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Cancelled", comment: "")])
                self = .failed(error)
            }
        default:
            break
        }
    }
    
    func map<V>(_ transform: (T) throws -> V) -> Requestable<V> {
        do {
            switch self {
            case .notRequested:
                return .notRequested
            case let .failed(error):
                return .failed(error)
            case let .isRequesting(value, cancellableBag):
                return .isRequesting(last: try value.map { try transform($0) },
                                     cancellableBag: cancellableBag)
            case let .requested(value):
                return .requested(try transform(value))
            }
        } catch {
            return .failed(error)
        }
    }
}

public protocol RequestOptional {
    associatedtype Wrapped
    func unwrap() throws -> Wrapped
}

public struct DataIsMissingError: Error {
    
    public init() {
    }
    
    public var localizedDescription: String {
        NSLocalizedString("Missing data", comment: "")
    }
}

extension Optional: RequestOptional {
    public func unwrap() throws -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            throw DataIsMissingError()
        }
    }
}

public extension Requestable where T: RequestOptional {
    func unwrap() -> Requestable<T.Wrapped> {
        map { try $0.unwrap() }
    }
}

extension Requestable: Equatable where T: Equatable {
    public static func == (lhs: Requestable<T>, rhs: Requestable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested):
            return true
        case let (.isRequesting(lhsV, lhsC), .isRequesting(rhsV, rhsC)):
            return lhsV == rhsV && lhsC.isEqual(to: rhsC)
        case let (.requested(lhsV), .requested(rhsV)):
            return lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default:
            return false
        }
    }
}
