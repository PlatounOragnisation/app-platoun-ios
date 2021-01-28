//
//  Array+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 04/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

extension Array {
    func getOrNil(_ index: Int) -> Element? {
        guard index < self.count else { return nil }
        return self[index]
    }
    
    func merged(with others: [Element], key: (Element) -> String ) -> [Element] {
        var previous = self
        others.forEach { (e) in
            if let index = previous.firstIndex(where: { key(e) == key($0) }) {
                previous[index] = e
            } else {
                previous.append(e)
            }
        }
        return previous
    }
}
