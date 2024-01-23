//
//  RemoteRepository.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation
import Combine

public protocol RemoteRepository {
    var session: URLSession { get }
    var baseURL: String { get }
    var bgQueue: DispatchQueue { get }
}

public extension RemoteRepository {
    func call<T>(endpoint: APIRequest, httpCodes: HTTPCodes = .success) -> AnyPublisher<T, Error>
        where T: Decodable {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL)
            return session.dataTaskPublisher(for: request).requestJSON(httpCodes: httpCodes)
        } catch let error {
            return Fail<T, Error>(error: error).eraseToAnyPublisher()
        }
    }
}

public extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func requestData(httpCodes: HTTPCodes = .success) -> AnyPublisher<Data, Error> {
        return tryMap {
                assert(!Thread.isMainThread)
                guard let code = ($0.1 as? HTTPURLResponse)?.statusCode else {
                    throw APIRequestError.unexpectedResponse
                }
                guard httpCodes.contains(code) else {
                    throw APIRequestError.httpCode(code)
                }
                return $0.0
            }
            .extractUnderlyingError()
            .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    public func requestJSON<Value>(httpCodes: HTTPCodes) -> AnyPublisher<Value, Error> where Value: Decodable {
        return requestData(httpCodes: httpCodes)
            .decode(type: Value.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
