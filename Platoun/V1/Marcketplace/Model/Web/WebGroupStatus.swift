//
//  WebGroupStatus.swift
//  Platoun
//
//  Created by Flavian Mary on 13/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct WebGroupStatus: Codable {
    let productName: String
    let productPicture: String
    let productBrand: String
    let status: Status
    let dateAdded: Date
    let dateValidated: Date?
    let maxUsers: Int
    let percentage: Int
    let promoCode: String?
    let promoCodeDateEnded: String?
    let buyLink: String
    let productId: String?
    let categoryId: String?
    
    enum Status: String, Codable {
        case pending = "PENDING"
        case validated = "VALIDATED"
        case failed = "FAILED"
    }
}
