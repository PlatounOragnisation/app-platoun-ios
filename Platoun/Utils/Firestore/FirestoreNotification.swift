//
//  FirestoreNotification.swift
//  Platoun
//
//  Created by Flavian Mary on 04/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCrashlytics

enum FirestoreUtilsNotificationsError: Error {
    case noErrorFetchNotif
}

extension FirestoreUtils {
    struct Notifications: FirestoreCollection {
        static let collectionName: String = "notifications"
        
        static func deleteNotification(userId: String, notifId: String) {
            Firestore.firestore()
                .collection(Users.collectionName).document(userId)
                .collection(Notifications.collectionName).document(notifId)
                .delete { (error) in
                    if let error = error {
                        Crashlytics.crashlytics().record(error: error)
                    }
                }
        }
        
        static func readNotification(userId: String, notifId: String) {
            Firestore.firestore()
                .collection(Users.collectionName).document(userId)
                .collection(Notifications.collectionName).document(notifId)
                .setData(["isRead":true], merge: true)
        }
        
        static func getNotification(userId: String, notifId: String, completion: @escaping (Result<DocumentSnapshot, Error>)->Void) {
            Firestore.firestore()
                .collection(Users.collectionName).document(userId)
                .collection(Notifications.collectionName).document(notifId)
                .getDocument { (snap, error) in
                    if let snap = snap {
                        completion(.success(snap))
                    } else {
                        completion(.failure(error ?? FirestoreUtilsNotificationsError.noErrorFetchNotif))
                    }
                }
        }
        
        static func saveInvitNotification(userId: String, notif: InvitPlatournNotification, completion: @escaping (Result<Void, Error>)->Void) {
            Firestore.firestore()
                .collection(Users.collectionName).document(userId)
                .collection(Notifications.collectionName).document(notif.id)
                .setData(notif.getData()) { error in
                    if let error = error {
                        Crashlytics.crashlytics().record(error: error)
                        completion(Result.failure(error))
                    } else {
                        completion(Result.success(Void()))
                    }
                }
        }
        
        static func saveCommentNotification(userId: String, notif: CommentPlatounNotification, completion: @escaping (Result<Void, Error>)->Void) {
            Firestore.firestore()
                .collection(Users.collectionName).document(userId)
                .collection(Notifications.collectionName).document(notif.id)
                .setData(notif.getData(), merge: false) { error in
                    if let error = error {
                        Crashlytics.crashlytics().record(error: error)
                        completion(Result.failure(error))
                    } else {
                        completion(Result.success(Void()))
                    }
                }
        }
    }
}
