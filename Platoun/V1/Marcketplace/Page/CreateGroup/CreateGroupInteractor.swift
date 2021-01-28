//
//  CreateGroupInteractor.swift
//  Platoun
//
//  Created by Flavian Mary on 06/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseAuth

class CreateGroupInteractor {
    func createGroup(code: String, userCount: Int, productId: String, _ completion: @escaping (String?, String?)->Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Interactor.shared.postGroup(
            code: code,
            userCount: userCount,
            userId: userId,
            productId: productId,
            completion)
    }
}
