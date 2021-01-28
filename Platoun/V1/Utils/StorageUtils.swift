//
//  StorageUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 05/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseCrashlytics

enum StorageUtilsError: Error {
    case convertUIImageToData
    case uploadErrorWithoutInfo
}

class StorageUtils: NSObject {
    
    static func deleteImageFor(userId: String, postId: String, numberOfImages:Int ) {
        let postRef = Storage.storage().reference().child(userId).child("images").child("posts").child(postId)
        for i in 0..<numberOfImages {
            postRef.child("image\(i).jpg").delete()
        }
    }
    
    static func deleteImageFor(userId: String, commentId: String, numberOfImages:Int ) {
        let postRef = Storage.storage().reference().child(userId).child("images").child("comments").child(commentId)
        for i in 0..<numberOfImages {
            postRef.child("image\(i).jpg").delete()
        }
    }
    
    static func uploadImageComment(image: UIImage, userId: String, commentId: String, imageCount: Int, completion: @escaping (Result<String, Error>)->Void) {
        let imageRef = Storage.storage().reference()
            .child(userId).child("images").child("comments")
            .child(commentId).child("image\(imageCount).jpg")
        
        guard let dataImage = image.jpegData(
            compressionQuality: CGFloat(RemoteConfigUtils.shared.getCompressionQuality().comment)
        ) else {
            completion(Result.failure(StorageUtilsError.convertUIImageToData)); return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        
        let _ = imageRef.putData(dataImage, metadata: metadata) { (metaData, error) in
            guard metaData != nil else {
                completion(Result.failure(error ?? StorageUtilsError.uploadErrorWithoutInfo)); return
            }
            completion(Result.success("\(imageRef)"))
        }
    }
    
    
    static func uploadImageProfil(image: UIImage, userId: String, completion: @escaping (Result<URL, Error>)->Void) {
        let imageRef = Storage.storage().reference()
            .child(userId).child("profil.jpg")

        guard let dataImage = image.jpegData(
            compressionQuality: CGFloat(RemoteConfigUtils.shared.getCompressionQuality().profilPicture)
        ) else {
            completion(Result.failure(StorageUtilsError.convertUIImageToData)); return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        
        let _ = imageRef.putData(dataImage, metadata: metadata) { (metaData, error) in
            guard let url = URL(string: "\(imageRef)"), metaData != nil else {
                completion(Result.failure(error ?? StorageUtilsError.uploadErrorWithoutInfo)); return
            }
            completion(Result.success(url))
        }
        
    }
    
    static func uploadImagePost(image: UIImage, userId: String, postId: String, imageCount: Int, completion: @escaping (Result<String, Error>)->Void) {
        let imageRef = Storage.storage().reference()
            .child(userId).child("images").child("posts")
            .child(postId).child("image\(imageCount).jpg")
        
        guard let dataImage = image.jpegData(
            compressionQuality: CGFloat(RemoteConfigUtils.shared.getCompressionQuality().post)
        ) else {
            completion(Result.failure(StorageUtilsError.convertUIImageToData)); return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        
        let _ = imageRef.putData(dataImage, metadata: metadata) { (metaData, error) in
            guard metaData != nil else {
                completion(Result.failure(error ?? StorageUtilsError.uploadErrorWithoutInfo)); return
            }
            completion(Result.success("\(imageRef)"))
        }
    }
}
