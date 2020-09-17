//
//  WrappedKey.swift
//  Platoun
//
//  Created by Flavian Mary on 07/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
}
