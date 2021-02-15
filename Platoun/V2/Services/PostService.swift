//
//  PostService.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseCrashlytics

final class PostService {
    static let shared = PostService()
    
    private init() {}
    
    let DB_REF: Firestore = Firestore.firestore()
    
    let POST_DB_REF: CollectionReference = Firestore.firestore().collection("version").document("v2").collection("posts")
    
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("v2").child("photos")
    
    private func getSeePost(user: UserV2?, completion: @escaping ([String])->Void) {
        let query = UserService.shared.USER_DB_REF.document(user.id).collection("see")
        
        query.getDocuments { (snapshot, error) in
            let postIds: [String] = (snapshot?.documents ?? []).compactMap { $0.documentID }
            completion(postIds)
        }
    }
    
    private func getPostLimit(user: UserV2, limite: Int, postIds: [String], posts:[PostV2] = [], lastSnapshot: DocumentSnapshot?, completion: @escaping ([PostV2], DocumentSnapshot?)->Void) {
        var postQuery: Query = POST_DB_REF
            .order(by: PostV2.ProductV2InfoKey.timestamp, descending: true)
        
        if let lastSnapshot = lastSnapshot {
            postQuery = postQuery
                .start(afterDocument: lastSnapshot)
        }
        
        postQuery = postQuery
            .limit(to: limite)

        
        postQuery.getDocuments { (snapshot, error) in
            let newPosts: [PostV2] = (snapshot?.documents ?? []).compactMap {
                PostV2(postId: $0.documentID, postInfo: $0.data())
            }
            let filteredPost = newPosts.filter { !postIds.contains($0.postId) && $0.user.id != user.id }
            
            let total = filteredPost+posts
            if newPosts.count < limite {
                print("PostService => fetch \(total.count) posts and is End")
                completion(total, nil)
            } else if total.count >= limite || (newPosts.count - filteredPost.count <= 10){
                print("PostService => fetch \(total.count) posts and is not End")
                completion(total, (snapshot?.documents ?? []).last)
            } else {
                self.getPostLimit(user: user, limite: limite, postIds: postIds, posts: total, lastSnapshot: (snapshot?.documents ?? []).last, completion: completion)
            }
        }
    }
    
    func getRecentPost(user: UserV2?, limit: Int, lastSnapshot: DocumentSnapshot?, completion: @escaping ([PostV2], DocumentSnapshot?)->Void) {
        self.getSeePost(user: user) { (postIdsAlreadySeen) in
            self.getPostLimit(user: user, limite: limit, postIds: postIdsAlreadySeen, lastSnapshot: lastSnapshot, completion: completion)
        }
    }
    
    func uploadImage(user: UserV2, image: UIImage, name: String, comment: String, completion: @escaping ()->Void, progress:((Double)->Void)? = nil) {
        let postDatabaseRef = POST_DB_REF.document()
        let imageKey = postDatabaseRef.documentID
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(imageKey).jpg")
        
        let scaledImage: UIImage = image.scale(newWidth: 640)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.9) else { return }
        
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Uploading \(imageKey).jpg... \(percentComplete)% complete")
            progress?(percentComplete)
        }
        
        
        uploadTask.observe(.success) { (snapshot) in            
            snapshot.reference.downloadURL { (url, error) in
                guard let url = url else { return }
                
                let imageFileURL = url.absoluteString
                
                let post = PostV2(postId: postDatabaseRef.documentID, name: name, comment: comment, imageFileURL: imageFileURL, user: user)
                
                let batch = self.DB_REF.batch()
                
                batch.setData(post.userInfo(), forDocument: postDatabaseRef)
                batch.updateData(
                    [UserV2.UserInfoKey.suggestionCount: FieldValue.increment(Int64(1))]
                    , forDocument: UserService.shared.USER_DB_REF.document(user.id))
                
                batch.setData(post.toProductVote().userInfo(),
                              forDocument: UserService.shared.USER_DB_REF.document(user.id).collection("postCreated").document(post.postId))
                
                batch.commit() { err in
                    if let err = err {
                        Crashlytics.crashlytics().record(error: err)
                        print("Error writing batch \(err)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }
            }
            
            completion()
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
}
