//
//  FirestorePost.swift
//  Platoun
//
//  Created by Flavian Mary on 04/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCrashlytics

extension FirestoreUtils {
    struct Posts: FirestoreCollection {
        static let collectionName: String = "posts"
        
        fileprivate static let votes = "votes"
        fileprivate static let voteUserId = "userId"
        fileprivate static let createBy = "createBy"
        fileprivate static let votedAt = "votedAt"
        
        static func updatePosts(uid: String, name: String, photo: String, sema: DispatchSemaphore) throws {
            let db = Firestore.firestore()
            
            var error: Error?
            var refs: [DocumentReference] = []
            db
                .collection(Posts.collectionName)
                .whereField(Posts.createBy, isEqualTo: uid)
                .getDocuments { (snaps, fetchError) in
                    if let snaps = snaps {
                        refs = snaps.documents.map { $0.reference }
                    } else if let fetchError = fetchError{
                        error = fetchError
                    }
                    sema.signal()
                }
            
            sema.wait()
            
            if refs.count > 0 {
                try batchUpdateName(db: db, refs: refs, name: name, photo: photo, sema: sema)
            } else if let error = error {
                Crashlytics.crashlytics().record(error: error)
                throw error
            }
        }
        
        private static func batchUpdateName(db: Firestore, refs: [DocumentReference], name: String, photo: String, sema: DispatchSemaphore, index: Int = 0) throws {
            if index == refs.count { return }
            let start = index
            let end = min(start+20, refs.count)
            
            let batch = db.batch()
            let subRefs = refs[start..<end]
            subRefs.forEach { ref in
                batch.updateData(
                    [
                        "authorName": name,
                        "authorPhoto": photo
                    ], forDocument: ref)
            }
            var errorBatch: Error?
            batch.commit { (batchError) in
                errorBatch = batchError
                sema.signal()
            }
            sema.wait()
            if let errorBatch = errorBatch {
                Crashlytics.crashlytics().record(error: errorBatch)
                throw errorBatch
            } else {
                try batchUpdateName(db: db, refs: refs, name: name, photo: photo, sema: sema, index: end)
            }
        }
        
        static func savePost(post: Post, completion: @escaping (Result<Void,Error>)->Void) {
            let db = Firestore.firestore()
            do {
                try db
                    .collection(Posts.collectionName).document(post.postId)
                    .setData(from: post, merge: true) { error in
                    if let error = error {
                        Crashlytics.crashlytics().record(error: error)
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
        
        static func deletePost(postId: String) {
            Firestore.firestore()
                .collection(Posts.collectionName).document(postId)
                .delete()
        }
        
        static func toogleVote(postId: String, userUid: String) {
            let db = Firestore.firestore()
            let sfReference = db.collection(Posts.collectionName).document(postId)
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let sfDocument: DocumentSnapshot
                do {
                    try sfDocument = transaction.getDocument(sfReference)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                let votes = sfDocument.data()?[Posts.votes] as? [[String: Any]]
                if let elem = votes?.first(where: { ($0[Posts.voteUserId] as? String) == userUid }) {
                    transaction.updateData([Posts.votes: FieldValue.arrayRemove([elem])], forDocument: sfReference)
                } else {
                    let vote: [String:Any] = [
                        Posts.voteUserId: userUid,
                        Posts.votedAt: Timestamp(date: Date())
                    ]
                    transaction.updateData([Posts.votes: FieldValue.arrayUnion([vote])], forDocument: sfReference)
                }
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction toogle vote failed: \(error)")
                } else {
                    print("Transaction toogle vote successfully committed!")
                }
            }
        }
    }
}
