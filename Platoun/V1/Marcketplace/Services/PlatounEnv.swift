//
//  HttpServices.swift
//  Platoun
//
//  Created by Flavian Mary on 04/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

public enum PlatounError: Error {
    case userIdNotDefined
}

public enum PlatounEnv: String {
    case develop
    case release
    
    var url: String {
        switch self {
        case .develop:
            return "https://platoun-api-develop.azurewebsites.net"
        case .release:
            return "https://platoun-api-release.azurewebsites.net"
        }
    }
}

extension HttpServices {
    static let shared = HttpServices()
}
