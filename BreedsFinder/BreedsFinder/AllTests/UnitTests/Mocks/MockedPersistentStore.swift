//
//  MockedPersistentStore.swift
//  BreedsFinderTests
//
//  Created by Jamie on 24/01/2024.
//

import CoreData
import Combine
import Models
import Infrastructure
@testable import BreedsFinder

final class MockedPersistentStore: Mock, PersistentStore {
    struct ContextSnapshot: Equatable {
        let inserted: Int
        let updated: Int
        let deleted: Int
    }
    enum Action: Equatable {
        case count
        case fetchBreeds(ContextSnapshot)
        case update(ContextSnapshot)
    }
    var actions = MockActions<Action>(expected: [])
    
    var countResult: Int = 0
    
    deinit {
        destroyDatabase()
    }
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> {
        register(.count)
        return Just<Int>.withErrorType(countResult, Error.self).publish()
    }
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<RequestableList<V>, Error> {
        do {
            let context = container.viewContext
            context.reset()
            let result = try context.fetch(fetchRequest)
            if T.self is BreedMO.Type {
                register(.fetchBreeds(context.snapshot))
            } else {
                fatalError("Add a case for \(String(describing: T.self))")
            }
            let list = RequestableList<V>(count: result.count, useCache: true, { index in
                try map(result[index])
            })
            return Just<RequestableList<V>>.withErrorType(list, Error.self).publish()
        } catch {
            return Fail<RequestableList<V>, Error>(error: error).publish()
        }
    }
    
    func update<Result>(_ operation: @escaping DataBaseOperation<Result>) -> AnyPublisher<Result, Error> {
        do {
            let context = container.viewContext
            context.reset()
            let result = try operation(context)
            register(.update(context.snapshot))
            return Just(result).setFailureType(to: Error.self).publish()
        } catch {
            return Fail<Result, Error>(error: error).publish()
        }
    }
    
    func preloadData(_ preload: (NSManagedObjectContext) throws -> Void) throws {
        try preload(container.viewContext)
        if container.viewContext.hasChanges {
            try container.viewContext.save()
        }
        container.viewContext.reset()
    }
    
    // MARK: Database
    
    private let dbVersion = CoreDataPersistentStore.Version(CoreDataPersistentStore.Version.actual)
    
    private var dbURL: URL {
        guard let url = dbVersion.databaseFileURL(.cachesDirectory, .userDomainMask)
            else { fatalError() }
        return url
    }
    
    private lazy var container: NSPersistentContainer = {
        guard let modelUrl = CoreDataPersistentStore.getBundle(modelName: dbVersion.modelName),
        let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError()
        }
        let container = NSPersistentContainer(name: dbVersion.modelName, managedObjectModel: model)
        try? FileManager().removeItem(at: dbURL)
        let store = NSPersistentStoreDescription(url: dbURL)
        container.persistentStoreDescriptions = [store]
        let group = DispatchGroup()
        group.enter()
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("\(error)")
            }
            group.leave()
        }
        group.wait()
        container.viewContext.mergePolicy = NSOverwriteMergePolicy
        container.viewContext.undoManager = nil
        return container
    }()
    
    private func destroyDatabase() {
        try? container.persistentStoreCoordinator
            .destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try? FileManager().removeItem(at: dbURL)
    }
}

extension NSManagedObjectContext {
    var snapshot: MockedPersistentStore.ContextSnapshot {
        .init(inserted: insertedObjects.count,
              updated: updatedObjects.count,
              deleted: deletedObjects.count)
    }
}
