//
//  PlatounUser.swift
//  Platoun
//
//  Created by Flavian Mary on 18/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation


struct PlatounUser: Codable {
    let uid: String
    let fcmToken: String?
    let displayName: String?
    let photoUrl: String?
    var groupNotification: Bool
    var trendsNotification: Bool
    var newsNotification: Bool
}
