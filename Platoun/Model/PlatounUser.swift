//
//  PlatounUser.swift
//  Platoun
//
//  Created by Flavian Mary on 18/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation


struct PlatounUser: Codable {
    let uid: String
    let fcmToken: String?
    let displayName: String?
    let photoUrl: String?
    
    init(uid: String, fcmToken: String?, displayName: String?, photoUrl: String?) {
        self.uid = uid
        self.fcmToken = fcmToken
        self.displayName = displayName
        self.photoUrl = photoUrl
        
        self.groupNotification = true
        self.trendsNotification = true
        self.newsNotification = true
    }
    
    var groupNotification: Bool
    var trendsNotification: Bool
    var newsNotification: Bool
    
    
    init(uid: String, fcmToken: String?, displayName: String?, photoUrl: String?, groupNotification: Bool, trendsNotification: Bool, newsNotification: Bool) {
        self.uid = uid
        self.fcmToken = fcmToken
        self.displayName = displayName
        self.photoUrl = photoUrl
        
        self.groupNotification = true
        self.trendsNotification = true
        self.newsNotification = true
    }
    
    static func getDicName(_ name: String) -> [String: String]{
        var dic = [String:String]()
        for index in 0..<10 {
            dic["letter\(index)"] = name[index]?.lowercased() ?? ""
        }
        return dic
    }
}

struct PlatounUserComplet: Codable {
    let uid: String
    let fcmToken: String?
    let displayName: String?
    let photoUrl: String?
    
    init(uid: String, fcmToken: String?, displayName: String?, photoUrl: String?) {
        self.uid = uid
        self.fcmToken = fcmToken
        self.displayName = displayName
        self.photoUrl = photoUrl
        
        self.groupNotification = true
        self.trendsNotification = true
        self.newsNotification = true
        
        let dic = PlatounUser.getDicName(displayName ?? "")
        self.letter0 = dic["letter0"] ?? ""
        self.letter1 = dic["letter1"] ?? ""
        self.letter2 = dic["letter2"] ?? ""
        self.letter3 = dic["letter3"] ?? ""
        self.letter4 = dic["letter4"] ?? ""
        self.letter5 = dic["letter5"] ?? ""
        self.letter6 = dic["letter6"] ?? ""
        self.letter7 = dic["letter7"] ?? ""
        self.letter8 = dic["letter8"] ?? ""
        self.letter9 = dic["letter9"] ?? ""
    }
    
    var groupNotification: Bool
    var trendsNotification: Bool
    var newsNotification: Bool
    
    let letter0: String
    let letter1: String
    let letter2: String
    let letter3: String
    let letter4: String
    let letter5: String
    let letter6: String
    let letter7: String
    let letter8: String
    let letter9: String
}


struct PlatounUserCompact: Codable {
    let uid: String
    let fcmToken: String?
    let displayName: String?
    let photoUrl: String?
}
