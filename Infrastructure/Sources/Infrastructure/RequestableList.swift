//
//  RequestableList.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation

public struct RequestableList<T> {
    
    public typealias Access = (Int) throws -> T?
    public let access: Access
    public let useCache: Bool
    public var cache = Cache()
    
    public let count: Int
    
    public init(count: Int, useCache: Bool, _ access: @escaping Access) {
        self.count = count
        self.useCache = useCache
        self.access = access
    }
    
    public func item(at index: Int) throws -> T {
        guard useCache else {
            return try get(at: index)
        }
        return try cache.sync { elements in
            if let element = elements[index] {
                return element
            }
            let element = try get(at: index)
            elements[index] = element
            return element
        }
    }
    
    public func get(at index: Int) throws -> T {
        guard let element = try access(index) else {
            throw Error.dataIsNil(index: index)
        }
        return element
    }
    
    public static var empty: Self {
        return .init(count: 0, useCache: false) { index in
            throw Error.dataIsNil(index: index)
        }
    }
}

public extension RequestableList {
    
    class Cache {

        private var items = [Int: T]()
        
        public func sync(_ access: (inout [Int: T]) throws -> T) throws -> T {
            guard Thread.isMainThread else {
                var result: T!
                try DispatchQueue.main.sync {
                    result = try access(&items)
                }
                return result
            }
            return try access(&items)
        }
    }
}

extension RequestableList: Sequence {
    
    public enum Error: LocalizedError {
        case dataIsNil(index: Int)
        
        public var localizedDescription: String {
            switch self {
            case let .dataIsNil(index):
                return "Item at index \(index) is nil"
            }
        }
    }
    
    public struct Iterator: IteratorProtocol {
        public typealias Item = T
        private var index = -1
        private var list: RequestableList<Item>
        
        public init(list: RequestableList<Item>) {
            self.list = list
        }
        
        public mutating func next() -> Item? {
            index += 1
            guard index < list.count else {
                return nil
            }
            do {
                return try list.item(at: index)
            } catch {
                return nil
            }
        }
    }

    public func makeIterator() -> Iterator {
        .init(list: self)
    }

    public var underestimatedCount: Int { count }
}

extension RequestableList: RandomAccessCollection {
    
    public typealias Index = Int
    public var startIndex: Index { 0 }
    public var endIndex: Index { count }
    
    public subscript(index: Index) -> Iterator.Element {
        do {
            return try item(at: index)
        } catch let error {
            fatalError("\(error)")
        }
    }

    public func index(after index: Index) -> Index {
        return index + 1
    }

    public func index(before index: Index) -> Index {
        return index - 1
    }
}

extension RequestableList: Equatable where T: Equatable {
    public static func == (lhs: RequestableList<T>, rhs: RequestableList<T>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        return zip(lhs, rhs).first(where: { $0 != $1 }) == nil
    }
}

extension RequestableList: CustomStringConvertible {
    public var description: String {
        let items = self.reduce("", { str, item in
            return str.count == 0 ? "\(item)" : str + ", \(item)"
        })
        return "RequestableList<[\(items)]>"
    }
}

public extension RandomAccessCollection {
    var requestableList: RequestableList<Element> {
        return .init(count: self.count, useCache: false) {
            guard $0 < self.count else {
                return nil
            }
            let index = self.index(self.startIndex, offsetBy: $0)
            return self[index]
        }
    }
}
