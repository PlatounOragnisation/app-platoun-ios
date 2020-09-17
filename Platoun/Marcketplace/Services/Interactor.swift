//
//  Api.swift
//  Platoun
//
//  Created by Flavian Mary on 06/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import Alamofire

enum NewApi {
    enum v1 : Hashable {
        case getUser(userId: String)
        case getUsers
        case getFriends(userId: String)
        case getProductCategories
        case deleteUserInGroup(userId: String, groupId: String)
        case putUserInGroup(userId: String, groupId: String)
        case postCreateGroup(code: String, userCount: Int, userId: String, productId: String)
        case postLikeProduct(userId: String, liked: Bool, productId: String)
        case getProduct(userId: String, productId: String)
        case getAllProducts(userId: String)
        case getProductsLiked(userId: String)
        case getProductGroup(userId: String, productId: String)
        case getGroupStatus(userId: String)
        case getPromocode(userId: String)
        case showNotif(userId: String, sendUserId: String, groupId: String)
        case sendNotif(userId: String, inviteUserId: String, groupId: String)
        case respondNotif(userId: String, userInviterId: String, groupId: String, accepted: Bool)
        case allNotif(userId: String)
        
        var url: String {
            switch self {
            case .getUser(let userId):
                return "\(HttpServices.shared.baseURL)/momunity-users/\(userId)"
            case .getUsers:
                return "\(HttpServices.shared.baseURL)/platoun-users"
            case .getFriends(let userId):
                return "\(HttpServices.shared.baseURL)/momunity-users/get-friends/\(userId)"
            case .getProductCategories:
                return "\(HttpServices.shared.baseURL)/product-categories"
            case .deleteUserInGroup:
                return "\(HttpServices.shared.baseURL)/platoun-groups/delete-user"
            case .putUserInGroup:
                return "\(HttpServices.shared.baseURL)/platoun-groups/add-user"
            case .postCreateGroup:
                return "\(HttpServices.shared.baseURL)/platoun-groups/create"
            case .postLikeProduct:
                return "\(HttpServices.shared.baseURL)/favorit-products/like/"
            case .getProduct:
                return "\(HttpServices.shared.baseURL)/products/by-product"
            case .getAllProducts:
                return "\(HttpServices.shared.baseURL)/products"
            case .getProductsLiked:
                return "\(HttpServices.shared.baseURL)/favorit-products/by-user/"
            case .getProductGroup:
                return "\(HttpServices.shared.baseURL)/platoun-groups/by-product/"
            case .getGroupStatus:
                return "\(HttpServices.shared.baseURL)/platoun-groups/with-status/"
            case .getPromocode:
                return "\(HttpServices.shared.baseURL)/platoun-groups/with-promo/"
            case .showNotif:
                return "\(HttpServices.shared.baseURL)/notifications/show"
            case .sendNotif:
                return "\(HttpServices.shared.baseURL)/notifications/send"
            case .respondNotif(_, _, _, let accepted):
                return "\(HttpServices.shared.baseURL)/platoun-groups/add-user-notif?accepted=\(accepted ? "true" : "false")"
            case .allNotif(let userId):
                return "\(HttpServices.shared.baseURL)/platoun-groups/notif?userId=\(userId)"
            }
        }
        
        var useCache: Bool {
            switch self {
            case .deleteUserInGroup,
                 .putUserInGroup,
                 .postCreateGroup,
                 .postLikeProduct,
                 .getGroupStatus,
                 .getProductGroup,
                 .showNotif,
                 .sendNotif,
                 .getPromocode,
                 .respondNotif,
                 .allNotif:
                return false
            case .getUser,
                 .getUsers,
                 .getFriends,
                 .getProductCategories,
                 .getProduct,
                 .getAllProducts,
                 .getProductsLiked:
                return true
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .deleteUserInGroup:
                return .delete
            case .putUserInGroup,
                 .respondNotif:
                return .put
            case .postCreateGroup,
                 .postLikeProduct,
                 .showNotif,
                 .sendNotif,
                 .allNotif:
                return .post
            case .getUser,
                 .getUsers,
                 .getFriends,
                 .getProductCategories,
                 .getProduct,
                 .getAllProducts,
                 .getProductsLiked,
                 .getProductGroup,
                 .getGroupStatus,
                 .getPromocode:
                return .get
            }
        }
        
