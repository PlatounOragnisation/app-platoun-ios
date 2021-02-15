//
//  Int+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 10/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation

extension Int {
    func concat() -> String {
        if self >= 1000000 {
            let result = Double(self)/1000000.0
            return String(format: "%.1f", result)+"M"
        } else if self >= 1000 {
            let result = Double(self)/1000.0
            return String(format: "%.1f", result)+"K"
        } else {
            return "\(self)"
        }
    }
}
