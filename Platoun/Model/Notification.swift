//
//  Notification.swift
//  Platoun
//
//  Created by Flavian Mary on 19/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol PlatounNotification {
    var id: String { get }
    var title: String { get }
    var message: String { get }
    var date: Date { get }
    var type: NotifType { get }
    var isRead: Bool { get }
}

enum NotifType: String, Codable {
    case status = "STATUS"
}

enum NotificationError: Error {
    case parsingTypeError
    case parsingStatus
}

struct StatusPlatounNotification: PlatounNotification {
    let id: String
    let title: String
    let message: String
    let date: Date
    let type: NotifType
    let isRead: Bool
    let groupId: String
    let senderUserId: String // sender
    let status: Status
    
    enum Status: String {
        case validated = "VALIDATED"
    }
    
    init(_ data: [String:Any], id: String) throws {
        guard
            let title = data["title"] as? String,
            let message = data["message"] as? String,
            let date = (data["dateTimeCreation"] as? Timestamp)?.dateValue(),
            let subData = data["data"] as? [String: Any],
            let groupId = subData["groupId"] as? String,
            let statusString = subData["status"] as? String,
            let status = StatusPlatounNotification.Status(rawValue: statusString),
            let senderId = subData["userId"] as? String else {
            throw NotificationError.parsingStatus
        }
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.type = .status
        self.isRead = (data["isRead"] as? Bool) ?? false
        self.groupId = groupId
        self.senderUserId = senderId
        self.status = status
    }
}

func notificationParse(_ data: [String:Any], id: String) throws -> PlatounNotification {
    guard
        let value = data["type"] as? String,
        let type = NotifType(rawValue: value) else { throw NotificationError.parsingTypeError }
    
    let notification: PlatounNotification
    switch type {
    case .status:
        notification = try StatusPlatounNotification(data, id: id)
    }
    return notification
}
