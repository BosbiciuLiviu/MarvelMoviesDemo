//
//  MovieViewModel.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import Foundation
import Combine

class MovieViewModel: ObservableObject {
    @Published var movie: Movie
    
    private var cancellableStore: [AnyCancellable] = []
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    func getMovieDetails() {
        let cancellable = movie.getDetails()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // ideally do something - to be done
                    }
                },
                receiveValue: { [weak self] response in
                    self?.movie = response
                }
            )
        
        cancellableStore.append(cancellable)
    }
}

