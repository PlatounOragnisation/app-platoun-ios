//
//  CommentTableViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 24/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    static let identifier: String = "CommentTableViewCell"
    
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var textCommentLabel: UITextView!
    @IBOutlet weak var firstImageView: UIImageView!
    
    @IBOutlet weak var secondImageView: UIImageView!
    
    let regularFont = UIFont(name: "Roboto-Regular", size: 14.0)!
    let boldFont = UIFont(name: "Roboto-Bold", size: 14.0)!

    
    func setup(comment: Comment) {
        
        if let value = comment.authorPhoto, let url = URL(string: value) {
            self.creatorImageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.creatorImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
        
        if comment.images.count > 0, let url = URL(string: comment.images[0]) {
            self.firstImageView.isHidden = false
            self.firstImageView.setImage(with: url, placeholder: nil, options: .progressiveLoad)
        } else {
            self.firstImageView.isHidden = true
        }
        
        if comment.images.count > 1, let url = URL(string: comment.images[1]) {
            self.secondImageView.isHidden = false
            self.secondImageView.setImage(with: url, placeholder: nil, options: .progressiveLoad)
        } else {
            self.secondImageView.isHidden = true
        }
        
        let text: NSMutableAttributedString
        if let name = comment.authorName {
            text = NSMutableAttributedString(string: "\(name) \(comment.text)", attributes: [.font : regularFont])
            text.addAttributes([.font: boldFont], range: NSRange(location: 0, length: name.count))
        } else {
            text = NSMutableAttributedString(string: comment.text, attributes: [.font : regularFont])
        }
        self.textCommentLabel.attributedText = text
    }
}
