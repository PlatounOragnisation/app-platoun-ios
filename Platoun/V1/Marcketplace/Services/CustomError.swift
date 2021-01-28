//
//  CustomError.swift
//  Platoun
//
//  Created by Flavian Mary on 18/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import Alamofire

enum CustomError: Error {
    case parsingError
    case platounError(error: WebPlatounError)
    case http(status: Int, data: String?, error: AFError?)
    case unknown(status: Int, error: AFError?)
}
