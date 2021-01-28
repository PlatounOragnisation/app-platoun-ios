//
//  PlatounBackendApi.swift
//  Platoun
//
//  Created by Flavian Mary on 18/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import Alamofire
//PlatounBackendApi

enum NewApi {
    enum v1 : Hashable {
        case getUser(userId: String)
        case updateToken(userId: String, token: String)
//        case getUsers
//        case getFriends(userId: String)
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
            case .updateToken:
                return "\(HttpServices.shared.baseURL)/platoun-users/token"
//            case .getUsers:
//                return "\(HttpServices.shared.baseURL)/platoun-users"
//            case .getFriends(let userId):
//                return "\(HttpServices.shared.baseURL)/momunity-users/get-friends/\(userId)"
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
                 .updateToken,
//                 .getUsers,
//                 .getFriends,
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
                 .updateToken,
                 .postLikeProduct,
                 .showNotif,
                 .sendNotif,
                 .allNotif:
                return .post
            case .getUser,
//                 .getUsers,
//                 .getFriends,
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
//                 .getUsers,
//                 .getFriends,
                 .getProductCategories,
                 .allNotif:
                return nil
            case .deleteUserInGroup(let userId, let groupId):
                return [ "groupId": groupId, "userId": userId ]
            case .updateToken(let userId, let token):
                return ["id": userId, "token":token]
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
                 .updateToken,
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
            
            let token = RemoteConfigUtils.shared.getBackendToken()
            let headers: HTTPHeaders = HTTPHeaders(
                ["Authorization" : "Bearer \(token)"])
            
            let param:[String:Any] = parameters ?? [:]
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
