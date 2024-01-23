//
//  BreedsServiceImpl.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import Combine
import DataAccess
import Infrastructure
import Models

public typealias Store<T> = CurrentValueSubject<T, Never>

public struct BreedsServiceImpl: BreedsService {
    
    let remoteRepository: BreedsRemoteRepository
    let databaseRepository: BreedsDataBaseRepository
    let appState: Store<AppState>
    
    public init(remoteRepository: BreedsRemoteRepository,
                databaseRepository: BreedsDataBaseRepository,
                applicationState: Store<AppState>) {
        self.remoteRepository = remoteRepository
        self.databaseRepository = databaseRepository
        self.appState = applicationState
    }

    public func load(breeds: RequestableSubject<RequestableList<Breed>>, search: String) {
        
        let cancellableBag = CancellableBag()
        breeds.wrappedValue.setIsRequesting(cancellableBag: cancellableBag)
        
        Just<Void>
            .withErrorType(Error.self)
            .flatMap { [databaseRepository] _ -> AnyPublisher<Bool, Error> in
                databaseRepository.hasRequestedBreeds()
            }
            .flatMap { hasRequested -> AnyPublisher<Void, Error> in
                if hasRequested {
                    return Just<Void>.withErrorType(Error.self)
                } else {
                    return self.refreshBreeds()
                }
            }
            .flatMap { [databaseRepository] in
                databaseRepository.searchBreeds(search: search)
            }
            .sinkToRequestable { breeds.wrappedValue = $0 }
            .insert(in: cancellableBag)
    }
    
    public func refreshBreeds() -> AnyPublisher<Void, Error> {
        return remoteRepository
            .loadBreeds()
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { [databaseRepository] in
                databaseRepository.saveBreedsToDataBase(breeds: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isForTests ? 0 : 0.5
    }
}
