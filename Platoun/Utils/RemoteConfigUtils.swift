//
//  RemoteConfigUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 03/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

struct MinimalVersion: Codable {
    let minimalVersion: String
    let unauthorizedVersions: [String]
}

class RemoteConfigUtils {
    
    static var shared: RemoteConfig = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
        return remoteConfig
    }()
    
    static func getBackendToken() -> String {
        let config = shared.configValue(forKey: "tokenAuthBackend").stringValue
        return config ?? Config.DefaultRemoteConfig.tokenAuthBackend
    }
    
    static func getMinimalVersion() -> MinimalVersion {
        let decoder = JSONDecoder()
        
        guard
            let stringValue = shared.configValue(forKey: "ios_minimalVersion").stringValue,
            let data = stringValue.data(using: .utf8) else {
            return Config.DefaultRemoteConfig.ios_minimalVersion
        }
        
        let minimalVersion = try? decoder.decode(MinimalVersion.self, from: data)
        return minimalVersion ?? Config.DefaultRemoteConfig.ios_minimalVersion
    }
}
