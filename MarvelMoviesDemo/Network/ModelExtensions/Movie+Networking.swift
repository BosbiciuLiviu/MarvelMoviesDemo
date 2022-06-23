//
//  Movie+Networking.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import Foundation
import Combine

extension Movie {
    static public func getMovies() -> AnyPublisher<[Movie], NetworkError> {
        return API.shared.request(endpoint: .movies,
                                  params: [:])
    }
    
    mutating public func getDetails() -> AnyPublisher<Movie, NetworkError> {
        return API.shared.request(endpoint: .movieDetails(movieId: self.id),
                                  params: [:])
    }
}
