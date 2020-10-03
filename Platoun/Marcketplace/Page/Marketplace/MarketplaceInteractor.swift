//
//  MarketplaceInteractor.swift
//  Platoun
//
//  Created by Flavian Mary on 05/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseAuth

class MarketplaceInteractor {
    func fetchCategories(_ completion: @escaping ([Category])->Void) {
        Interactor.shared.fetchCategories(completion)
    }
    
    func fetchData(_ completion: @escaping ([ProductSummary])->Void) {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userId = Auth.auth().currentUser?.uid ?? "JohnDoe"
        Interactor.shared.fetchProducts(userId: userId, completion)
    }
}
