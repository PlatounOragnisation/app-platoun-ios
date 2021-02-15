//
//  UserV2.swift
//  Platoun
//
//  Created by Flavian Mary on 06/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation


struct UserV2 {
    let id: String
    let fcmToken: String?
    
    let name: String?
    let imageProfilURL: String?

    let suggestionCount: Int
    let likeReceived: Int
    let superLikeReceived: Int
    
    var point: Int {
        get { likeReceived + (superLikeReceived * 3) }
    }
    
    let timestampPosition: TimestampPosition?
    
    struct TimestampPosition {
        let lastSee: Int
        let firstSee: Int
    }
    
    enum UserInfoKey {
        static let fcmToken = "fcmToken"
        static let name = "displayName"
        static let imageProfilURL = "photoUrl"
        
        static let suggestionCount = "suggestionCount"
        static let likeReceived = "likeReceived"
        static let superLikeReceived = "superLikeReceived"
        
        static let timestampLastSee = "timestampLastSee"
        static let timestampFirstSee = "timestampFirstSee"
    }
    
    init(id: String, fcmToken: String?, name: String?, imageProfilURL: String?, suggestionCount: Int, likeReceived: Int, superLikeReceived: Int,  timestampLastSee: Int?, timestampFirstSee: Int?) {
        self.id = id
        self.fcmToken = fcmToken
        self.name = name
        self.imageProfilURL = imageProfilURL
        self.suggestionCount = suggestionCount
        self.likeReceived = likeReceived
        self.superLikeReceived = superLikeReceived
        
        if let last = timestampLastSee, let first = timestampFirstSee {
            self.timestampPosition = TimestampPosition(lastSee: last, firstSee: first)
        } else {
            self.timestampPosition = nil
        }
    }
    
    init?(userId: String, userInfo: [String:Any]) {
        let fcmToken = userInfo[UserInfoKey.fcmToken] as? String
        let name = userInfo[UserInfoKey.name] as? String
        let imageProfilURL = userInfo[UserInfoKey.imageProfilURL] as? String
        
        let suggestionCount = userInfo[UserInfoKey.suggestionCount] as? Int ?? 0
        let likeReceived = userInfo[UserInfoKey.likeReceived] as? Int ?? 0
        let superLikeReceived = userInfo[UserInfoKey.superLikeReceived] as? Int ?? 0
        let timestampLastSee = userInfo[UserInfoKey.timestampLastSee] as? Int
        let timestampFirstSee = userInfo[UserInfoKey.timestampFirstSee] as? Int
            
        self = UserV2(id: userId, fcmToken: fcmToken, name: name, imageProfilURL: imageProfilURL, suggestionCount: suggestionCount, likeReceived: likeReceived, superLikeReceived: superLikeReceived, timestampLastSee: timestampLastSee, timestampFirstSee: timestampFirstSee)
    }
    
    func toUserVote() -> UserVote {
        UserVote(id: self.id, name: self.name ?? "", image: self.imageProfilURL ?? "")
    }
}
