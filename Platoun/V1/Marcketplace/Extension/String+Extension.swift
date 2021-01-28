//
//  String+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 28/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation


extension Optional where Wrapped == String {
    var trimed: String? {
        get { (self?.isEmpty ?? true) ? nil : self }
    }
}

extension String {

    subscript (i: Int) -> String? {
        if self.count <= i { return nil }
        return "\([Character](self)[i])"
    }
}
