//
//  Movie.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation


struct Movie: Identifiable, Codable {
    let id: String
    let title: String
    let watchOrder: Int
    let releaseDate: Date
    let createdAt: Date?
    let updatedAt: Date?
    let director: String?
}
