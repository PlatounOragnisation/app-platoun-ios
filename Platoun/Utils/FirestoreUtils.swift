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

class FirestoreUtils: NSObject {
    
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
            completion(Result.failure(error))
        }
    }
    
    
    static func getPostQuery() -> Query {
        let db = Firestore.firestore()
        
        return db.collection("posts").order(by: "createAt", descending: true)
    }
}
