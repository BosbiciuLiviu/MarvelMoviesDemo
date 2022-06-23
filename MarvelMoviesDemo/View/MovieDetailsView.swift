//
//  MovieDetailsView.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import SwiftUI

struct MovieDetailView: View {
    var name: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline)
            Text(value)
        }
    }
}

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
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImage(url: API.shared.getMovieURL(movieViewModel.movie.title)) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else if phase.error != nil {
                            EmptyView()
                        } else {
                            ProgressView()
                        }
                    }
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                    
                    MovieDetailView(name: "Title", value: movieViewModel.movie.title)
                    MovieDetailView(name: "Release date", value: movieViewModel.movie.releaseDate.toDateString())
                    MovieDetailView(name: "Director", value: movieViewModel.movie.director ?? "Unknown")
                    MovieDetailView(name: "Watch order", value: String(movieViewModel.movie.watchOrder))
                    MovieDetailView(name: "Created at", value: movieViewModel.movie.createdAt?.toString() ?? "Unknown")
                    MovieDetailView(name: "Updated at", value: movieViewModel.movie.updatedAt?.toString() ?? "Unknown")
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
