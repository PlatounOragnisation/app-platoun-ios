//
//  WebGroup.swift
//  Platoun
//
//  Created by Flavian Mary on 01/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct WebGroup: Codable {
    let id: String
    let users: [User]
    let dateAdded: Date
    let maxUsers: Int
    let code: String?
    let joined: Bool
    
    struct User: Codable {
        let userId: String
        let name: String
        let profilePictureLink: String?
    }
}
