//
//  CoreDataHelpers.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import CoreData
import Combine

public protocol ManagedEntity: NSFetchRequestResult { }

public extension ManagedEntity where Self: NSManagedObject {
    
    public static var entityName: String {
        let nameManagedObject = String(describing: Self.self)
        let suffixIndex = nameManagedObject.index(nameManagedObject.endIndex, offsetBy: -2)
        return String(nameManagedObject[..<suffixIndex])
    }
    
    public static func insertNew(in context: NSManagedObjectContext) -> Self? {
        return NSEntityDescription
            .insertNewObject(forEntityName: entityName, into: context) as? Self
    }
    
    public static func newFetchRequest() -> NSFetchRequest<Self> {
        return .init(entityName: entityName)
    }
}

public extension NSManagedObjectContext {
    
    public func configureAsReadOnlyContext() {
        automaticallyMergesChangesFromParent = true
        mergePolicy = NSRollbackMergePolicy
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
    }
    
    public func configureAsUpdateContext() {
        mergePolicy = NSOverwriteMergePolicy
        undoManager = nil
    }
}

public extension NSSet {
    public func toArray<T>(of type: T.Type) -> [T] {
        allObjects.compactMap { $0 as? T }
    }
}
