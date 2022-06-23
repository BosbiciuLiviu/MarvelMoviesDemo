//
//  MovieDetailsView.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import SwiftUI

struct MovieDetailsView: View {
    @State var movie: Movie
    @StateObject var movieViewModel: MovieViewModel
    
    init(movie: Movie) {
        self._movie = State(initialValue: movie)
        self._movieViewModel = StateObject(wrappedValue: MovieViewModel(movie: movie))
    }
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    Text("Title: \(movieViewModel.movie.title)")
                    Text("Release date: " + movieViewModel.movie.releaseDate.toDateString())
                    Text("Director: \(movieViewModel.movie.director ?? "Unknown")")
                    Text("Watch order: \(String(movieViewModel.movie.watchOrder))")
                    Text("Created at: \(movieViewModel.movie.createdAt?.toString() ?? "Unknown")")
                    Text("Updated at: \(movieViewModel.movie.updatedAt?.toString() ?? "Unknown")")
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            movieViewModel.getMovieDetails()
        }
    }
}
