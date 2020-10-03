//
//  RemoteConfigUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 03/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

class RemoteConfigUtils {
    static var shared: RemoteConfig = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
//        settings.minimumFetchInterval = 0
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        remoteConfig.configSettings = settings
        return remoteConfig
    }()
    
    static func getBackendToken() -> String {
        let config = shared.configValue(forKey: "tokenAuthBackend").stringValue
        let defaultConfig = shared.defaultValue(forKey: "tokenAuthBackend")?.stringValue
        
        return config ?? (defaultConfig ?? "Error")
    }
}
