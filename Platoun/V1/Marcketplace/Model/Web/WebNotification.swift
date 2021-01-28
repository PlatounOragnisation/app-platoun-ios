//
//  WebNotification.swift
//  Platoun
//
//  Created by Flavian Mary on 15/04/2020.
//

import Foundation

struct WebNotification: Codable {
    let userInviteeId: String
    let productId: String
    let groupId: String
    let productName: String
    let productPicture: String
    let productBrand: String
    let soloPrice: Int
    let groupPrice: Int
    let dateAdded: Date
    let maxUsers: Int
    let users: [WebUser]
}
