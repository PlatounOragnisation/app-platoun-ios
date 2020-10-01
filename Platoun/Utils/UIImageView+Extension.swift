//
//  UIImageView+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 06/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage
import FirebaseCrashlytics


extension UIImageView {
    func setImage(with url: URL? , placeholder: UIImage?, options: SDWebImageOptions, completion: ((Error?)->Void)? = nil) {
        if url?.scheme == "gs", let urlString = url?.absoluteString {
            let ref = Storage.storage().reference(forURL: urlString)
            setImage(with: ref, placeholder: placeholder, options: options, completion: completion)
            return
        }
        self.sd_setImage(with: url, placeholderImage: placeholder, options: options) { _, error, _, _ in
            if let err = error as? SDWebImageError, case SDWebImageError.cancelled = err {
            } else if let err = error {
                Crashlytics.crashlytics().record(error: err)
                completion?(err)
            } else {
                completion?(nil)
            }
        }
    }
    
    func setImage(with ref: StorageReference , placeholder: UIImage?, options: SDWebImageOptions, completion: ((Error?)->Void)? = nil) {
        self.sd_setImage(with: ref, maxImageSize: StorageImageLoader.shared.defaultMaxImageSize, placeholderImage: placeholder, options: options) { _, error, _, _ in
            if let err = error as? SDWebImageError, case SDWebImageError.cancelled = err {
            } else if let err = error {
                Crashlytics.crashlytics().record(error: err)
                completion?(err)
            } else {
                completion?(nil)
            }
        }
    }
}


