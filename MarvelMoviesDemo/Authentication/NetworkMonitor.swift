//
//  NetworkMonitor.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//
import Foundation
import Network

enum ConnectionStatus: String, CaseIterable {
    case undefined,
         connected,
         disconnected
}

final class NetworkMonitor: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    @Published var connectionStatus: ConnectionStatus = .undefined {
        didSet {
            isNotConnected = !(connectionStatus == .connected)
            if connectionStatus == .connected {
                DispatchQueue.main.async {
                    let keychain = KeychainManager.shared
                    let username = keychain.getString(keychain.keychainUsername)
                    let password = keychain.getString(keychain.keychainPassword)
                    
                    // refresh only if there is a network connection. If we don't do this, the user will be logged out.
                    if let username = username, let password = password {
                        OAuthClient.shared.handleLogin(username: username,
                                                       password: password)
                    }
                }
            }
        }
    }
    @Published var isNotConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connectionStatus = (path.status == NWPath.Status.satisfied) ? .connected : .disconnected
            }
        }
        monitor.start(queue: queue)
    }
}
