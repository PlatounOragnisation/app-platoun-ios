//
//  Config.swift
//  Platoun
//
//  Created by Flavian Mary on 02/11/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

class Config {
    static let appStoreURL = URL(string: "https://apps.apple.com/us/app/platoun/id1534422969")!
    static let playStoreURL = URL(string: "https://play.google.com/store/apps/details?id=com.momunity")!
    static let communStoreURL = URL(string: "https://apps.apple.com/us/app/platoun/id1534422969")!
    
    static let env = ConfigEnv.shared
    
    class DefaultRemoteConfig {
        static let tokenAuthBackend = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJpb3MiLCJleHAiOjIyMzI3NDE2MDAsImlhdCI6MTYwMTYzNzczNX0.Yf9HIa-XTLOsD_vCEFOiwEKrk86QhRUHR88osvA7pCw"
        
        static let ios_minimalVersion = MinimalVersion(
            minimalVersion: "1.0.0",
            unauthorizedVersions: [])
    }
}

class InvitationConfig {    
    static let email =
"""
<p>\("invitation_text".localise())</p>
\(customTextForEmail)
"""
    
    static let customTextForEmail = "<p></p><p>Télécharge l'application gratuitement ici : <a href=\"\(Config.communStoreURL.absoluteString)\">Store</a></p>"
    
    static let sms =
"""
\("invitation_text".localise())
\(customText)
"""
    
    static let messenger = "\(Config.communStoreURL.absoluteURL)"

    static let whatsapp =
"""
\("invitation_text".localise())
\(customText)
"""
    
    static let customText = "Télécharge l'application gratuitement ici : \(Config.communStoreURL.absoluteURL)"
    
}
