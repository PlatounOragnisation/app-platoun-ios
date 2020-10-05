//
//  FirestoreComment.swift
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
    struct Comments: FirestoreCollection {
        static let collectionName: String = "comments"
        
        fileprivate static let commentsCount = "commentsCount"
        fileprivate static let createBy = "createBy"
        
        static func updateComments(uid: String, name: String, photo: String, sema: DispatchSemaphore) throws {
            let db = Firestore.firestore()
            
            var error: Error?
            var refs: [DocumentReference] = []
            db
                .collectionGroup(Comments.collectionName)
                .whereField(Comments.createBy, isEqualTo: uid)
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
        
        static func getComments(postId: String, completion: @escaping (Result<[Comment], Error>)->Void) {
            Firestore.firestore()
                .collection(Posts.collectionName).document(postId)
                .collection(Comments.collectionName)
                .getDocuments { (query, error) in
                    guard let query = query else {
                        completion(Result.failure(error ?? FirestoreUtilsError.noErrorGetPost(postId: postId)))
                        return
                    }
                    
                    let comments = query.documents.compactMap { try? $0.data(as: Comment.self) }
                    completion(Result.success(comments))
                }
        }
        
        static func addComment(postId: String, comment: Comment, completion: @escaping (Bool)->Void) {
            let db = Firestore.firestore()
            let postReference = db.collection(Posts.collectionName).document(postId)
            let commentsReference = postReference.collection(Comments.collectionName).document(comment.id)
            guard let commentData = try? Firestore.Encoder().encode(comment) else { completion(false); return }
            
            let batch = db.batch()
            
            batch.updateData([Comments.commentsCount: FieldValue.increment(Int64(1))], forDocument: postReference)
            batch.setData(commentData, forDocument: commentsReference)
            
            batch.commit { (error) in
                if let err = error {
                    Crashlytics.crashlytics().record(error: err)
                    print("Error writing batch \(err)")
                    completion(false)
                } else {
                    print("Batch write succeeded.")
                    completion(true)
                }
            }
        }
    }
}
