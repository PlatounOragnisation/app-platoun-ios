//
//  Category.swift
//  Platoun
//
//  Created by Flavian Mary on 01/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Category: Hashable {
    let id: String
    let name: String
    let icon: String
    let brands: [String]
    let order: Int
        
    static func setup(_ web: WebCategory) -> Category {
        return Category(
            id: web.id,
            name: web.title,
            icon: web.iconLink,
            brands: web.brands.map({ $0.title ?? "No Brand name" }),
            order: web.sortOrder
        )
    }
}
