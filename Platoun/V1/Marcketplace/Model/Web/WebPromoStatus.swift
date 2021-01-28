//
//  WebPromoStatus.swift
//  Platoun
//
//  Created by Flavian Mary on 13/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct WebPromoStatus: Codable {
    let productName: String
    let productPicture: String
    let productBrand: String
    let groupId: String
    let percentage: Int
    let promoCode: String
    let status: Status
    let dateValidated: Date
    let buyLink: String
    
    enum Status: String, Codable {
        case pending = "PENDING"
        case validated = "VALIDATED"
        case failed = "FAILED"
    }
}
