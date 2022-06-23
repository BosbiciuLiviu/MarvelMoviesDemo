//
//  AuthClient.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import SwiftUI
import Foundation
import Combine

public class OAuthClient: ObservableObject {
    public enum State: Equatable {
        case signedOut
        case refreshing, signinInProgress
        case authenticated(authToken: String)
    }
    
    static public let shared = OAuthClient()
    
    @Published public var authState = State.refreshing {
        didSet {
            switch authState {
            case .authenticated:
                print(".authenticated")
            case .signedOut:
                print(".signedOut")
                if (AuthenticationInfo.shared.loggedIn) {
                    AuthenticationInfo.shared.loggedIn = false
                }
            default:
                print("authState default")
            }
        }
    }
    
    var loading: Bool {
        authState == .signinInProgress || authState == .refreshing
    }
    
    private var refreshTimer: Timer?
    @ObservedObject var monitor: NetworkMonitor
    
    let keychain = KeychainManager.shared
    
    // Request
    private var requestCancellable: AnyCancellable?
    private var refreshCancellable: AnyCancellable?
    
    init() {
        monitor = NetworkMonitor()
        if let username = keychain.getString(keychain.keychainUsername),
           let password = keychain.getString(keychain.keychainPassword) {
            if monitor.connectionStatus == .connected {
                DispatchQueue.main.async {
                    // refresh only if there is a network connection. If we don't do this, the user will be logged out.
                    self.generateAuthToken(username: username, password: password)
                }
            } else {
                authState = .signedOut
            }
            
            // refresh every 4 minutes (the token expires in 5 minutes)
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 4 * 60, repeats: true) { _ in
                switch self.authState {
                case .authenticated(_):
                    if let username = self.keychain.getString(self.keychain.keychainUsername),
                       let password = self.keychain.getString(self.keychain.keychainPassword) {
                        // refresh only if there is a network connection. If we don't do this, the user will be logged out.
                        if self.monitor.connectionStatus == .connected {
                            self.handleLogin(username: username, password: password)
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    func handleLogin(username: String,
                     password: String) {
        print("handleLogin()")
        authState = .signinInProgress
        refreshCancellable = generateAuthToken(username: username,
                                               password: password)?
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.logout()
                    break
                case .finished:
                    print("handleLogin() success")
                    AuthenticationInfo.shared.loggedIn = true
                }
            }, receiveValue: { response in
                self.keychain.saveString(key: self.keychain.keychainUsername, value: username)
                self.keychain.saveString(key: self.keychain.keychainPassword, value: password)
                self.keychain.saveString(key: self.keychain.keychainToken, value: response.token)
                // todo: take validTo into account
                API.shared.setToken(token: response.token)
            })
    }
    
    public func generateAuthToken(username: String,
                                  password: String) -> AnyPublisher<LoginResponse, NetworkError>? {
        let params: [String: String] = [:]
        API.shared.setAuthCredentials(username: username, password: password)
        return API.shared.request(endpoint: .login,
                                  httpMethod: "POST",
                                  isJSONEndpoint: true,
                                  queryParamsAsBody: true,
                                  params: params)
            .eraseToAnyPublisher()
    }
    
    public func logout() {
        authState = .signedOut
        self.keychain.saveString(key: keychain.keychainUsername, value: nil)
        self.keychain.saveString(key: keychain.keychainPassword, value: nil)
        self.keychain.saveString(key: keychain.keychainToken, value: nil)
    }
}
