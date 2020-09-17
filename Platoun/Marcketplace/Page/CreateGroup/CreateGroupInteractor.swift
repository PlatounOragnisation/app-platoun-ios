//
//  CreateGroupInteractor.swift
//  Platoun
//
//  Created by Flavian Mary on 06/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

class CreateGroupInteractor {
    func createGroup(code: String, userCount: Int, productId: String, _ completion: @escaping (String?, String?)->Void) {
        Interactor.shared.postGroup(
            code: code,
            userCount: userCount,
            userId: HttpServices.shared.userId,
            productId: productId,
            completion)
    }
}
