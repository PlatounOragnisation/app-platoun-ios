//
//  UIImageView+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 07/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

fileprivate var imageCache: [String: UIImage] = [:]

fileprivate func downloadImg(from link: String,count: Int = 0, _ completion: @escaping (UIImage) -> Void) {
    guard link != "default" else {
        completion(UIImage(named: "ic-no-user")!)
        return
    }
    
    
    guard let url = URL(string: link) else { return }
    
    if let image = imageCache[url.absoluteString] {
        completion(image)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
            let data = data, error == nil,
            let image = UIImage(data: data)?.fixOrientation()
            else {
                
                if count < 3 {
                    downloadImg(from: link, count: count + 1, completion)
                }
                return
        }
        
        imageCache[url.absoluteString] = image
        completion(image)
    }.resume()
}

extension String {
    func ddlImg(completion: @escaping (String, UIImage?)->Void) {
        let start = Date()
        print("Download Started \(self)")
        
        if let image = imageCache[self] {
            print("Download Finished in \(Date().timeIntervalSince(start) * 1000)ms")
            completion(self, image)
            return
        }
        let url = URL(string: self)!
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished in \(Date().timeIntervalSince(start) * 1000)ms")
            let image = UIImage(data: data)?.fixOrientation()
            imageCache[self] = image
            completion(self, image)
        }
    }
}

private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

extension ImageShadow {
//    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
//        contentMode = mode
//
//        SD_
//        downloadImg(from: link) { (image) in
//            DispatchQueue.main.async() {
//                self.image = image
//            }
//        }
//    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}

extension UIImageView {
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        downloadImg(from: link) { (image) in
            DispatchQueue.main.async() {
                self.image = image
            }
        }
    }
}
