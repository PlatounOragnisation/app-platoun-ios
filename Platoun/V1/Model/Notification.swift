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
    
    func getData() -> [String:Any]
}

enum NotifType: String, Codable {
    case status = "STATUS"
    case invit = "INVITATION"
    case comment = "COMMENT"
}

enum NotificationError: Error {
    case parsingTypeError
    case parsingStatus
}

struct CommentPlatounNotification: PlatounNotification {
    var id: String
    var title: String
    var message: String
    var date: Date
    var type: NotifType
    var isRead: Bool
    var postId: String
    
    init(postId: String) {
        self.id = postId
        self.title = "Ton poste a reçu un nouveau commentaire"
        self.message = "N'hésite pas à aller répondre."
        self.date = Date()
        self.type = .comment
        self.isRead = false
        self.postId = postId
    }
    
    
    init(_ data: [String:Any], id: String) throws {
        guard
            let title = data["title"] as? String,
            let message = data["message"] as? String,
            let date = (data["dateTimeCreation"] as? Timestamp)?.dateValue() else {
            throw NotificationError.parsingStatus
        }
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.type = .comment
        self.isRead = (data["isRead"] as? Bool) ?? false
        self.postId = id
    }
    
    func getData() -> [String : Any] {
        return [
            "title": title,
            "message": message,
            "dateTimeCreation": Timestamp(date: self.date),
            "type": NotifType.comment.rawValue,
            "data": [
                "postId": id,
            ],
            "isRead": isRead
        ]
    }
    
    
}

struct InvitPlatournNotification: PlatounNotification {
    var id: String
    var title: String
    var message: String
    var date: Date
    var type: NotifType
    var isRead: Bool
    var senderUserId: String
    var senderName: String?
    let groupId: String
    
    init(id: String, title: String, message: String, senderUserId: String, senderName: String?, groupId: String) {
        self.id = id
        self.title = title
        self.message = message
        self.date = Date()
        self.type = .invit
        self.isRead = false
        self.senderUserId = senderUserId
        self.senderName = senderName
        self.groupId = groupId
    }
    
    init(_ data: [String:Any], id: String) throws {
        guard
            let title = data["title"] as? String,
            let message = data["message"] as? String,
            let date = (data["dateTimeCreation"] as? Timestamp)?.dateValue(),
            let subData = data["data"] as? [String: Any],
            let groupId = subData["groupId"] as? String,
            let senderId = subData["userId"] as? String else {
            throw NotificationError.parsingStatus
        }
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.type = .invit
        self.isRead = (data["isRead"] as? Bool) ?? false
        self.groupId = groupId
        self.senderUserId = senderId
        self.senderName = subData["userName"] as? String
    }
    
    func getData() -> [String : Any] {
        return [
            "title": title,
            "message": message,
            "dateTimeCreation": Timestamp(date: self.date),
            "type": NotifType.invit.rawValue,
            "data": [
                "userId": senderUserId,
                "userName": senderName,
                "groupId": groupId
            ],
            "isRead": isRead
        ]
    }
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
        case pending = "PENDING"
        case failed = "FAILED"
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
    
    func getData() -> [String : Any] {
        return [
            "title": title,
            "message": message,
            "dateTimeCreation": Timestamp(date: self.date),
            "type": NotifType.status.rawValue,
            "data": [
                "groupId": groupId,
                "status": status.rawValue,
                "userId": senderUserId
            ],
            "isRead": isRead
        ]
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
    case .invit:
        notification = try InvitPlatournNotification(data, id: id)
    case .comment:
        notification = try CommentPlatounNotification(data, id: id)
    }
    return notification
}
