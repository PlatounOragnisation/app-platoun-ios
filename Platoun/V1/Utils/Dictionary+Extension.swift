//
//  Dictionary+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 04/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
    func merged(dict: [Key: Value]) -> [Key: Value]{
        var newD = self
        for (k, v) in dict {
            newD.updateValue(v, forKey: k)
        }
        return newD
    }
}
