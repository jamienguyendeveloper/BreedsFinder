//
//  CoreDataPersistentStore.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import CoreData
import Combine
import Infrastructure

public protocol PersistentStore {
    typealias DataBaseOperation<Result> = (NSManagedObjectContext) throws -> Result
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error>
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>, map: @escaping (T) throws -> V?) -> AnyPublisher<RequestableList<V>, Error>
    func update<Result>(_ operation: @escaping DataBaseOperation<Result>) -> AnyPublisher<Result, Error>
}

public struct CoreDataPersistentStore: PersistentStore {
    
    public let container: NSPersistentContainer
    public let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    public let bgQueue = DispatchQueue(label: "coredata")
    
    public static func getBundle(modelName: String) -> URL? {
        return Bundle.module.url(forResource:modelName, withExtension: "momd")
    }
    
    public init(directory: FileManager.SearchPathDirectory = .documentDirectory,
                domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
                version: UInt) {
        let version = Version(version)
        guard let modelUrl = Bundle.module.url(forResource:version.modelName, withExtension: "momd"),
        let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError()
        }
        container = NSPersistentContainer(name: version.modelName, managedObjectModel: model)
        if let url = version.databaseFileURL(directory, domainMask) {
            let store = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [store]
        }
        bgQueue.async { [weak isStoreLoaded, weak container] in
            container?.loadPersistentStores { (storeDescription, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        isStoreLoaded?.send(completion: .failure(error))
                    } else {
                        container?.viewContext.configureAsReadOnlyContext()
                        isStoreLoaded?.value = true
                    }
                }
            }
        }
    }
    
    public func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> {
        return onStoreIsReady
            .flatMap { [weak container] in
                Future<Int, Error> { promise in
                    do {
                        let count = try container?.viewContext.count(for: fetchRequest) ?? 0
                        promise(.success(count))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<RequestableList<V>, Error> {
        assert(Thread.isMainThread)
        
        print(T.self)
        print(V.self)
        let fetch = Future<RequestableList<V>, Error> { [weak container] promise in
            guard let context = container?.viewContext else { return }
            context.performAndWait {
                do {
                    let managedObjects = try context.fetch(fetchRequest)
                    let results = RequestableList<V>(count: managedObjects.count,
                                                     useCache: true) { [weak context] in
                        let object = managedObjects[$0]
                        let mapped = try map(object)
                        if let mo = object as? NSManagedObject {
                            context?.refresh(mo, mergeChanges: false)
                        }
                        return mapped
                    }
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        return onStoreIsReady
            .flatMap { fetch }
            .eraseToAnyPublisher()
    }
    
    public func update<Result>(_ operation: @escaping DataBaseOperation<Result>) -> AnyPublisher<Result, Error> {
        let update = Future<Result, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.async {
                guard let context = container?.newBackgroundContext() else { return }
                context.configureAsUpdateContext()
                context.performAndWait {
                    do {
                        let result = try operation(context)
                        if context.hasChanges {
                            try context.save()
                        }
                        context.reset()
                        promise(.success(result))
                    } catch {
                        context.reset()
                        promise(.failure(error))
                    }
                }
            }
        }
        return onStoreIsReady
            .flatMap { update }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public var onStoreIsReady: AnyPublisher<Void, Error> {
        return isStoreLoaded
            .filter { $0 }
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

public extension CoreDataPersistentStore.Version {
    static var actual: UInt { 1 }
}

public extension CoreDataPersistentStore {
    struct Version {
        private let number: UInt
        
        public init(_ number: UInt) {
            self.number = number
        }
        
        public var modelName: String {
            return "db_model_v1"
        }
        
        public func databaseFileURL(_ directory: FileManager.SearchPathDirectory,
                             _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            return FileManager.default
                .urls(for: directory, in: domainMask).first?
                .appendingPathComponent(subpathToDatabase)
        }
        
        private var subpathToDatabase: String {
            return "db.sql"
        }
    }
}
