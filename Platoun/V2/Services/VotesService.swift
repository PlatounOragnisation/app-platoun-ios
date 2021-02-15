//
//  VotesService.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseCrashlytics

final class VotesService {
    static let shared = VotesService()
    
    private init() {}
    
    let DB_REF: Firestore = Firestore.firestore()

    
    let POST_DB_REF = PostService.shared.POST_DB_REF
    let USER_DB_REF = UserService.shared.USER_DB_REF
    
    func seePost(user: UserV2, post: PostV2, completion: @escaping ()->Void) {
        let currentUserRed = USER_DB_REF.document(user.id).collection("see").document(post.postId)

        let batch = DB_REF.batch()
        batch.setData(["hasSee": true], forDocument: currentUserRed)
        batch.commit() { err in
            if let err = err {
                Crashlytics.crashlytics().record(error: err)
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
            completion()
        }
    }
    
    func likePost(user: UserV2, post: PostV2, surkiff: Bool,completion: @escaping ()->Void) {
        let collectionKey = surkiff ? "likes" : "surkiffs"
        let postRef = POST_DB_REF.document(post.postId)
        let userCreatorRef = USER_DB_REF.document(post.user.id)
        let currentUserRed = USER_DB_REF.document(user.id).collection(collectionKey).document(post.postId)
        
        let voteProductRef = postRef.collection(collectionKey).document(user.id)
        
        let batch = DB_REF.batch()
        
        // count Post like
        let postKey = surkiff ? PostV2.ProductV2InfoKey.superLikesCount : PostV2.ProductV2InfoKey.likesCount
        batch.updateData([postKey: FieldValue.increment(Int64(1))], forDocument: postRef)
        
        // see post
        batch.setData(["hasSee": true], forDocument: USER_DB_REF.document(user.id).collection("see").document(post.postId))
        
        // like post user info
        batch.setData(user.toUserVote().infoUser(), forDocument: voteProductRef, merge: true)

        // Point User creator
        let userKey = surkiff ? UserV2.UserInfoKey.superLikeReceived : UserV2.UserInfoKey.likeReceived
        batch.updateData([userKey: FieldValue.increment(Int64(1))], forDocument: userCreatorRef)

        batch.setData(post.toProductVote().userInfo(), forDocument: currentUserRed)
        
        batch.commit() { err in
            if let err = err {
                Crashlytics.crashlytics().record(error: err)
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
            completion()
        }
    }
}
