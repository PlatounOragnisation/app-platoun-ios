//
//  RemoteConfigUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 03/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseCrashlytics

struct MinimalVersion: Codable {
    let minimalVersion: String
    let unauthorizedVersions: [String]
}

struct CompressionQuality: Codable {
    let post: Float
    let comment: Float
    let profilPicture: Float
}

class RemoteConfigUtils {
    
    static var shared: RemoteConfigUtils = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = Config.remoteConfigMinimumFetchInterval
        remoteConfig.configSettings = settings
        return RemoteConfigUtils(config: remoteConfig)
    }()
    
    var config: RemoteConfig
    private init(config: RemoteConfig) {
        self.config = config
    }
    
    func initialize(completion: @escaping ()->Void) {
        self.config.fetchAndActivate { (status, error) in
            if error != nil {
                Crashlytics.crashlytics().record(error: error!)
            }
            completion()
        }
    }
    
    func getBackendToken() -> String {
        let config = self.config.configValue(forKey: "tokenAuthBackend").stringValue
        return config ?? Config.DefaultRemoteConfig.tokenAuthBackend
    }
    
    func getMinimalVersion() -> MinimalVersion {
        let value = fetchValue(type: MinimalVersion.self, key: "ios_minimalVersion")
        return value ?? Config.DefaultRemoteConfig.ios_minimalVersion
    }
    
    func getCompressionQuality() -> CompressionQuality {
        let value = fetchValue(type: CompressionQuality.self, key: "compressionQuality")
        return value ?? Config.DefaultRemoteConfig.compressionQuality
    }
    
    private func fetchValue<T: Codable>(type: T.Type, key: String) -> T? {
        let decoder = JSONDecoder()
        
        guard
            let stringValue = self.config.configValue(forKey: key).stringValue,
            let data = stringValue.data(using: .utf8) else {
            return nil
        }
        
        return try? decoder.decode(type, from: data)
    }
}
