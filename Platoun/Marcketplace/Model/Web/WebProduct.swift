//
//  Products.swift
//  Platoun
//
//  Created by Flavian Mary on 01/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct WebProduct: Codable {
    let id: String
    let title: String
    let pictureLink: String
    let percentage: Int
    let description: String?
    let brand: WebBrand?
    let price: Double?
    let productAges: [String]
    let categoryId: String
    let moreInformation: String?
    let shippingInfo: String?
    let buyLink: String
    let productPictures: [ProductPicture]
    let liked: Bool
    let likeAlso: [WebSummaryProduct]
    
    struct ProductPicture: Codable {
        let pictureLinks: [String]
        let productColor: String
    }
}
