//
//  FIRDocumentReference+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 21/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCrashlytics

enum DocumentReferenceError: Error {
    case BlockPropertiesNil
    case DocumentDoesntExist
}

extension DocumentReference {
    func getDocumentWithResult(unRecordError: [Error] = [], completion: @escaping (Result<DocumentSnapshot, Error>)->Void) {
        self.getDocument { (snap, queryError) in
            if let snap = snap {
                if snap.exists {
                    completion(Result.success(snap))
                } else {
                    let error = DocumentReferenceError.DocumentDoesntExist
                    if !unRecordError.contains(where: { error == $0 }) {
                        Crashlytics.crashlytics().record(error: error)
                    }
                    completion(Result.failure(error))
                }
            } else {
                let error = queryError ?? DocumentReferenceError.BlockPropertiesNil
                if !unRecordError.contains(where: { error == $0 }) {
                    Crashlytics.crashlytics().record(error: error)
                }
                completion(Result.failure(error))
            }
        }
    }
    
    func getDocumentCodable<T: Codable>(unRecordError: [Error] = [], completion: @escaping (Result<T, Error>)->Void) {
        self.getDocument { (snap, queryError) in
            if let snap = snap {
                do {
                    if let obj = try snap.data(as: T.self) {
                        completion(Result.success(obj))
                    } else {
                        let error = DocumentReferenceError.DocumentDoesntExist
                        if !unRecordError.contains(where: { error == $0 }) {
                            Crashlytics.crashlytics().record(error: error)
                        }
                        completion(Result.failure(error))
                    }
                } catch {
                    if !unRecordError.contains(where: { error == $0 }) {
                        Crashlytics.crashlytics().record(error: error)
                    }
                    completion(Result.failure(error))
                }
            } else {
                let error = queryError ?? DocumentReferenceError.BlockPropertiesNil
                if !unRecordError.contains(where: { error == $0 }) {
                    Crashlytics.crashlytics().record(error: error)
                }
                completion(Result.failure(error))
            }
        }
    }
}


