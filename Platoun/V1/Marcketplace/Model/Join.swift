//
//  Join.swift
//  Platoun
//
//  Created by Flavian Mary on 15/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Join {
    let isJoined: Bool
    let isCompleted: Bool
    let promocode: String?
    let link: String?
    let isReached: Bool
    
    static func setup(from: WebJoin, isJoined: Bool, isReached: Bool) -> Join {
        return Join(isJoined: isJoined, isCompleted: from.status == .validated, promocode: from.promoCode, link: from.buyLink, isReached: isReached)
    }
}
