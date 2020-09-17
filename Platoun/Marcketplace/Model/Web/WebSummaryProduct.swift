//
//  WebSummaryProduct.swift
//  Platoun
//
//  Created by Flavian Mary on 01/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct WebSummaryProduct: Codable {
    let id: String
    let title: String
    let description: String?
    let pictureLink: String
    let percentage: Int
    let brand: WebBrand
    let price: Double?
    let productAges: [String]
    let categoryId: String
    let buyLink: String?
    let liked: Bool
}
