//
//  Date+Extension.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 23.06.2022.
//

import Foundation

extension Date {
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
}
