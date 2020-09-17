//
//  WebPlatounError.swift
//  Platoun
//
//  Created by Flavian Mary on 21/04/2020.
//

import Foundation

struct WebPlatounError: Codable {
    let status: String
    let code: ErrorCode
    let error: String
    
    
    enum ErrorCode: String, Codable {
        case haveNoPromocode = "ErrGR"
        case limitOfPrivateGroup = "ErrPRGR"
        case limitOfPublicGroup = "ErrPGR"
        case limitOfPublicAndPrivateGroup = "ErrPPRGR"
    }
}
