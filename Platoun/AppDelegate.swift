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
import UserNotifications
import FirebaseMessaging
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import DropDown
//import netfox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        NFX.sharedInstance().start()
        
        FirebaseApp.configure()
        
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
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
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler()
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
                FirestoreUtils.saveUser(uid: user.uid, fcmToken: fcmToken)
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

