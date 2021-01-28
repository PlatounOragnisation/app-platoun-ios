//
//  Entry.swift
//  Platoun
//
//  Created by Flavian Mary on 07/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

extension Cache {
    final class Entry {
        let value: Value
        let expirationDate: Date

        init(value: Value, expirationDate: Date) {
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}
