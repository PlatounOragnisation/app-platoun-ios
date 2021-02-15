//
//  PostV2.swift
//  Platoun
//
//  Created by Flavian Mary on 28/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct PostV2 {
    let user: UserVote
    let name: String
    let comment: String
    let postId: String
    let imageFileURL: String
    let likesCount: Int
    let superLikesCount: Int
    let timestamp: Int
        
    enum ProductV2InfoKey {
        static let userName = "userName"
        static let userId = "userId"
        static let userImage = "userImage"
        static let name = "name"
        static let comment = "comment"
        static let imageFileURL = "imageFileURL"
        static let likesCount = "likesCount"
        static let superLikesCount = "superLikesCount"
        static let timestamp = "timestamp"
    }
    
    init(postId: String, name: String, comment: String, imageFileURL: String, user: UserV2) {
        self.postId = postId
        self.name = name
        self.comment = comment
        self.user = user.toUserVote()
        self.imageFileURL = imageFileURL
        self.likesCount = 0
        self.superLikesCount = 0
        self.timestamp = Int(Date().timeIntervalSince1970 * 1000)
    }
    
    init(postId: String, name: String, comment: String, imageFileURL: String, user: UserVote, likesCount: Int, superLikesCount: Int, timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)) {
        self.postId = postId
        self.name = name
        self.comment = comment
        self.user = user
        self.imageFileURL = imageFileURL
        self.likesCount = likesCount
        self.superLikesCount = superLikesCount
        self.timestamp = timestamp
    }
    
    init?(postId: String, postInfo: [String:Any]) {
        guard let imageFileURL = postInfo[ProductV2InfoKey.imageFileURL] as? String,
              let name = postInfo[ProductV2InfoKey.name] as? String,
              let comment = postInfo[ProductV2InfoKey.comment] as? String,
              let userId = postInfo[ProductV2InfoKey.userId] as? String,
              let likesCount = postInfo[ProductV2InfoKey.likesCount] as? Int,
              let superLikesCount = postInfo[ProductV2InfoKey.superLikesCount] as? Int,
              let timestamp = postInfo[ProductV2InfoKey.timestamp] as? Int else {
            return nil
        }
        let userName = postInfo[ProductV2InfoKey.userName] as? String ?? ""
        let userImage = postInfo[ProductV2InfoKey.userImage] as? String ?? ""
        let user = UserVote(id: userId, name: userName, image: userImage)
        self = PostV2(postId: postId, name: name, comment: comment, imageFileURL: imageFileURL, user: user, likesCount: likesCount, superLikesCount: superLikesCount, timestamp: timestamp)
    }
    
    func userInfo() -> [String: Any] {
        [
            ProductV2InfoKey.imageFileURL: self.imageFileURL,
            ProductV2InfoKey.name: self.name,
            ProductV2InfoKey.comment: self.comment,
            ProductV2InfoKey.userId: self.user.id,
            ProductV2InfoKey.userImage: self.user.image,
            ProductV2InfoKey.userName: self.user.name,
            ProductV2InfoKey.likesCount: self.likesCount,
            ProductV2InfoKey.superLikesCount: self.superLikesCount,
            ProductV2InfoKey.timestamp: self.timestamp
        ]
    }
    
    func toProductVote() -> ProductVote {
        ProductVote(postId: self.postId, image: self.imageFileURL)
    }
}
