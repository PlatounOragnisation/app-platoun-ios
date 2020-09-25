//
//  Comment.swift
//  Platoun
//
//  Created by Flavian Mary on 23/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Comment: Codable {
    let id: String
    let text: String
    let images: [String]
    let createdAt: Date
    let createBy: String
    let authorName: String?
    let authorPhoto: String?
}
