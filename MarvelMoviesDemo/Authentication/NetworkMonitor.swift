//
//  NetworkMonitor.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//
import Foundation
import Network

/// An enum representing the regions in which DO Spaces are available
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
                    // refresh only if there is a network connection. If we don't do this, the user will be logged out.
//                    OAuthClient.shared.refreshToken(username: <#T##String#>, password: <#T##String#>)()
                    // todo liviu: change this.
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
