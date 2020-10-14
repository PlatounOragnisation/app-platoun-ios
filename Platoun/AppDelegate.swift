//
//  AppDelegate.swift
//  Platoun
//
//  Created by Flavian Mary on 23/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseInstanceID
import FirebaseAuth
import FirebaseFirestore
import FirebaseCrashlytics
import UserNotifications
import FirebaseMessaging
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import DropDown
#if DEBUG
import netfox
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            NFX.sharedInstance().start()
        #endif
        
        FirebaseApp.configure()
        
        
        RemoteConfigUtils.shared.fetch { (status, error) in
            switch status {
            case .success:
                print("Config fetched!")
                RemoteConfigUtils.shared.activate() { (changed, error) in
                    if error != nil {
                        Crashlytics.crashlytics().record(error: error!)
                    }
                }
            default:
                if error != nil {
                    Crashlytics.crashlytics().record(error: error!)
                }
            }
        }
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        //        Firestore.enableLogging(true)
        signOutOldUser()
        Auth.auth().languageCode = "fr"
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        DropDown.startListeningToKeyboard()
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebook = ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
        let google = GIDSignIn.sharedInstance().handle(url)
        return facebook || google
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {}
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
    }
}

extension AppDelegate {
    func signOutOldUser() {
        if !UserDefaults.standard.bool(forKey: "isNewuser") {
            UserDefaults.standard.set(true, forKey: "isNewuser")
            try? Auth.auth().signOut()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    //When received
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        switch notification.getType() {
        case .comment(let postId):
            center.getDeliveredNotifications { notifs in
                let commentsNotif = notifs
                    .filter { $0.getType() == .comment(postId: postId) }
                    .map { $0.request.identifier }
                if commentsNotif.count > 0 {
                    center.removeDeliveredNotifications(withIdentifiers: commentsNotif)
                }
                completionHandler([.alert, .sound, .badge])
            }
        case .like(let postId):
            center.getDeliveredNotifications { notifs in
                let commentsNotif = notifs
                    .filter { $0.getType() == .like(postId: postId) }
                if commentsNotif.count == 0 {
                    completionHandler([.alert, .sound, .badge])
                } else {
                    completionHandler([])
                }
            }
        case .invitation(_):
            completionHandler([.alert, .sound, .badge])
        case .other:
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    //When Clic
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        (self.window?.rootViewController as? TabViewController)?.selectedIndex = 4
        
        switch response.notification.getType() {
        case .comment: break
        case .like: break
        case .invitation(let notifId):
            if let notifs = (self.window?.rootViewController as? TabViewController)?.viewControllers?.last {
                actionNotif(notifId: notifId, from: notifs)
            }
        case .other: break
        }
        
        completionHandler()
    }
}

extension UNNotification {
    enum NotifPlatoun: Equatable {
        case comment(postId: String)
        case like(postId: String)
        case invitation(notifId: String)
        case other
    }
    var messageId: String? {
        get {
            return self.request.content.userInfo["gcm.message_id"] as? String
        }
    }
    
    func getType() -> NotifPlatoun {
        let userInfo = self.request.content.userInfo
        
        switch userInfo["type"] as? String {
        case "comment":
            guard let postId = userInfo["postId"] as? String else { return .other }
            return .comment(postId: postId)
        case "like":
            guard let postId = userInfo["postId"] as? String else { return .other }
            return .like(postId: postId)
        case "invitation":
            guard let notifId = userInfo["notifId"] as? String else { return .other }
            return .invitation(notifId: notifId)
        default:
            return .other
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let needUpdate = UserDefaults.standard.FCMToken == nil || UserDefaults.standard.FCMToken != fcmToken
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FCMToken"), object: nil, userInfo: dataDict)
        
        
        if needUpdate {
            UserDefaults.standard.FCMToken = fcmToken
            if let user = Auth.auth().currentUser {
                FirestoreUtils.Users.saveUser(uid: user.uid, fcmToken: fcmToken)
                Interactor.shared.updateToken(userId: user.uid, token: fcmToken)
            }
        }
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

extension UserDefaults {
    var FCMToken: String? {
        get { self.string(forKey: "FCMToken") }
        set { self.set(newValue, forKey: "FCMToken") }
    }
}