        var parameters: Parameters? {
            switch self {
            case .getUser,
                 .getUsers,
                 .getFriends,
                 .getProductCategories,
                 .allNotif:
                return nil
            case .deleteUserInGroup(let userId, let groupId):
                return [ "groupId": groupId, "userId": userId ]
            case .putUserInGroup(let userId, let groupId):
                return [ "groupId": groupId, "userId": userId ]
            case .postCreateGroup(let code, let userCount, let userId, let productId):
                return [
                    "code": code,
                    "maxUsers": userCount,
                    "userId": userId,
                    "title": "",
                    "productId": productId
                ]
            case .postLikeProduct(let userId, let liked, let productId):
                return [
                    "isLike": liked ? "true" : "false",
                    "productId": productId,
                    "userId": userId
                ]
            case .getProduct(let userId, let productId):
                return [
                    "productId": productId,
                    "userId": userId,
                    "likeAlsoItemSize": 12
                ]
            case .getAllProducts(let userId):
                return ["userId": userId]
            case .getProductsLiked(let userId):
                return ["userId": userId]
            case .getProductGroup(let userId, let productId):
                return ["productId": productId, "userId": userId]
            case .getGroupStatus(let userId):
                return ["userId": userId, "itemSize": 12000]
            case .getPromocode(let userId):
                return ["userId": userId]
            case .sendNotif(let userId, let inviteUserId, let groupId):
                return ["userInviterId": userId, "userInviteeId": inviteUserId, "groupId": groupId]
            case .showNotif(let userId, let sendUserId, let groupId):
                return ["userInviterId": sendUserId, "userInviteeId": userId, "groupId": groupId]
            case .respondNotif(let userId, let userInviterId, let groupId, _):
                return ["userInviterId": userInviterId, "userInviteeId": userId, "groupId": groupId]
            }
        }
        
        var encoding: ParameterEncoding {
            switch self {
            case .postCreateGroup,
                 .showNotif,
                 .sendNotif,
                 .respondNotif:
                return JSONEncoding()
            default:
                return URLEncoding.default
            }
        }
        
        var decoder: JSONDecoder {
            switch self {
            case .deleteUserInGroup,
                 .putUserInGroup:
                let decoder = JSONDecoder()
                let dateFormatterSimple = DateFormatter(format: "yyyy-MM-dd")
                decoder.dateDecodingStrategy = .formatted(dateFormatterSimple)
                return decoder
            case .getProductGroup,
                 .getGroupStatus,
                 .getPromocode,
                 .showNotif:
                let decoder = JSONDecoder()
                let dateformaterComplex = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSS", timeZone: TimeZone(abbreviation: "GMT-0")!, locale: Locale.current.identifier)
                decoder.dateDecodingStrategy = .formatted(dateformaterComplex)
                return decoder
            case .allNotif:
                let decoder = JSONDecoder()
                let dateformaterComplex = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z", timeZone: TimeZone(abbreviation: "GMT-0")!, locale: Locale.current.identifier)
                decoder.dateDecodingStrategy = .formatted(dateformaterComplex)
                return decoder
            default:
                return JSONDecoder()
            }
        }
        
        func response<T: Codable>(forceUpdate: Bool = false, _ completion: @escaping (Result<T, CustomError>)->Void) {
            
            if useCache, let cached = cache[self], !forceUpdate {
                completion(.success(cached as! T))
                return
            }
            
            let headers: HTTPHeaders = HTTPHeaders(
                ["Authorization" : "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJwbGF0b3VuLWlvcyIsImV4cCI6MjIxNzM2MjQwMCwiaWF0IjoxNTg2MjgxMzU5fQ.VWCVZR6vVxh3W93yVDLCdly0GlxahzBe6xOb0jqllEw"])
            
            var param:[String:Any] = parameters ?? [:]
//            param["lgPrefix"] = "lgPrefix".localise()
                        
            var newUrl = url.contains("?") ? url + "&" : url + "?"
            newUrl += "lgPrefix=\("lgPrefix".localise())"
            
            AF.request(newUrl, method: method, parameters: param, encoding: encoding, headers: headers)
                .response { response in
                    let statusCode = response.response?.statusCode ?? -1
                    
                    guard let data = response.data, statusCode / 100 == 2 else {
                        let decoder = JSONDecoder()
                        
                        if let data = response.data {
                            if let error = try? decoder.decode(WebPlatounError.self, from: data) {
                                completion(.failure(.platounError(error: error)))
                            } else {
                                let value = String(data: data, encoding: .utf8)
                                completion(.failure(.http(status: statusCode, data: value, error: response.error)))
                            }
                        } else {
                            completion(.failure(.unknown(status: statusCode, error: response.error)))
                        }
                        return
                    }
                    
                    do {
                        
                        let web: T
                        if T.self == String.self {
                            web = String(data: data, encoding: .utf8) as! T
                        } else {
                            web = try self.decoder.decode(T.self, from: data)
                        }
                        if self.useCache {
                            cache[self] = web
                        }
                        completion(.success(web))
                    } catch {
                        print(error)
                        completion(.failure(.parsingError))
                    }
            }
        }
    }
}

enum CustomError: Error {
    case parsingError
    case platounError(error: WebPlatounError)
    case http(status: Int, data: String?, error: AFError?)
    case unknown(status: Int, error: AFError?)
}

//enum Result<T: Codable> {
//    case success(T)
//    case error(CustomError)
//}


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
    
    func fetchUsers(_ completion: @escaping ([String])-> Void) {
        struct UserIds: Codable {
            let id: String
        }
        
        NewApi.v1.getUsers
            .response { (result: Result<[UserIds], CustomError>) in
                switch result {
                case .success(let web):
                    completion(web.map { $0.id })
                case .failure(let customError):
                    completion([])
                }
        }
    }
    
    func fetchMomunityUsers(userId: String, _ completion: @escaping ([UserMomunity])->Void) {
        NewApi.v1.getFriends(userId: userId)
            .response { (result: Result<[WebUser], CustomError>) in
                switch result {
                case .success(let web):
                    completion(web.map { UserMomunity.setup(from: $0) })
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
