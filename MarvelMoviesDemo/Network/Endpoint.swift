//
//  Endpoint.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation

public enum Endpoint: Equatable {
    case login
    case movies
    case movieDetails(movieId: String)
    case titleImage(title: String)
    
    func path() -> String {
        switch self {
        case .login:
            return "/api/login"
        case .movies:
            return "/api/movies"
        case let .movieDetails(movieId):
            return "/api/movies/\(movieId)"
        case let .titleImage(title):
            return "/images/\(title).jpg"
        }
    }
}
