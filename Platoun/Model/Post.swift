//
//  Post.swift
//  Platoun
//
//  Created by Flavian Mary on 05/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Post: Codable {
    let postId: String
    let title: String
    let text: String
    let images: [String]
    let category: PostType
    let language: LanguageType
    let createAt: Date
    let createBy: String
    let votes: [Vote]
    let comments: [Comment]
    
    static func create(by userId: String, for postId: String, text: String, images: [String], category: PostType, language: LanguageType, createAt: Date) -> Post {
        let post = Post(postId: postId, title: "", text: text, images: images, category: category, language: language, createAt: createAt, createBy: userId, votes: [], comments: [])
        return post
    }
    
    struct Vote: Codable {
        let userId: String
        let votedAt: Date
    }
    
    struct Comment: Codable {
        let text: String
        let images: [String]
        let createdAt: Date
        let userId: String
    }
    
    enum PostType: String, Codable, CaseIterable {
        case suggestion = "#Suggestion"
        case question = "#Question"
        //        case review = "#Review"
    }
    
    enum LanguageType: String, Codable, CaseIterable {
        case french = "#Français"
        case german = "#Allemand"
        case english = "#International (Anglais)"
    }
}
