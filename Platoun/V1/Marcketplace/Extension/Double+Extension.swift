//
//  Double+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 08/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

extension Int {
    
    func apply(percentage: Int) -> Int {
        let doubleValue = Double(self) * (1-Double(percentage) / 100)
        return Int(doubleValue.rounded())
    }
    
}
