//
//  HttpServices.swift
//  Platoun
//
//  Created by Flavian Mary on 31/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

class HttpServices {
    static let defaultUserImg = "default"
    
    private static let versionApi = "/v1"
        
    var env = PlatounEnv.release
    
    var baseURL: String {
        get { "\(env.url)/api\(HttpServices.versionApi)" }
    }
}

class ConfigEnv {
    static let shared = ConfigEnv()
    static let remoteConfigMinimumFetchInterval: TimeInterval = 3600
    let notificationAuthorization = "AAAAEv-sP9w:APA91bEswEMe3nFEpiMRrUZQJkYxgMqtZaMDvbHOZKNbVCIlhUEN91guSL663D5_IjWawiZQnCYwwMaIns7UsK4-8GX52UmwuMIbsLINjJUsAjpv2-VW0nkOEy8h4iGwsXEZM8NyLL4q"
}

