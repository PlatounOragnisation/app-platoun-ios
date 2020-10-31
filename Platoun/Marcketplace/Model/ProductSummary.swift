//
//  Product.swift
//  Platoun
//
//  Created by Flavian Mary on 05/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct ProductSummary {
    let id: String
    let name: String
    let description: String
    let brandId: String
    let brandName: String
    let pictureLink: String
    let price: Int
    let percentage: Int
    let categoryId: String
    let productAges: [String]
    let link: String
    var isLike: Bool
    let withReduc: Bool
        
    var groupPrice: Int {
        get { self.price.apply(percentage: self.percentage) }
    }
    
    static func setup(_ product: WebSummaryProduct) -> ProductSummary {

        return ProductSummary(
            id: product.id,
            name: product.title,
            description: product.description ?? "",
            brandId: product.brand.id ?? "",
            brandName: product.brand.title ?? "No Brand",
            pictureLink: product.pictureLink,
            price: Int(product.price ?? 0),
            percentage: product.percentage,
            categoryId: product.categoryId,
            productAges: product.productAges.isEmpty ? ["∞"] : product.productAges,
            link: product.buyLink ?? "",
            isLike: product.liked,
            withReduc: product.withReduc
            )
    }
}
