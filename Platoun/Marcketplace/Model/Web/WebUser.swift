//
//  WebUser.swift
//  Platoun
//
//  Created by Flavian Mary on 04/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

public struct WebUser: Codable {
    public let userId: String
    public let name: String?
    public let profilePictureLink: String?
}
