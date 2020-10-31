//
//  Product.swift
//  Platoun
//
//  Created by Flavian Mary on 05/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Product {
    let id: String
    let name: String
    let brandId: String
    let brandName: String
    let iconName: String
    let description: String
    let moreInfo: String?
    let shippingInfo: String?
    let price: Int
    let percentage: Int
    let categoryId: String
    let productAges: [String]
    let colors: [Color]
    var isLike: Bool
    var link: String
    let withReduc: Bool
    var alsoLike: [ProductSummary]
    
    struct Color: Equatable {
        let images: [String]
        let name: String
    }
    
    var groupPrice: Int {
        get { self.price.apply(percentage: self.percentage) }
    }
    
    static func setup(_ product: WebProduct) -> Product {
        return Product(
            id: product.id,
            name: product.title,
            brandId: product.brand?.id ?? "no Brand Id",
            brandName: product.brand?.title ?? "no Brand",
            iconName: product.pictureLink,
            description: product.description ?? "No Description",
            moreInfo: product.moreInformation,
            shippingInfo: product.shippingInfo,
            price: Int(product.price ?? 0),
            percentage: product.percentage,
            categoryId: product.categoryId,
            productAges: product.productAges.isEmpty ? ["∞"] : product.productAges,
            colors: product.productPictures.map { Color(images: $0.pictureLinks, name: $0.productColor.capitalized) },
            isLike: product.liked,
            link: product.buyLink,
            withReduc: product.withReduc,
            alsoLike: product.likeAlso.map { ProductSummary.setup($0) })
    }
    
    func toSummary() -> ProductSummary {
        return ProductSummary(
            id: self.id,
            name: self.name,
            description: self.description,
            brandId: self.brandId,
            brandName: self.brandName,
            pictureLink: self.iconName,
            price: self.price,
            percentage: self.percentage,
            categoryId: self.categoryId,
            productAges: self.productAges,
            link: self.link,
            isLike: self.isLike,
            withReduc: self.withReduc
            )
    }
}
