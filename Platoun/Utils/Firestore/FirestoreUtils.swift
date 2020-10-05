//
//  FirestoreUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 06/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCrashlytics
import FirebaseAuth

enum FirestoreUtilsError: Error {
    case noErrorGetUser(uid: String)
    case noErrorGetUsers
    case parseUserError
    case noErrorGetPost(postId: String)
    case noErrorGetNotifications(userId: String)
}

protocol FirestoreCollection {
    static var collectionName: String { get }
}

enum FirestoreUtils {
    
    static func getPostQuery(filter: Post.PostType? = nil) -> Query {
        let db = Firestore.firestore()
        var query: Query = db.collection(Posts.collectionName)
        
        if let filter = filter {
            query = query.whereField("category", isEqualTo: filter.rawValue)
        }
        
        
        return query.order(by: "createAt", descending: true)
    }
    
    static func getNotificationsOrderedQuery(userId: String) -> Query {
        return Firestore.firestore()
            .collection(Users.collectionName).document(userId)
            .collection(Notifications.collectionName)
            .order(by: "dateTimeCreation", descending: true)
    }
    
    static func getNotificationsQuery(userId: String) -> Query {
        return Firestore.firestore()
            .collection(Users.collectionName).document(userId)
            .collection(Notifications.collectionName)
    }
}
