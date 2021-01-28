//
//  WebSummaryNotification.swift
//  Platoun
//
//  Created by Flavian Mary on 02/05/2020.
//

import Foundation

public struct WebSummaryNotification: Codable {
    public let id: String
    public let type: NotifType?
    public let time: Date
    public let userId: String?
    public let platounGroupId: String?
    public let platounGroupStatus: Status?
    public let author: Author?
    

    public struct Author: Codable {
        public let id: String
        public let nickname: String?
    }
    
    public enum Status: String, Codable {
        case pending = "PENDING"
        case validated = "VALIDATED"
        case failed = "FAILED"
    }
    
    public enum NotifType: String, Codable {
        case status = "PLATOUN_STATUS"
        case invit = "PLATOUN_INVITATION"
        case chat = "PUBLIC_CHAT_INVITE"
        
        public var name: String {
            switch self {
            case .status:
                return "status de group"
            case .invit:
                return "invitation"
            case .chat:
                return "invitation a rejoindre un chat public"
            }
        }
    }
}
