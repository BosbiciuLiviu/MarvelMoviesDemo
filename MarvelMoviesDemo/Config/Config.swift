//
//  Config.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation

enum FullEnv: String {
    case debugDevelopment = "Debug Development"
    case releaseDevelopment = "Release Development"

    case debugStaging = "Debug Staging"
    case releaseStaging = "Release Staging"

    case debugProduction = "Debug Production"
    case releaseProduction = "Release Production"
}

enum Env {
    case development
    case staging
    case production
}

class BuildConfiguration {
    static let shared = BuildConfiguration()
    
    var fullEnvironment: FullEnv {
        didSet {
            print("Running environment: ", fullEnvironment.rawValue)
            if (fullEnvironment == .debugDevelopment || fullEnvironment == .releaseDevelopment) {
                environment = .development
            } else if (fullEnvironment == .debugStaging || fullEnvironment == .releaseStaging) {
                environment = .staging
            } else if (fullEnvironment == .debugProduction || fullEnvironment == .releaseProduction) {
                environment = .production
            }
        }
    }
    
    var environment: Env
    
    init() {
        // TODO: future improvement (we just need to set the configuration for each env)
        let currentConfiguration = FullEnv.debugDevelopment.rawValue // Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
        
        fullEnvironment = FullEnv(rawValue: currentConfiguration)!
        if (fullEnvironment == .debugDevelopment || fullEnvironment == .releaseDevelopment) {
            environment = .development
        } else if (fullEnvironment == .debugStaging || fullEnvironment == .releaseStaging) {
            environment = .staging
        } else if (fullEnvironment == .debugProduction || fullEnvironment == .releaseProduction) {
            environment = .production
        } else {
            // should not reach here
            environment = .development
        }
    }
}

extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var language: String {getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String {getInfo("CFBundleIdentifier")}
    
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}
