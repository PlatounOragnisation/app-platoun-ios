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
    
    func fetchDataByCategory(uid: String?, _ completion: @escaping ([MarketplaceViewController.Section])->Void) {
        
        var res: [Category:[ProductSummary]] = [:]
        
        Interactor.shared.fetchCategories { (categories) in
            categories.forEach { res[$0] = [] }
            Interactor.shared.fetchProducts(userId: uid ?? "JohnDoe") { (products) in
                products.forEach { (product) in
                    if let category = categories.first(where: { $0.id == product.categoryId }) {
                        res[category]?.append(product)
                    }
                }
                
                let result = res.reduce([MarketplaceViewController.Section](), {
                    return $0 + [MarketplaceViewController.Section(category: $1.key, products: $1.value)]
                })
                
                completion(result)
            }
        }
    }
}
