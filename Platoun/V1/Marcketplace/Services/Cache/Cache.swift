//
//  Cache.swift
//  Platoun
//
//  Created by Flavian Mary on 07/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import UIKit

let cache = Cache<NewApi.v1, Codable>()

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval

    
    init(dateProvider: @escaping () -> Date = Date.init, entryLifetime: TimeInterval = 5 * 60) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
    }
    
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}
