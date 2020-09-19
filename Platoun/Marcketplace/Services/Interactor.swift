//
//  Api.swift
//  Platoun
//
//  Created by Flavian Mary on 06/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

class Interactor {
    static let shared = Interactor()
    
    enum LikeState {
        case yes, no, loading
        
        var isLike: Bool {
            return self == .yes
        }
    }
    
//    var products = [String:[ProductSummary]]()
    var productLike: [String:[String:LikeState]] = [:]
    
    func respondNotif(userId: String, userInviterId: String, groupId: String, accepted: Bool, _ completion: @escaping (Bool, Bool, String?, String?)->Void) {
        
        struct WebNotifResult: Codable {
            let groupStatus: Status?
            let promoCode: String?
            let buyLink: String?
            let message: String
            
            enum Status: String, Codable {
                case pending = "PENDING"
                case validated = "VALIDATED"
                case failed = "FAILED"
            }
        }
        
        NewApi.v1.respondNotif(userId: userId, userInviterId: userInviterId, groupId: groupId, accepted: accepted)
            .response { (result: Result<WebNotifResult, CustomError>) in
                switch result {
                case .success(let web):
                    completion(web.message.contains("successfully"), web.groupStatus == .validated, web.promoCode, web.buyLink)
                case .failure(let error):
                    print(error)
                    completion(false, false, nil, nil)
                }
        }
    }
    func sendNotif(userId: String, inviteUserId: String, groupId: String, _ completion: @escaping (Bool)->Void) {
        NewApi.v1.sendNotif(userId: userId, inviteUserId: inviteUserId, groupId: groupId)
            .response { (result: Result<String, CustomError>) in
                switch result {
                case .success(let web):
                    completion(web.contains("SUCCESS"))
                case .failure(_):
                    completion(false)
                }
        }
    }
    
