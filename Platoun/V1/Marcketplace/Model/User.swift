//
//  User.swift
//  Platoun
//
//  Created by Flavian Mary on 04/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct UserMomunity: Equatable {
    let id: String
    
    static func setup(from web: WebUser) -> UserMomunity {
        return UserMomunity(id: web.userId)
    }
}
