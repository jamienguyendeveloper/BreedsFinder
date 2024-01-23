//
//  APIRequest.swift
//  BreedsFinder
//
//  Created by Jamie on 24/01/2024.
//

import Foundation

public typealias HTTPCode = Int
public typealias HTTPCodes = Range<HTTPCode>

public extension HTTPCodes {
    static let success = 200 ..< 300
}

public protocol APIRequest {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    func requestBody() throws -> Data?
}

public enum APIRequestError: Swift.Error {
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case imageDeserialization
}

extension APIRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case let .httpCode(code):
            return "Failed with HTTP code: \(code)"
        case .unexpectedResponse:
            return "Failed with response from the server"
        case .imageDeserialization:
            return "Failed with deserializing image"
        }
    }
}

public extension APIRequest {
    func urlRequest(baseURL: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIRequestError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = try requestBody()
        return request
    }
}
