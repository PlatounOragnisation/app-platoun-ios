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

