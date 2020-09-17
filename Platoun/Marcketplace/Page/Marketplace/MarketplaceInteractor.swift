//
//  MarketplaceInteractor.swift
//  Platoun
//
//  Created by Flavian Mary on 05/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

class MarketplaceInteractor {
    func fetchCategories(_ completion: @escaping ([Category])->Void) {
        Interactor.shared.fetchCategories(completion)
    }
    
    func fetchData(_ completion: @escaping ([ProductSummary])->Void) {
        Interactor.shared.fetchProducts(userId: HttpServices.shared.userId, completion)
    }
}
