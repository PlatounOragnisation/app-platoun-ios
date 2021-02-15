//
//  UserVote.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation

struct UserVote {
    let id: String
    let name: String
    let image: String
    
    
    enum UserVoteKey {
        static let name = "name"
        static let image = "image"
    }
    
    
    init(id: String, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    func infoUser() -> [String: Any] {
        [
            UserVoteKey.name: self.name,
            UserVoteKey.image: self.image
        ]
    }
}
