//
//  ButtonStyle.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation
import SwiftUI


struct OutlinedButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(.label))
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                        .foregroundColor(Color(.label)))
    }
}

extension View {
    func outlinedButtonStyle() -> some View {
        self.modifier(OutlinedButtonStyleModifier())
    }
}
