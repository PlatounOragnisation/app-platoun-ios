//
//  CreatePost.swift
//  Platoun
//
//  Created by Flavian Mary on 09/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit
import YPImagePicker
import ImagePicker
import Photos

class ImagePickerControllerCustom: ImagePickerController {
    
    var cancel: (()->Void)?
    var done: (([UIImage])->Void)?
    var wrapper: (([UIImage])->Void)?
    
    required init(configuration: Configuration = Configuration()) {
        super.init(configuration: configuration)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 14, *) {
            if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                self.galleryView.collectionView.reloadData()
            }
        }
    }
}

extension ImagePickerControllerCustom: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.wrapper?(images)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.done?(images)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.cancel?()
    }
}

class ImageBisViewController: UIViewController {
    
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override func loadView() {
        super.loadView()
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
}

func takePictureForPost2(in viewController: UIViewController, for user: UserV2) {
    let config = Configuration()
    config.allowMultiplePhotoSelection = false
        
    let imagePicker = ImagePickerControllerCustom(configuration: config)
    
    imagePicker.cancel = {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    imagePicker.done = { images in
        guard let image = images.first else { return }
        let storyBoard = UIStoryboard(name: "V2", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SuggestVC") as! SugestViewController
        
        vc.image = image
        vc.user = user
        imagePicker.dismiss(animated: false) {
            viewController.present(vc, animated: true)
        }
    }
    
    imagePicker.wrapper = { images in
        guard let image = images.first else { return }
        
        let vc = ImageBisViewController()
        vc.image = image
        
        imagePicker.present(vc, animated: true)
        print("t")
    }
    
    imagePicker.modalPresentationStyle = .fullScreen
    viewController.present(imagePicker, animated: true)
}

func takePictureForPost(in viewController: UIViewController, for user: UserV2) {
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
        vc.user = user
        picker.dismiss(animated: false) {
            viewController.present(vc, animated: true)
        }
    }
    
    viewController.present(picker, animated: true)
}
