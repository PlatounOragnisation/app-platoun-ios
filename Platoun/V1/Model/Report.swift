//
//  Report.swift
//  Platoun
//
//  Created by Flavian Mary on 19/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

struct Report: Codable {
    let reportId: String
    let reportedBy: String
    let reportedAt: Date
    let postId: String
}
