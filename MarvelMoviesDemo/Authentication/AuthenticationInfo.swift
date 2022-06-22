//
//  AuthenticationInfo.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation

class AuthenticationInfo: ObservableObject {
    static public let shared = AuthenticationInfo()
    
    init() {
        self.loggedIn = UserDefaults.standard.object(forKey: "loggedIn") as? Bool ?? false
    }
    
    @Published var loggedIn: Bool {
        didSet {
            UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
        }
    }
}
