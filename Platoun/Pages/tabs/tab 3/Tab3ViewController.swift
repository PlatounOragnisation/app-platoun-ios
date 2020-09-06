//
//  Tab3ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class Tab3ViewController: UIViewController {
    
    static func getInstance() -> Tab3ViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Tab3ViewController") as! Tab3ViewController
    }
    
    enum PickerType {
        case category, language, none
        
        var listItem: [EnumType] {
            get {
                switch self {
                case .category:
                    return Post.PostType.allCases
                case .language:
                    return Post.LanguageType.allCases
                case .none:
                    return []
                }
            }
        }
    }
    
    @IBOutlet weak var addImage1Button: UIButton!
    @IBOutlet weak var image1ImageView: UIImageView!
    @IBOutlet weak var addImage2Button: UIButton!
    @IBOutlet weak var image2ImageView: UIImageView!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textTextView: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var pickerSelected: PickerType = .none {
        didSet {
            switch self.pickerSelected {
            case .category:
                self.pickerView.isHidden = false
                self.pickerView.reloadComponent(0)
                let index = Post.PostType.allCases.firstIndex(of: self.categorySelected)!
                self.pickerView.selectRow(index, inComponent: 0, animated: false)
            case .language:
                self.pickerView.isHidden = false
                self.pickerView.reloadComponent(0)
                let index = Post.LanguageType.allCases.firstIndex(of: self.languageSelected)!
                self.pickerView.selectRow(index, inComponent: 0, animated: false)
            case .none:
                self.pickerView.isHidden = true
            }
        }
    }
    
    var categorySelected: Post.PostType = .suggestion {
        didSet {
            self.categoryButton.setTitle("Catégorie: \(self.categorySelected.rawValue)", for: .normal)
        }
    }
    var languageSelected: Post.LanguageType = .french {
        didSet {
            self.languageButton.setTitle("Langue: \(self.languageSelected.rawValue)", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categorySelected = .suggestion
        self.languageSelected = .french
        
        self.image1ImageView.isUserInteractionEnabled = true
        self.image2ImageView.isUserInteractionEnabled = true
        self.image1ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(image1Selected(_:))))
        self.image2ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(image2Selected(_:))))
    }
    
    @IBAction func addImage1Action(_ sender: Any) {
        ImagePickerManager().pickImage(self) { image in
            self.image1ImageView.image = image
            self.addImage1Button.isHidden = true
            self.image1ImageView.isHidden = false
            self.addImage2Button.isHidden = false
        }
    }
    
    @IBAction func addImage2Action(_ sender: Any) {
        ImagePickerManager().pickImage(self) { image in
            self.image2ImageView.image = image
            self.addImage2Button.isHidden = true
            self.image2ImageView.isHidden = false
        }
    }
    
    @objc func image1Selected(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Vous souhaitez ?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Changer l'image", style: .default, handler: { _ in
            ImagePickerManager().pickImage(self) { image in
                self.image1ImageView.image = image
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Supprimer l'image", style: .destructive, handler: { _ in
            if let image = self.image2ImageView.image, !self.image2ImageView.isHidden {
                self.image1ImageView.image = image
                self.image2ImageView.image = nil
                self.image2ImageView.isHidden = true
                self.addImage2Button.isHidden = false
            } else {
                self.image1ImageView.image = nil
                self.image1ImageView.isHidden = true
                self.addImage1Button.isHidden = false
                self.addImage2Button.isHidden = true
                self.image2ImageView.isHidden = true
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func image2Selected(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Vous souhaitez ?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Changer l'image", style: .default, handler: { _ in
            ImagePickerManager().pickImage(self) { image in
                self.image2ImageView.image = image
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Supprimer l'image", style: .destructive, handler: { _ in
            self.image2ImageView.image = nil
            self.addImage2Button.isHidden = false
            self.image2ImageView.isHidden = true
        }))
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonPickerAction(_ sender: Any) {
        if (sender as? UIButton) == categoryButton {
            if self.pickerSelected == .category {
                self.pickerSelected = .none
            } else {
                self.pickerSelected = .category
            }
        } else if (sender as? UIButton) == languageButton {
            if self.pickerSelected == .language {
                self.pickerSelected = .none
            } else {
                self.pickerSelected = .language
            }
        }
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        guard Auth.auth().currentUser != nil else { return }
        guard let title = titleTextField.text, !title.isEmpty else {
            UIKitUtils.showAlert(in: self, message: "Le titre ne peut pas être vide", completion: {}); return
        }
        guard let text = textTextView.text, !text.isEmpty else {
            UIKitUtils.showAlert(in: self, message: "Le Text ne peut pas être vide", completion: {}); return
        }
        
        
        UIKitUtils.showAlert(
            in: self,
            message: "Êtes vous sur de vouloir publié ce post ?",
            action1Title: "Oui", completionOK: { self.publishPost(title: title, text: text) },
            action2Title: "Non", completionCancel: {})
    }
    
    func publishPost(title: String, text: String) {
        let user = Auth.auth().currentUser!
        let date = Date()
        let postId = "\(user.uid)-\(date.timeIntervalSince1970)"
        
        self.uploadImages(postId: postId, images: getImages()) { urls in
            let post = Post.create(
                by: user.uid,
                for: postId,
                text: text,
                images: urls,
                category: self.categorySelected,
                language: self.languageSelected,
                createAt: date)
            
            FirestoreUtils.savePost(post: post) { result in
                switch result {
                case .success():
                    UIKitUtils.showAlert(in: self, message: "Votre post à été publié") {
                        self.tabBarController?.selectedIndex = 3
                        self.tabBarController?.viewControllers?[2] = Tab3ViewController.getInstance()
                    }
                case .failure(let error):
                    StorageUtils.deleteImageFor(userId: user.uid, postId: postId, numberOfImages: urls.count)
                    UIKitUtils.showAlert(in: self, message: "Une erreur est survenue: \(error.localizedDescription)"){}
                }
            }
        }
        
    }
    
    private func uploadImages(postId: String, images: [UIImage], completion: @escaping ([String])->Void) {
        let user = Auth.auth().currentUser!
        
        guard images.count > 0 else { completion([]); return }
        
        StorageUtils.uploadImagePost(image: images[0], userId: user.uid, postId: postId, imageCount: 0) { result in
            switch result {
            case .success(let imageUrl1):
                guard images.count > 1 else {
                    completion([imageUrl1]); return
                }
                StorageUtils.uploadImagePost(image: images[1], userId: user.uid, postId: postId, imageCount: 1) { result in
                    switch result {
                    case .success(let imageUrl2):
                        completion([imageUrl1, imageUrl2])
                    case .failure(let error):
                        StorageUtils.deleteImageFor(userId: user.uid, postId: postId, numberOfImages: 1)
                        UIKitUtils.showAlert(in: self, message: "Une erreur c'est produite lors de l'upload de la deuxième image: \n\(error.localizedDescription)") {}; return
                    }
                }
            case .failure(let error):
                UIKitUtils.showAlert(in: self, message: "Une erreur c'est produite lors de l'upload de la première image: \n\(error.localizedDescription)") {}; return
            }
        }
    }
    
    private func getImages() -> [UIImage] {
        var images: [UIImage] = []
        if let image1 = self.image1ImageView.image, !self.image1ImageView.isHidden { images.append(image1) }
        if let image2 = self.image2ImageView.image, !self.image2ImageView.isHidden { images.append(image2) }
        return images
    }
}

extension Tab3ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerSelected.listItem.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return
            (self.pickerSelected.listItem[row] as? Post.PostType)?.rawValue ??
                (self.pickerSelected.listItem[row] as? Post.LanguageType)?.rawValue
    }
}

extension Tab3ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch self.pickerSelected {
        case .category:
            self.categorySelected = self.pickerSelected.listItem[row] as! Post.PostType
        case .language:
            self.languageSelected = self.pickerSelected.listItem[row] as! Post.LanguageType
        case .none: break
        }
    }
}
