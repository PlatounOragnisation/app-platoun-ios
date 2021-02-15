//
//  UserDefaultsServices.swift
//  Platoun
//
//  Created by Flavian Mary on 14/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    
    func getSeePost() -> [String] {
        UserDefaults.standard.array(forKey: "seeingPostUnconnected")
    }
    
    func passPost(post: PostV2) {
        var seePost = getSeePost()
        seePost.append(post.postId)
        UserDefaults.standard.set(seePost, forKey: "seeingPostUnconnected")
    }
    
    func likePost(post: PostV2, surkiff: Bool) {
        passPost(post: post)
        
    }
}
