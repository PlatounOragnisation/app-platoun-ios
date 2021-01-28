//
//  NotificationUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 14/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import Alamofire

class NotificationUtils {
    
    static func sendCommentNotif(fcmToken: String, notif: CommentPlatounNotification) {
        self.sendCommentSentNotif(fcmToken: fcmToken, title: notif.title, body: notif.message, postId: notif.id)
    }
    
    private static func sendCommentSentNotif(fcmToken: String, title: String, body: String, postId: String) {
        sendNotif(to: fcmToken, title: title, body: body,
                  ["type":"comment", "postId": postId])
    }
    
    static func sendLikeNotif(fcmToken: String, postId: String) {
        sendNotif(to: fcmToken, title: "Ton poste a reçu un nouveau Upvote", body: "Félicitation",
                  ["type":"like", "postId": postId])
    }
    
    static func sendInvitationNotif(fcmToken: String, notif: InvitPlatournNotification) {
        sendNotif(to: fcmToken, title: notif.title, body: notif.message,
                  ["type":"invitation","notifId": notif.id])
    }
    
    private static func sendNotif(to token: String, title: String, body: String, _ content: [String:Any] = [:]) {
        AF.request(
            "https://fcm.googleapis.com/fcm/send",
            method: .post,
            parameters: [
                "notification": [
                    "body": body,
                    "title": title
                ],
                "data": content,
                "to": token
            ],
            encoding: JSONEncoding(),
            headers: [
                "Content-Type": "application/json",
                "Authorization": "key=\(Config.env.notificationAuthorization)"
            ])
            .response { response in
                print(response)
            }
    }
}
