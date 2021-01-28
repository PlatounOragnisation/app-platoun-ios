//
//  HttpServices.swift
//  PlatounDev
//
//  Created by Flavian Mary on 31/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

class HttpServices {    
    static let defaultUserImg = "default"
    
    private static let versionApi = "/v1"
        
    var env = PlatounEnv.develop
    
    var baseURL: String {
        get { "\(env.url)/api\(HttpServices.versionApi)" }
    }
}

class ConfigEnv {
    static let shared = ConfigEnv()
    static let remoteConfigMinimumFetchInterval: TimeInterval = 0
    let notificationAuthorization = "AAAASP_Vozc:APA91bE11oX0YgVxDGEEWzjgjbm9j6OhPMNXl5P38Ukhlkw0bXxgtFhHgs-sfpTJo-D-D0ob0-Xe4lxv-HqyACyiajUKFs8bfOun2h35xlXq98BSiL-_jn5xN9mJIoHvOcD0bbsO57B6"
}

