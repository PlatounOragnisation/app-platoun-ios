//
//  SugestViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 01/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

class SugestViewController: UIViewController {
        
    var image: UIImage?
    
    @IBOutlet weak var titleLabel: StyleLabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryButton: NSLayoutConstraint!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productCommentTextView: UITextView!
    @IBOutlet weak var productCommentPlaceHolder: UITextView!
    @IBOutlet weak var productLinkTextField: UITextField!
    
    func setGradientBackground() {
        let colorTop =  ThemeColor.cFEFEFE.cgColor
        let colorBottom = ThemeColor.cF7F6FB.cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        
        if let navBar = self.navigationController?.navigationBar, !navBar.isHidden {
            let rect = CGRect(
                x: self.view.bounds.minX,
                y: self.view.bounds.minY,
                width: self.view.bounds.width,
                height: self.view.bounds.height + navBar.bounds.height)
            gradientLayer.frame = rect
        } else {
            gradientLayer.frame = self.view.bounds
        }
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setGradientBackground()
        super.viewWillAppear(animated)
        titleLabel.update(colors: [ThemeColor.BackgroundGradient1, ThemeColor.BackgroundGradient2])
        imageView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productCommentPlaceHolder.delegate = self
        productCommentTextView.delegate = self
        
        
        
        productNameTextField.attributedPlaceholder =
            NSAttributedString(string: "Nom du produit", attributes: [NSAttributedString.Key.foregroundColor: ThemeColor.c9B9B9B])
        productLinkTextField.attributedPlaceholder =
            NSAttributedString(string: "(Optionel) : Lien du produit", attributes: [NSAttributedString.Key.foregroundColor: ThemeColor.c9B9B9B])

    }
    
    
    @IBAction func shareActionTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension SugestViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == productCommentPlaceHolder {
            productCommentTextView.becomeFirstResponder()
            productCommentTextView.isHidden = false
            productCommentPlaceHolder.isHidden = true
            return false
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == productCommentTextView && productCommentTextView.text.count == 0{
            productCommentTextView.isHidden = true
            productCommentPlaceHolder.isHidden = false
            productCommentPlaceHolder.setContentOffset(CGPoint.zero, animated: false)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let string = textView.text, let textRange = Range(range, in: string) else { return false }
        let updatedText = string.replacingCharacters(in: textRange, with: text)
        if updatedText.last == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if updatedText.contains("\n") {
            let te = updatedText.replacingOccurrences(of: "\n", with: "")
            textView.text = te
            return false
        }
        if range.length > 0 {
            guard textView.text.count + text.count > 300 else { return true }
            return range.length >= text.count
        }
        return textView.text.count + text.count <= 300
    }
}
