//
//  ContentView.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authInfo: AuthenticationInfo = AuthenticationInfo.shared
    
    var body: some View {
        if !authInfo.loggedIn {
            LoginView()
        } else {
            MoviesView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
