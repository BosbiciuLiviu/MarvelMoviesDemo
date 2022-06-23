//
//  NavigationLazyView.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import SwiftUI

// Used to avoid automatically initializing all sub-views
struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
