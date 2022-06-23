//
//  Responses.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import Foundation

public struct ErrorResponse: Decodable {
    let error: Bool
    let reason: String
}

public struct LoginResponse: Decodable {
    let token: String
    let validTo: Date
}

public enum NetworkError: Error {
    case unknown(data: ErrorResponse)
    case message(reason: String, data: Data)
    case parseError(reason: Error)
    case rateLimitted
    case serverBusy
    case unauthorized
    case conflict
    
    static func processResponse(data: Data, response: URLResponse) throws -> Result<Data, Error> {
        guard let httpResponse = response as? HTTPURLResponse else {
            print("processResponse() SHOULD NOT GET HERE")
            throw NetworkError.unknown(data: try! JSONDecoder().decode(ErrorResponse.self, from: data))
        }
        print("processResponse() statusCode: ", httpResponse.statusCode)
        if (httpResponse.statusCode == 401) {
            throw NetworkError.unauthorized
        } else if (httpResponse.statusCode == 429) {
            throw NetworkError.rateLimitted
        } else if (httpResponse.statusCode == 503) {
            throw NetworkError.serverBusy
        } else if (httpResponse.statusCode == 409) {
            throw NetworkError.conflict
        } else if (httpResponse.statusCode == 404) {
            throw NetworkError.message(reason: "Resource not found", data: data)
        } else if 200 ... 299 ~= httpResponse.statusCode {
            return .success(data)
        } else {
            print("Unkown error data: ", String(decoding: data, as: UTF8.self))
            throw NetworkError.unknown(data: try! JSONDecoder().decode(ErrorResponse.self, from: data))
        }
    }
}
