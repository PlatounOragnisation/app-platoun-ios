//
//  Notification.swift
//  Platoun
//
//  Created by Flavian Mary on 19/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Notification: Codable {
    let recipientUserId: String //destinataire
    let senderUserId: String?
    let sendingAt: Date
    let title: String
    let description: String
    let isRead: Bool
}
