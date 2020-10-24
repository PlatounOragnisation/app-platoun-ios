//
//  FirestoreUser.swift
//  Platoun
//
//  Created by Flavian Mary on 04/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCrashlytics

extension FirestoreUtils {
    struct Users: FirestoreCollection {
        static let collectionName: String = "users"
        
        fileprivate static let uid = "uid"
        fileprivate static let displayName = "displayName"
        fileprivate static let photoUrl = "photoUrl"
        fileprivate static let fcmToken = "fcmToken"
        fileprivate static let groupNotification = "groupNotification"
        fileprivate static let trendsNotification = "trendsNotification"
        fileprivate static let newsNotification = "newsNotification"
        
        
        static func saveUser(uid: String, name: String) {
            let db = Firestore.firestore()
            db.collection(Users.collectionName).document(uid)
                .setData(
                    [Users.displayName: name].merged(dict: PlatounUser.getDicName(name))
                    , merge: true)
        }
        
        
        
        static func saveUser(uid: String, fcmToken: String) {
            let db = Firestore.firestore()
            db.collection(Users.collectionName).document(uid).setData([Users.fcmToken: fcmToken], merge: true)
        }
        
        static func saveUser(uid: String, groupNotification: Bool, trendsNotification: Bool, newsNotification: Bool) {
            let db = Firestore.firestore()
            db.collection(Users.collectionName).document(uid).setData(
                [
                    Users.groupNotification: groupNotification,
                    Users.trendsNotification: trendsNotification,
                    Users.newsNotification: newsNotification
                ], merge: true)
        }
        
        static func saveUser(uid: String, name: String, photo: String, sema: DispatchSemaphore) throws {
            var error: Error?
            Firestore.firestore()
                .collection(Users.collectionName).document(uid)
                .setData(
                    [
                        Users.photoUrl: photo,
                        Users.displayName: name
                    ].merged(dict: PlatounUser.getDicName(name)),
                    merge: true)
                { error = $0; sema.signal() }
            sema.wait()
            
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                throw error
            } else {
                return
            }
        }
        
        static func getUsers(search: String, completion: @escaping (Result<[PlatounUserCompact], Error>)->Void) {
            
            var query: Query = Firestore.firestore().collection(Users.collectionName)
            
            
            for i in 0..<min(search.count, 10) {
                query = query.whereField("letter\(i)", isEqualTo: search[i]?.lowercased() ?? "")
            }
            
            query
                .order(by: Users.displayName)
                .getDocuments { (query, err) in
                    guard let query = query else {
                        completion(.failure(err ?? FirestoreUtilsError.noErrorGetUsers))
                        return
                    }
                    
                    do {
                        let res = try query.documents.compactMap { try $0.data(as: PlatounUserCompact.self) }
                        completion(.success(res))
                    } catch {
                        completion(.failure(error)); return
                    }
                }
        }
        
        static func getUsers(ids: [String], res: [String: PlatounUser] = [:], completion:  @escaping (Result<[String: PlatounUser], Error>)->Void) {
            guard res.count != ids.count else { completion(.success(res)); return }
            
            let index:Int = res.count / 10
            let minIndex = min(((index*10)+10), ids.count)
            let list: [String] = Array(ids[(index*10)..<minIndex])
            Firestore
                .firestore()
                .collection(Users.collectionName).whereField(Users.uid, in: list)
                .getDocuments { (query, err) in
                    guard let query = query else {
                        completion(.failure(err ?? FirestoreUtilsError.noErrorGetUsers))
                        return
                    }
                    var newRes = res
                    for doc in query.documents {
                        do {
                            guard let user = try doc.data(as: PlatounUser.self) else {
                                throw FirestoreUtilsError.parseUserError
                            }
                            newRes[user.uid] = user
                        } catch {
                            completion(.failure(error)); return
                        }
                    }
                    if list.count != query.documents.count {
                        completion(.success(newRes)); return
                    }
                    
                    self.getUsers(ids: ids, res: newRes, completion: completion)
                }
        }
        
        static func getUser(uid: String, forCreation: Bool = false, completion: @escaping (Result<PlatounUser, Error>)->Void) {
            Firestore
                .firestore()
                .collection(Users.collectionName).document(uid)
                .getDocumentCodable(
                    unRecordError: forCreation ? [DocumentReferenceError.DocumentDoesntExist] : [],
                    completion: completion)
        }
        
        static func getUserNotif(uid: String, completion: @escaping (String?)->Void) {
            getUser(uid: uid) { result in
                switch result {
                case .success(let user): completion(user.fcmToken); return
                case .failure(_): completion(nil); return
                }
            }
        }
        
        static func getUserInfo(uid: String, completion: @escaping (Result<(name: String, photo:URL?), Error>)->Void) {
            Firestore
                .firestore()
                .collection(Users.collectionName).document(uid)
                .getDocumentWithResult(completion: { result in
                    switch result {
                    case .success(let doc):
                        let name = doc.data()?[Users.displayName] as? String ?? "No name"
                        let photo = doc.data()?[Users.photoUrl] as? String
                        let url = photo?.isEmpty ?? true ? nil : URL(string: photo!)
                        completion(Result.success((name, url)))
                    case .failure(let error):
                        completion(Result.failure(error))
                    }
                })
        }
        
        static func createUser(user: PlatounUserComplet, completion: @escaping (Result<Void, Error>)->Void) {
            let db = Firestore.firestore()
            do {
                try db.collection(Users.collectionName).document(user.uid).setData(from: user, merge: true) { error in
                    if let error = error {
                        Crashlytics.crashlytics().record(error: error)
                        completion(Result.failure(error))
                    } else {
                        completion(Result.success(Void()))
                    }
                }
            } catch {
                Crashlytics.crashlytics().record(error: error)
                completion(Result.failure(error))
            }
        }
        
    }
}
