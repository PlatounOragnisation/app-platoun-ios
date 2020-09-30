//
//  FirestoreUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 06/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCrashlytics
import FirebaseAuth

enum FirestoreUtilsError: Error {
    case noErrorGetUser(uid: String)
    case noErrorGetUsers
    case parseUserError
    case noErrorGetPost(postId: String)
    case noErrorGetNotifications(userId: String)
}

class FirestoreUtils: NSObject {
    
    static func saveUser(uid: String, name: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(["displayName": name], merge: true)
    }
    
    static func saveUser(uid: String, fcmToken: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(["fcmToken": fcmToken], merge: true)
    }
    
    static func saveUser(uid: String, groupNotification: Bool, trendsNotification: Bool, newsNotification: Bool) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(
            [
                "groupNotification": groupNotification,
                "trendsNotification": trendsNotification,
                "newsNotification": newsNotification
            ], merge: true)
    }
    
    static func getUsers(ids: [String], res: [String: PlatounUser] = [:], completion:  @escaping (Result<[String: PlatounUser], Error>)->Void) {
        guard res.count != ids.count else { completion(.success(res)); return }
        
        let index:Int = res.count / 10
        let minIndex = min(((index*10)+10), ids.count)
        let list: [String] = Array(ids[(index*10)..<minIndex])
        Firestore
            .firestore()
            .collection("users").whereField("uid", in: list)
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
            .collection("users").document(uid)
            .getDocument() { (doc, error) in
                do {
                    guard let doc = doc, doc.exists, let user = try doc.data(as: PlatounUser.self) else {
                        let error = error ?? FirestoreUtilsError.noErrorGetUser(uid: uid)
                        if !forCreation {
                            Crashlytics.crashlytics().record(error: error)
                        }
                        completion(Result.failure(error))
                        return
                    }
                    completion(Result.success(user))
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                }
            }
    }
    
    static func getUserInfo(uid: String, completion: @escaping (Result<(name: String, photo:URL?), Error>)->Void) {
        Firestore
            .firestore()
            .collection("users").document(uid)
            .getDocument() { (doc, error) in
                guard let doc = doc, doc.exists, let name = doc.data()?["displayName"] as? String else {
                    let error = error ?? FirestoreUtilsError.noErrorGetUser(uid: uid)
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                    return
                }
                let photo = doc.data()?["photoUrl"] as? String
                let url = photo?.isEmpty ?? true ? nil : URL(string: photo!)
                completion(Result.success((name, url)))
            }
    }
    
    static func getPost(postId: String, completion: @escaping (Result<Post, Error>)->Void) {
        let db = Firestore.firestore()
        
        db.collection("posts").document(postId).getDocument { (document, error) in
            if let doc = document, doc.exists {
                do {
                    if let post = try doc.data(as: Post.self) {
                        completion(Result.success(post))
                    } else {
                        completion(Result.failure(FirestoreUtilsError.noErrorGetPost(postId: postId)))
                    }
                } catch {
                    completion(Result.failure(error))
                }
            } else {
                completion(Result.failure(error ?? FirestoreUtilsError.noErrorGetPost(postId: postId)))
            }
        }
    }
    
    static func getComments(postId: String, completion: @escaping (Result<[Comment], Error>)->Void) {
        let db = Firestore.firestore()
        
        db.collection("posts").document(postId).collection("comments")
            .getDocuments { (query, error) in
                guard let query = query else {
                    completion(Result.failure(error ?? FirestoreUtilsError.noErrorGetPost(postId: postId)))
                    return
                }
                
                let comments = query.documents.compactMap { try? $0.data(as: Comment.self) }
                completion(Result.success(comments))
            }
    }
    
