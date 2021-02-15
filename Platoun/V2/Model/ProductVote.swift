//
//  ProductVote.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation


struct ProductVote{
    let postId: String
    let image: String
    
    enum ProductVoteKey {
        static let image = "image"
    }
    
    
    init(postId: String, image: String) {
        self.postId = postId
        self.image = image
    }
    
    init?(postId: String, userInfo: [String: Any]) {
        guard let image = userInfo[ProductVoteKey.image] as? String else {
            return nil
        }
        
        self = ProductVote(postId: postId, image: image)
    }
    
    func userInfo() -> [String: Any] {
        [
            ProductVoteKey.image: self.image
        ]
    }
}
