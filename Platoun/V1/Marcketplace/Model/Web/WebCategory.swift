//
//  WebCategory.swift
//  Platoun
//
//  Created by Flavian Mary on 01/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct WebCategory: Codable {
    let id: String
    let title: String
    let brands: [WebBrand]
    let iconLink: String
    let sortOrder: Int
}