//    static func getNotifications(userId: String, completion: @escaping (Result<[Notification], Error>)->Void) {
//        let db = Firestore.firestore()
//
//        db.collection("notifications").document(userId).getDocument { (document, error) in
//            struct Internal: Codable {
//                let list: [Notification]
//            }
//
//            guard let doc = document, doc.exists else {
//                completion(Result.failure(error ?? FirestoreUtilsError.noErrorGetNotifications(userId: userId)))
//                return
//            }
//
//            do {
//                if let inter = try doc.data(as: Internal.self) {
//                    completion(Result.success(inter.list))
//                } else {
//                    completion(Result.failure(FirestoreUtilsError.noErrorGetNotifications(userId: userId)))
//                }
//            } catch {
//                completion(Result.failure(error))
//            }
//        }
//    }
    
    static func savePost(post: Post, completion: @escaping (Result<Void,Error>)->Void) {
        let db = Firestore.firestore()
        do {
            try db.collection("posts").document(post.postId).setData(from: post, merge: true) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                } else {
                    completion(Result.success(Void()))
                }
            }
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            completion(Result.failure(error))
        }
    }
    
    static func createUser(user: PlatounUser, completion: @escaping (Result<Void, Error>)->Void) {
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(user.uid).setData(from: user, merge: true) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                } else {
                    completion(Result.success(Void()))
                }
            }
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            completion(Result.failure(error))
        }
    }
    
    static func deletePost(postId: String) {
        let db = Firestore.firestore()
        db.collection("posts").document(postId).delete()
    }
    
    static func saveReport(post: Post, userUid: String, completion: @escaping (Result<Void,Error>)->Void) {
        let db = Firestore.firestore()
        let date = Date()
        let reportId = "r-\(userUid)-\(date.timeIntervalSince1970)"
        let report = Report(reportId: reportId, reportedBy: userUid, reportedAt: date, postId: post.postId)
        do {
            try db.collection("reports").document(report.reportId).setData(from: report, merge: true) { error in
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                } else {
                    completion(Result.success(Void()))
                }
            }
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            completion(Result.failure(error))
        }
    }
    
    static func addComment(postId: String, comment: Comment, completion: @escaping (Bool)->Void) {
        let db = Firestore.firestore()
        let postReference = db.collection("posts").document(postId)
        let commentsReference = postReference.collection("comments").document(comment.id)
        guard let commentData = try? Firestore.Encoder().encode(comment) else { completion(false); return }
        
        let batch = db.batch()
        
        batch.updateData(["commentsCount": FieldValue.increment(Int64(1))], forDocument: postReference)
        batch.setData(commentData, forDocument: commentsReference)
        
        batch.commit { (error) in
            if let err = error {
                Crashlytics.crashlytics().record(error: err)
                print("Error writing batch \(err)")
                completion(false)
            } else {
                print("Batch write succeeded.")
                completion(true)
            }
        }
    }
    
    static func toogleVote(postId: String, userUid: String) {
        let db = Firestore.firestore()
        let sfReference = db.collection("posts").document(postId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let post = try? sfDocument.data(as: Post.self) else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to parse post from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            let encoder = Firestore.Encoder()
            if let index = post.votes.first(where: { $0.userId == userUid }), let obj = try? encoder.encode(index) {
                transaction.updateData(["votes": FieldValue.arrayRemove([obj])], forDocument: sfReference)
            } else if let obj = try? encoder.encode(Post.Vote(userId: userUid, votedAt: Date())){
                transaction.updateData(["votes": FieldValue.arrayUnion([obj])], forDocument: sfReference)
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction toogle vote failed: \(error)")
            } else {
                print("Transaction toogle vote successfully committed!")
            }
        }
    }
    
    
    static func getPostQuery(filter: Post.PostType? = nil) -> Query {
        let db = Firestore.firestore()
        var query: Query = db.collection("posts")
        
        if let filter = filter {
            query = query.whereField("category", isEqualTo: filter.rawValue)
        }
        
        return query.order(by: "createAt", descending: true)
    }
    
    static func getNotificationsQuery(userId: String) -> Query {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: -3, to: start)!
        return db.collection("users").document(userId).collection("notifications")
            .whereField("dateTimeCreation", isGreaterThan: end)
            .order(by: "dateTimeCreation", descending: true)
    }
    //    static func getCommentsQuery(postId: String) -> Query {
    //        let db = Firestore.firestore()
    //
    //        return db.collection("posts").document(postId)..order(by: "createAt", descending: true)
    //    }
}
