//
//  WebJoin.swift
//  Platoun
//
//  Created by Flavian Mary on 13/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct WebJoin: Codable {
    let productName: String
    let productPicture: String
    let productBrand: String
    let percentage: Int
    let promoCode: String?
    let buyLink: String?
    let promoCodeDateEnded: Date?
    let status: Status
    
    enum Status: String, Codable {
        case pending = "PENDING"
        case validated = "VALIDATED"
        case failed = "FAILED"
    }
}
