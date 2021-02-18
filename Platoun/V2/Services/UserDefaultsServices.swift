//
//  UserDefaultsServices.swift
//  Platoun
//
//  Created by Flavian Mary on 14/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseAuth

extension UserDefaults {
    
    func hasAlreadyVote() -> Bool {
        let userIdBis = Auth.auth().currentUser?.uid ?? "anonyme"
        let key = "love_swipe_feature_voted_\(userIdBis)"
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func saveVote(saidYes: Bool) {
        let userIdBis = Auth.auth().currentUser?.uid ?? "anonyme"
        let key = "love_swipe_feature_voted_\(userIdBis)"
        UserDefaults.standard.setValue(true, forKey: key)//save only if user have voted
    }
    
    
    func getSeePost() -> [String] {
        UserDefaults.standard.array(forKey: "seeingPostUnconnected") as? [String] ?? []
    }
    
    func passPost(post: PostV2) {
        var seePost = getSeePost()
        seePost.append(post.postId)
        UserDefaults.standard.set(seePost, forKey: "seeingPostUnconnected")
    }
    
    func likePost(post: PostV2, surkiff: Bool) {
        passPost(post: post)
        let key = surkiff ? "surkiff" : "like"
        var oldPost = getPost(surkiff: surkiff)
        oldPost.append(post)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(oldPost), forKey: "\(key)PostUnconnected")
    }
    
    func getPost(surkiff: Bool) -> [PostV2] {
        let key = surkiff ? "surkiff" : "like"
        guard let data = UserDefaults.standard.value(forKey: "\(key)PostUnconnected") as? Data else { return [] }
        
        return (try? PropertyListDecoder().decode([PostV2].self, from: data)) ?? []
    }
}
