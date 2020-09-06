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

enum FirestoreUtilsError: Error {
    case noErrorGetUser(uid: String)
}

class FirestoreUtils: NSObject {
    
    static func saveUser(uid: String, name: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(["displayName": name], merge: true)
    }
    
    static func getUserInfo(uid: String, completion: @escaping (Result<(name: String, photo:URL?), Error>)->Void) {
        Firestore
            .firestore()
            .collection("users").document(uid)
            .getDocument() { (doc, error) in
                guard let doc = doc, doc.exists, let name = doc.data()?["displayName"] as? String else {
                    let error = error ?? FirestoreUtilsError.noErrorGetUser(uid: uid)
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                    return
                }
                let photo = doc.data()?["photoUrl"] as? String
                let url = photo?.isEmpty ?? true ? nil : URL(string: photo!)
                completion(Result.success((name, url)))
        }
    }
    
    static func savePost(post: Post, completion: @escaping (Result<Void,Error>)->Void) {
        let db = Firestore.firestore()
        do {
            try db.collection("posts").document(post.postId).setData(from: post, merge: true) { error in
                if let error = error {
                    completion(Result.failure(error))
                } else {
                    completion(Result.success(Void()))
                }
            }
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            completion(Result.failure(error))
        }
    }
    
    
    static func getPostQuery() -> Query {
        let db = Firestore.firestore()
        
        return db.collection("posts").order(by: "createAt", descending: true)
    }
}
