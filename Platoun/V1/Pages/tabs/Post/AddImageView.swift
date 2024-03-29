//
//  AddImageView.swift
//  Platoun
//
//  Created by Flavian Mary on 20/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import TOCropViewController
import CropViewController
import FirebaseAuth

protocol AddImageViewAction {
    
}

fileprivate extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class AddImageView: UIView {
    var originalImage: UIImage?
    var delegate: AddImageViewDelegate?
    var modified = false
    
    @IBInspectable
    var text: String = "Ajouter une photo"
    
    var image: UIImage? {
        get { self.imageView.image }
        set {
            self.imageView.image = newValue
            self.checkVisibility()
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emptyImageView: UIView!
    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func updateWith(user: User)  {
        self.originalImage = nil
        self.modified = false
        if let url = user.photoURL {
            self.imageView.setImage(with: url, placeholder: nil, options: .progressiveLoad) { _ in
                self.checkVisibility()
            }
        } else {
            self.image = nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func checkVisibility() {
        self.imageView.isHidden = self.imageView.image == nil
        self.emptyImageView.isHidden = self.imageView.image != nil
    }
    
    func setup() {
        Bundle.main.loadNibNamed("AddImageView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        titleLabel.text = text
        
        self.emptyImageView.isUserInteractionEnabled = true
        self.emptyImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addImage)))
        
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editImage)))
    }
    
    @objc func addImage() {
        guard let viewController = self.parentViewController else { return }
        ImagePickerManager().pickImage(viewController) { image in
            self.originalImage = image
            self.crop(image: image, in: viewController)
        }
    }
    
    @objc func editImage() {
        guard let viewController = self.parentViewController else { return }
        let alert = UIAlertController(title: "Que souhaitez-vous faire ?", message: nil, preferredStyle: .actionSheet)
        
        if let original = self.originalImage {
            alert.addAction(UIAlertAction(title: "Recadrer", style: .default, handler: { _ in
                self.crop(image: original, in: viewController)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Reprendre", style: .default, handler: { _ in
            self.addImage()
        }))
        
        alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: { _ in
            self.originalImage = nil
            self.image = nil
        }))
        
        viewController.present(alert, animated: true)
    }
    
    func crop(image: UIImage, in viewControler: UIViewController) {
        let cropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetButtonHidden = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.delegate = self
        DispatchQueue.main.async {
            viewControler.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.applyGradientWith(startColor: ThemeColor.BackgroundGradient1, endColor: ThemeColor.BackgroundGradient2)
        
        
        self.circle.applyGradient(colours: [ThemeColor.BackgroundGradient1, ThemeColor.BackgroundGradient2])
        self.circle.layer.cornerRadius = self.emptyImageView.bounds.size.height / 4
        self.circle.layer.masksToBounds = true
        
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        
        self.emptyImageView.applyGradient(
            colours: [
                ThemeColor.BackgroundGradient1.withAlphaComponent(0.2),
                ThemeColor.BackgroundGradient2.withAlphaComponent(0.2)
            ])

    }

}

protocol AddImageViewDelegate {
    func imageWasChanged()
}

extension AddImageView: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        self.image = image
        modified = true
        self.delegate?.imageWasChanged()
    }
    
//    func cropViewController(_ cropViewController: TOCropViewController?, didCropToCircularImage image: UIImage?, with cropRect: CGRect, angle: Int) {
//        // 'image' is the newly cropped, circular version of the original image
//    }
}
