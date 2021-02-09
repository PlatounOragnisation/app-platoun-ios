//
//  CreatePost.swift
//  Platoun
//
//  Created by Flavian Mary on 09/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit
import YPImagePicker


func takePictureForPost(in viewController: UIViewController) {
    var config = YPImagePickerConfiguration()
    config.isScrollToChangeModesEnabled = true
    config.usesFrontCamera = false
    config.showsPhotoFilters = false
    config.shouldSaveNewPicturesToAlbum = false
    config.albumName = "Platoun"
    config.startOnScreen = YPPickerScreen.photo
    config.screens = [.library, .photo]
    config.showsCrop = .rectangle(ratio: 3/4)
    config.onlySquareImagesFromCamera = false
    config.targetImageSize = YPImageSize.original
    config.overlayView = UIView()
    config.hidesStatusBar = true
    config.hidesBottomBar = false
    config.hidesCancelButton = false
    config.preferredStatusBarStyle = UIStatusBarStyle.default
    config.maxCameraZoomFactor = 10.0
    
    config.library.options = nil
    config.library.onlySquare = false
    config.library.isSquareByDefault = false
    config.library.minWidthForItem = nil
    config.library.mediaType = YPlibraryMediaType.photo
    config.library.defaultMultipleSelection = false
    config.library.maxNumberOfItems = 1
    config.library.minNumberOfItems = 1
    config.library.numberOfItemsInRow = 4
    config.library.spacingBetweenItems = 1.0
    config.library.skipSelectionsGallery = false
    config.library.preselectedItems = nil
    
    config.gallery.hidesRemoveButton = false
    
    let picker = YPImagePicker(configuration: config)
    picker.didFinishPicking { (items, cancelled) in
        guard !cancelled, case .photo(let photo) = items.first else { picker.dismiss(animated: true, completion: nil); return }
        
        let storyBoard = UIStoryboard(name: "V2", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SuggestVC") as! SugestViewController
        
        vc.image = photo.image
        picker.dismiss(animated: false) {
            viewController.present(vc, animated: true)
        }
    }
    
    viewController.present(picker, animated: true)
}
