//
//  MoviesView.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import SwiftUI

enum SortType {
    case chronologicallyAscending
    case chronologicallyDescending
    case releaseDateAscending
    case releaseDateDescending
}

// todo: move this
struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct MoviesView: View {
    @State var showSortingActionSheet: Bool = false
    @StateObject var moviesViewModel: MoviesViewModel = MoviesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach($moviesViewModel.movies) { $movie in
                    NavigationLink(destination: NavigationLazyView(MovieDetailsView(movie: movie))) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(movie.title)
                                    .multilineTextAlignment(.leading)
                                    .font(.headline)
                                Text(movie.releaseDate.toDateString())
                                    .multilineTextAlignment(.leading)
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .foregroundColor(Color(.label))
                        .padding()
                    }
                }
            }
            .actionSheet(isPresented: $showSortingActionSheet) {
                ActionSheet(
                    title: Text("Sort"),
                    buttons: [
                        .default(Text("Chronologically ascending")) {
                            moviesViewModel.sortType = .chronologicallyAscending
                        },
                        .default(Text("Chronologically descending")) {
                            moviesViewModel.sortType = .chronologicallyDescending
                        },
                        .default(Text("Release date ascending")) {
                            moviesViewModel.sortType = .releaseDateAscending
                        },
                        .default(Text("Release date descending")) {
                            moviesViewModel.sortType = .releaseDateDescending
                        },
                        .cancel()
                    ]
                )
            }
            .navigationBarTitle("Movies")
            .navigationBarItems(trailing: Button(action: {
                showSortingActionSheet = true
            }) {
                Image(systemName: "arrow.up.arrow.down")
            }
                                    .buttonStyle(.plain)
            )
            
        }
        .onAppear {
            moviesViewModel.getMovies()
        }
    }
}


struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
    }
}
