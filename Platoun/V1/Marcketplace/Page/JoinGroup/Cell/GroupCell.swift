//
//  GroupCell.swift
//  Platoun
//
//  Created by Flavian Mary on 22/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol GroupCellDelegate {
    func joinGroup(_ cell: GroupCell, group: Group)
    func leaveGroup(_ cell: GroupCell, group: Group)
    func joinPrivateGroup(_ cell: GroupCell, group: Group, forJoin: Bool)
    func sendInvitation(_ cell: GroupCell, group: Group)
    func endOfTime()
    func iamCreator(_ cell: GroupCell, group: Group)
}

class GroupCell: UITableViewCell {
    static let identifier = "GroupCell"
    
    @IBOutlet weak var bgImageView: UIImageView!
    var delegate: GroupCellDelegate?
    
    @IBOutlet weak var creatorImage: RoundedImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var userContainer: UIView!
    @IBOutlet weak var user1Image: RoundedImageView!
    @IBOutlet weak var user2Image: RoundedImageView!
    @IBOutlet weak var user3Image: RoundedImageView!
    @IBOutlet weak var user4Image: RoundedImageView!
    @IBOutlet weak var user5Image: RoundedImageView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var dealLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var group: Group!
    
    private var timer: Timer?

    var isLoading: Bool = false
    var users: [String: PlatounUser] = [:]
    func setup(group: Group, users: [String:PlatounUser], delegate: GroupCellDelegate?, isLoading: Bool) {
        self.group = group
        self.users = users
        self.delegate = delegate
        self.isLoading = isLoading
        
        if let value = users[group.groupCreator.id]?.photoUrl, let url = URL(string: value) {
            self.creatorImage.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.creatorImage.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
        self.creatorLabel.text = users[group.groupCreator.id]?.displayName ?? "No Name"
        
        
        definedUserImage(self.user1Image, index: 0)
        definedUserImage(self.user2Image, index: 1)
        definedUserImage(self.user3Image, index: 2)
        
        let selectName = group.haveJoin ? "unselect" : "select"
        let indexName = group.maxUsers == 3 ? 3 : 5
        self.bgImageView.image = UIImage(named: "img-bg-join-\(selectName)-\(indexName)")

        
        if group.maxUsers == 3 {
            self.user4Image.isHidden = true
            self.user5Image.isHidden = true
        } else {
            self.user4Image.isHidden = false
            self.user5Image.isHidden = false
            definedUserImage(self.user4Image, index: 3)
            definedUserImage(self.user5Image, index: 4)
        }
        
        

        if group.haveJoin {
            joinButton.setBackgroundImage(UIImage(named: "bg-quit-button"), for: .normal)
            joinButton.setTitle("Quit".localise(), for: .normal)
            joinButton.setTitleColor(UIColor(hex: "#222222"), for: .normal)
        } else {
            joinButton.setBackgroundImage(UIImage(named: "bg-join-button"), for: .normal)
            joinButton.setTitle("Join".localise(), for: .normal)
            joinButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        }
        
        userContainer.setNeedsLayout()
        
        
        
        
        if isLoading {
            self.loader.isHidden = false
            self.loader.startAnimating()
            self.joinButton.isHidden = true
            self.lockImage.isHidden = true
        } else {
            self.loader.isHidden = true
            self.joinButton.isHidden = false
            self.lockImage.isHidden = !group.isPrivate
        }
        
        user1Image.isUserInteractionEnabled = true
        user2Image.isUserInteractionEnabled = true
        user3Image.isUserInteractionEnabled = true
        user4Image.isUserInteractionEnabled = true
        user5Image.isUserInteractionEnabled = true
        
        user1Image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClicUser(_:))))
        user2Image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClicUser(_:))))
        user3Image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClicUser(_:))))
        user4Image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClicUser(_:))))
        user5Image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClicUser(_:))))
    }
    
    @objc func actionClicUser(_ sender: UITapGestureRecognizer) {
        guard !isLoading else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard self.group.endDate >= Date() else {
            self.delegate?.endOfTime()
            return
        }
        
        let index: Int
        switch sender.view {
        case user1Image:
            index = 0
        case user2Image:
            index = 1
        case user3Image:
            index = 2
        case user4Image:
            index = 3
        case user5Image:
            index = 4
        default:
            return
        }
        
        if !self.group.haveJoin {
            if self.group.isPrivate {
                self.delegate?.joinPrivateGroup(self, group: self.group, forJoin: true)
            } else {
                self.delegate?.joinGroup(self, group: self.group)
            }
        } else {
            let user = self.group.users.getOrNil(index)
            
            if user?.id == currentUserId {
                if index > 0 {
                    self.delegate?.leaveGroup(self, group: self.group)
                } else {
                    self.delegate?.iamCreator(self, group: self.group)
                }
            } else {
                if self.group.isPrivate {
                    self.delegate?.joinPrivateGroup(self, group: self.group, forJoin: false)
                } else {
                    self.delegate?.sendInvitation(self, group: self.group)
                }
            }
        }
    }
    
    func startTimer() {
        if timer == nil {
            _ = self.update()
            timer = Timer(timeInterval: 60.0, repeats: true) { _ in
                let countSecond = self.update()
                if countSecond <= 0 {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func update() -> Int{
        let date = Date()
        let endDate = self.group!.endDate
        let countSecond = Int(endDate.timeIntervalSince(date))
        if(countSecond >= 0) {
            let hours: Int = (countSecond / (60 * 60))
            let min: Int = (countSecond / 60) - ( 60 * hours )
            
            dealLabel.text = "Deal ends in".localise() + " \(hours)h \(min)m"
        } else {
            dealLabel.text = "Deal ends finish".localise()
        }
        return countSecond
    }
    
    func definedUserImage(_ image: UIImageView, index: Int) {
        if let user = (self.group?.users ?? []).getOrNil(index) {
            if let value = self.users[user.id]?.photoUrl, let url = URL(string: value) {
                image.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
            } else {
                image.image = #imageLiteral(resourceName: "ic_social_default_profil")
            }
        } else {
            let name = self.group.isPrivate ? "ic-private" : "ic-noUser"
            
            image.image = UIImage(named: name)
        }
    }
    
    @IBAction func actionJoin(_ sender: Any) {
        guard !isLoading else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard self.group.endDate >= Date() else {
            self.delegate?.endOfTime()
            return
        }
        
        if self.group.haveJoin {
            if self.group.users.getOrNil(0)?.id != userId {
                self.delegate?.leaveGroup(self, group: self.group)
            } else {
                self.delegate?.iamCreator(self, group: self.group)
            }
        } else {
            if self.group.isPrivate {
                self.delegate?.joinPrivateGroup(self, group: self.group, forJoin: true)
            } else {
                self.delegate?.joinGroup(self, group: self.group)
            }
        }
    }
}
