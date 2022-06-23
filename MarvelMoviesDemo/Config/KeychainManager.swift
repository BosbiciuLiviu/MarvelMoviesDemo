//
//  KeychainManager.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation
import KeychainAccess

class KeychainManager {
    static public let shared = KeychainManager()
    public let keychainUsername = "username"
    public let keychainPassword = "password"
    public let keychainToken = "token"
    public let validTo = "validTo"
    
    let keychain: Keychain
    
    private let keychainService = "com.novartis.MarvelMoviesDemo"
    
    init() {
        keychain = Keychain(service: keychainService)
    }
    
    public func saveString(key: String, value: String?) {
        keychain[key] = value
    }
    
    public func getString(_ key: String) -> String? {
        return keychain[key]
    }
}
