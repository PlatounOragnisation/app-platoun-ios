//
//  HttpServices.swift
//  Platoun
//
//  Created by Flavian Mary on 04/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

public enum PlatounError: Error {
    case userIdNotDefined
}

public class Platoun {
        
    public static func getViewController() -> UIViewController {
        let rootController = RootViewController.instance()
        let menuVC = DrawerViewController.instance()
        return DrawerController(rootViewController: rootController, menuController: menuVC)
    }
    
    public static func update(userId: String) {
//        HttpServices.shared.userId = userId
    }
    
    public static func getNotificationViewController(currentUserId: String, notificationSendBy: String, groupId: String) -> UIViewController {
        return NotificationInvitationViewController.instance(sendUserId: notificationSendBy, currentUserId: currentUserId, groupId: groupId)
    }
    
    public static func getAllNotifications(userId: String, _ completion: @escaping ([WebSummaryNotification])->Void) {
        NewApi.v1.allNotif(userId: userId)
            .response { (result: Result<[WebSummaryNotification], CustomError>) in
                switch result {
                case .success(let web):
                    completion(web)
                case .failure(let error):
                    print(error)
                    break
                }
        }
    }
    
//    public static func getUsers(_ completion: @escaping ([String])-> Void) {
//        Interactor.shared.fetchUsers(completion)
//    }
    
//    public static func getUser(userId: String, _ completion: @escaping (WebUser?)-> Void) {
//        NewApi.v1.getUser(userId: userId)
//            .response { (result: Result<WebUser, CustomError>) in
//                switch result {
//                case .success(let web):
//                    completion(web)
//                case .failure(let customError):
//                    print(customError)
//                    completion(nil)
//                }
//        }
//    }
}

public enum PlatounEnv: String {
    case develop
    case release
    
    var url: String {
        switch self {
        case .develop:
            return "https://platoun-api-develop.azurewebsites.net"
        case .release:
            return "https://platoun-api-release.azurewebsites.net"
        }
    }
}

class HttpServices {
    
    
    static let shared = HttpServices()
    static let defaultUserImg = "default"
    
    private static let versionApi = "/v1"
    
//    var user: UserMomunity?
    
    var env = PlatounEnv.develop
    
    var baseURL: String {
        get { "\(env.url)/api\(HttpServices.versionApi)" }
    }
    
//    var userId: String? {
//        didSet {
////            Interactor.shared.fetchUser(userId: HttpServices.shared.userId) {
////                self.user = $0
////            }
//        }
//    }
}
