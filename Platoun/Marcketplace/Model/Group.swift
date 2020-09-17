//
//  Group.swift
//  Platoun
//
//  Created by Flavian Mary on 22/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Group {
    let id: String
    let productId: String
    var users: [User]
    let groupCreator: User
    let endDate: Date
    var haveJoin: Bool
    let isPrivate: Bool
    let code: String?
    let maxUsers: Int
    
    struct User {
        let id: String
        let image: String
        let name: String
    }
    
    
    static func setup(_ web: WebGroup, in productId: String) -> Group {
        let count = (web.maxUsers == 5 ? 72 : 48) * 60 * 60
        
        let users = web.users.map { User(id: $0.userId, image: $0.profilePictureLink.trimed ?? HttpServices.defaultUserImg, name: $0.name) }
        return Group(
            id: web.id,
            productId: productId,
            users: users,
            groupCreator: users.first!,
            endDate: web.dateAdded.addingTimeInterval(TimeInterval(count)),
            haveJoin: web.joined,
            isPrivate: !(web.code ?? "").isEmpty,
            code: web.code ?? "",
            maxUsers: web.maxUsers)
    }
}