    func showNotif(userId: String, sendUserId: String, groupId: String, _ completion: @escaping (WebNotification?)->Void) {
        NewApi.v1.showNotif(userId: userId, sendUserId: sendUserId, groupId: groupId)
            .response { (result: Result<WebNotification, CustomError>) in
                switch result {
                case .success(let web):
                    completion(web)
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
        }
    }
    
//    func fetchUsers(_ completion: @escaping ([String])-> Void) {
//        struct UserIds: Codable {
//            let id: String
//        }
//
//        NewApi.v1.getUsers
//            .response { (result: Result<[UserIds], CustomError>) in
//                switch result {
//                case .success(let web):
//                    completion(web.map { $0.id })
//                case .failure(let customError):
//                    completion([])
//                }
//        }
//    }
    
    func fetchMomunityUsers(userId: String, _ completion: @escaping ([UserMomunity])->Void) {
        //TODO get users
        completion([])
//        NewApi.v1.getFriends(userId: userId)
//            .response { (result: Result<[WebUser], CustomError>) in
//                switch result {
//                case .success(let web):
//                    completion(web.map { UserMomunity.setup(from: $0) })
//                case .failure(let customError):
//                    switch customError {
//                    case .parsingError: break
//                    case .platounError: break
//                    case .http(_, _, _): break
//                    case .unknown: break
//                    }
//                }
//        }
    }
    
    func fetchCategories(_ completion: @escaping ([Category])->Void) {
        NewApi.v1.getProductCategories
            .response { (result: Result<[WebCategory], CustomError>) in
                switch result {
                case .success(let web):
                    completion( web.map { Category.setup($0) } )
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                }
        }
    }
    
    func deleteUserInGroup(groupId: String, productId: String, userId :String, _ completion: @escaping (_ isLeaved: Bool)->Void) {
        NewApi.v1.deleteUserInGroup(userId: userId, groupId: groupId)
            .response { (result: Result<WebJoin, CustomError>) in
                switch result {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
        }
    }
    
    func joinGroup(groupId: String, productId: String, userId: String,_ completion: @escaping (Join?, String?)->Void) {
        NewApi.v1.putUserInGroup(userId: userId, groupId: groupId)
            .response { (result: Result<WebJoin, CustomError>) in
                switch result {
                case .success(let web):
                    if web.status == .validated {
                        cache.removeValue(forKey: NewApi.v1.getPromocode(userId: userId))
                    }
                    completion(Join.setup(from: web, isJoined: true, isReached: false), nil)
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError(let error):
                        switch error.code {
                        case .haveNoPromocode: break
                        case .limitOfPrivateGroup:
                            completion(nil, "You can't be part of more than 1 private group per product".localise()); return
                        case .limitOfPublicGroup:
                            completion(nil, "You can't be part of more than 1 public group per product".localise()); return
                        case .limitOfPublicAndPrivateGroup:
                            completion(nil, "You can't be part of more than 1 public and 1 private group per product".localise()); return
                        }
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                    completion(nil, "An error has occurred. Please try again later.".localise())
                }
        }
    }
    
    func postGroup(code: String, userCount: Int, userId: String, productId: String, _ completion: @escaping (String?, String?)->Void) {
        struct PostGroup: Codable {
            let id: String?
            let status: Int
            let error: String
            let message: String
        }
        NewApi.v1.postCreateGroup(code: code, userCount: userCount, userId: userId, productId: productId)
            .response { (result: Result<PostGroup, CustomError>) in
                switch result {
                case .success(let web):
                    let groupId = web.status / 100 == 2 ? web.id : nil
                    completion(groupId, nil)
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError(let error):
                        switch error.code {
                        case .haveNoPromocode:
                            completion(nil, "All promocodes have been sold out. Currently, it's not possible to create a group for this product.".localise())
                        case .limitOfPrivateGroup:
                            completion(nil, "You can't be part of more than 1 private group per product".localise())
                        case .limitOfPublicGroup:
                            completion(nil, "You can't be part of more than 1 public group per product".localise())
                        case .limitOfPublicAndPrivateGroup:
                            completion(nil, "You can't be part of more than 1 public and 1 private group per product".localise())
                        }
                        return
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                    completion(nil, "An error has occurred. Please try again later.".localise())
                }
        }
    }
    
    func postLike(userId: String, liked: Bool, productId: String, _ completion: @escaping (Bool?)->Void) {
        struct PostLike: Codable {
            let status: Int
            let error: String
            let message: String
        }
        cache.removeValue(forKey: NewApi.v1.getAllProducts(userId: userId))
        cache.removeValue(forKey: NewApi.v1.getProduct(userId: userId, productId: productId))
        cache.removeValue(forKey: NewApi.v1.getProductsLiked(userId: userId))
        let uid = HttpServices.shared.user!.id
        var list = self.productLike[uid] ?? [:]
        list[productId] = .loading
        self.productLike[uid] = list
        
        NewApi.v1.postLikeProduct(userId: userId, liked: liked, productId: productId)
            .response { (result: Result<PostLike, CustomError>) in
                cache.removeValue(forKey: NewApi.v1.getAllProducts(userId: userId))
                cache.removeValue(forKey: NewApi.v1.getProduct(userId: userId, productId: productId))
                cache.removeValue(forKey: NewApi.v1.getProductsLiked(userId: userId))
                switch result {
                case .success(let web):
                    let isLike = web.status / 100 == 2 ? liked : !liked
                    var list = self.productLike[uid] ?? [:]
                    list[productId] = isLike ? .yes : .no
                    self.productLike[uid] = list
                    completion(isLike)
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                    completion(nil)
                }
        }
    }
    
    func fetchUser(userId: String, _ completion: @escaping (UserMomunity)->Void) {
        NewApi.v1.getUser(userId: userId)
            .response { (result: Result<WebUser, CustomError>) in
                switch result {
                case .success(let web):
                    completion(UserMomunity.setup(from: web))
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                }
        }
    }
    
    func fetchProduct(forceUpdate: Bool, userId: String, productId: String, _ completion: @escaping (Product)->Void) {
        NewApi.v1.getProduct(userId: userId, productId: productId)
            .response(forceUpdate: forceUpdate) { (result: Result<WebProduct, CustomError>) in
                switch result {
                case .success(let web):
                    var list = self.productLike[userId] ?? [:]
                    list[productId] = web.liked ? .yes : .no
                    self.productLike[userId] = list
                    completion(Product.setup(web))
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                }
        }
    }
    
    func fetchProducts(userId: String, _ completion: @escaping ([ProductSummary])->Void) {
        NewApi.v1.getAllProducts(userId: userId)
            .response { (result: Result<[WebSummaryProduct], CustomError>) in
                switch result {
                case .success(let web):
                    let products = web.map { ProductSummary.setup($0) }
                    
                    var list = self.productLike[userId] ?? [:]
                    
                    for p in products {
                        list[p.id] = p.isLike ? .yes : .no
                    }
                    self.productLike[userId] = list
                    completion(products)
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                }
        }
    }
    
    func fetchLiked(userId: String, _ completion: @escaping ([ProductLiked])->Void) {
        NewApi.v1.getProductsLiked(userId: userId)
            .response { (result: Result<[WebFavoritProducts], CustomError>) in
                switch result {
                case .success(let web):
                    var list = self.productLike[userId] ?? [:]
                    for k in list.keys {
                        list[k] = .no
                    }
                    for p in web {
                        list[p.id] = .yes
                    }
                    self.productLike[userId] = list
                    completion(web.map { ProductLiked.setup(from: $0) })
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(let status, let data, _):
                        if status == 500 {
                            if data?.contains("has no FavoritProduct") ?? false {
                                completion([])
                            }
                        }
                    case .unknown: break
                    }
                }
        }
    }
    
    func fetchGroups(userId: String, productId: String, completion: @escaping ([Group])->Void) {
        NewApi.v1.getProductGroup(userId: userId, productId: productId)
            .response { (result: Result<[WebGroup], CustomError>) in
                switch result {
                case .success(let web):
                    completion(web.map { Group.setup($0, in: productId) })
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                }
        }
    }
    
    func fetchGroupStatus(userId: String,_ completion: @escaping ([GroupStatusCell.Object])->Void) {
        NewApi.v1.getGroupStatus(userId: userId)
            .response { (result: Result<[WebGroupStatus], CustomError>) in
                switch result {
                case .success(let web):
                    completion(web.map { GroupStatusCell.Object.setup($0) })
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                }
        }
    }
    
    func fetchPromocodes(userId: String,_ completion: @escaping ([PromocodeCell.Object])->Void) {
        NewApi.v1.getPromocode(userId: userId)
            .response { (result: Result<[WebPromoStatus], CustomError>) in
                switch result {
                case .success(let web):
                    completion(web.map { PromocodeCell.Object.setup($0) })
                case .failure(let customError):
                    switch customError {
                    case .parsingError: break
                    case .platounError: break
                    case .http(_, _, _): break
                    case .unknown: break
                    }
                }
        }
    }
}
