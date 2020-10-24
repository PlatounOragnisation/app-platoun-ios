//
//  Error+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 21/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

public func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}

extension Equatable where Self : Error {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
}
