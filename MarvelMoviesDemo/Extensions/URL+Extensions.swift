//
//  URL+Extensions.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation

extension URL {
    /// Use this init for static URL strings to avoid using force unwrap or doing redundant error handling
    /// - Parameter string: static url ie https://www.example.com/privacy/
    init(staticString: StaticString) {
        guard let url = URL(string: "\(staticString)") else {
            fatalError("URL is illegal: \(staticString)")
        }
        self = url
    }
    
    public func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: queryItem, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
    
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }

}
