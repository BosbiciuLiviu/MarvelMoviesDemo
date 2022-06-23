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

struct MoviesView: View {
    @State var showSortingActionSheet: Bool = false
    @StateObject var moviesViewModel: MoviesViewModel = MoviesViewModel()
    @ObservedObject var authClient = OAuthClient.shared
    
    var body: some View {
        NavigationView {
            Group {
                if case .authenticated(_) = authClient.authState {
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
                    .onAppear {
                        moviesViewModel.getMovies()
                    }
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
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
            .navigationBarItems(trailing: HStack(spacing: 20) {
                Button(action: {
                    OAuthClient.shared.logout()
                }) {
                    Text("Logout")
                }
                
                Button(action: {
                    showSortingActionSheet = true
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .buttonStyle(.plain)
            }
            )
        }
        .navigationViewStyle(.stack)
    }
}


struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
    }
}
