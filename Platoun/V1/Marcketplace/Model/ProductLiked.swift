//
//  ProductLiked.swift
//  Platoun
//
//  Created by Flavian Mary on 24/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct ProductLiked {
    let id: String
    let title: String
    let pictureLink: String
    let brandName: String
    let buyLink: String
    
    static func setup(from web: WebFavoritProducts) -> ProductLiked {
        return ProductLiked(id: web.id, title: web.title, pictureLink: web.pictureLink, brandName: web.brandName, buyLink: web.buyLink)
    }
}
