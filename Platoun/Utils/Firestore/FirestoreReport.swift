//
//  FirestoreReport.swift
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
    struct Reports: FirestoreCollection {
        static var collectionName: String = "reports"
        
        static func saveReport(post: Post, userUid: String, completion: @escaping (Result<Void,Error>)->Void) {
            let db = Firestore.firestore()
            let date = Date()
            let reportId = "r-\(userUid)-\(date.timeIntervalSince1970)"
            let report = Report(reportId: reportId, reportedBy: userUid, reportedAt: date, postId: post.postId)
            do {
                try db.collection(Reports.collectionName).document(report.reportId).setData(from: report, merge: true) { error in
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
    }
}
