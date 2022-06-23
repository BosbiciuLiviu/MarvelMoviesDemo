//
//  MoviesViewModel.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import Foundation
import Combine

class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var sortType: SortType = .chronologicallyAscending {
        didSet {
            sortMovies(movies)
        }
    }
    
    private var cancellableStore: [AnyCancellable] = []
    
    init() {
        
    }
    
    init(movies: [Movie]) {
        self.movies = movies
    }
    
    func getMovies() {
        let cancellable = Movie.getMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // ideally do something - to be done
                    }
                },
                receiveValue: { [weak self] response in
                    let newMovies = response
                    self?.sortMovies(newMovies)
                }
            )
        
        cancellableStore.append(cancellable)
    }
    
    func sortMovies(_ movies: [Movie]) {
        switch self.sortType {
        case .chronologicallyAscending:
            self.movies = movies.sorted { $0.watchOrder < $1.watchOrder }
        case .chronologicallyDescending:
            self.movies = movies.sorted { $0.watchOrder > $1.watchOrder }
        case .releaseDateAscending:
            self.movies = movies.sorted { $0.releaseDate < $1.releaseDate }
        case .releaseDateDescending:
            self.movies = movies.sorted { $0.releaseDate > $1.releaseDate }
        }
    }
}
