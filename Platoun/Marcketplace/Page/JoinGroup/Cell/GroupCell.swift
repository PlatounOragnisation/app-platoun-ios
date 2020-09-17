//
//  GroupCell.swift
//  Platoun
//
//  Created by Flavian Mary on 22/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

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
    
    var delegate: GroupCellDelegate?
    
    @IBOutlet weak var creatorImage: RoundedImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var userContainer: BorderedView!
    @IBOutlet weak var user1Image: RoundedImageView!
    @IBOutlet weak var user2Image: RoundedImageView!
    @IBOutlet weak var user3Image: RoundedImageView!
    @IBOutlet weak var user4Image: RoundedImageView!
    @IBOutlet weak var user5Image: RoundedImageView!
    @IBOutlet weak var joinButton: BorderedButton!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var dealLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var group: Group!
    
    private var timer: Timer?

    var isLoading: Bool = false
    
    func setup(group: Group, delegate: GroupCellDelegate?, isLoading: Bool) {
        self.group = group
        self.delegate = delegate
        self.isLoading = isLoading
        
        self.creatorImage.downloaded(from: group.groupCreator.image, contentMode: .scaleAspectFill)
        self.creatorLabel.text = group.groupCreator.name
        
        
        definedUserImage(self.user1Image, index: 0)
        definedUserImage(self.user2Image, index: 1)
        definedUserImage(self.user3Image, index: 2)
        
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
            joinButton.borderColor = UIColor(hex: "#00D5CA")!
            joinButton.setTitle("Quit".localise(), for: .normal)
            joinButton.backgroundColor = UIColor(hex: "#E9E9E9")
            joinButton.setTitleColor(UIColor(hex: "#222222"), for: .normal)
            joinButton.borderWidth = 2
            userContainer.backgroundColor = UIColor(hex: "#E9E9E9")
            userContainer.tintColor = UIColor(hex: "#00D5CA")
        } else {
            joinButton.borderColor = UIColor(hex: "#FFFFFF")!
            joinButton.setTitle("Join".localise(), for: .normal)
            joinButton.backgroundColor = UIColor(hex: "#038091")
            joinButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
            joinButton.borderWidth = 2
            userContainer.backgroundColor = UIColor(hex: "#038091")
            userContainer.tintColor = UIColor(hex: "#FFFFFF")
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
            
            if user?.id == HttpServices.shared.user?.id {
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
            image.downloaded(from: user.image, contentMode: .scaleAspectFill)
        } else {
            let name = self.group.isPrivate ? "ic-private" : "ic-noUser"
            
            image.image = UIImage(named: name)
        }
    }
    
    @IBAction func actionJoin(_ sender: Any) {
        guard !isLoading else { return }
        guard self.group.endDate >= Date() else {
            self.delegate?.endOfTime()
            return
        }
        
        if self.group.haveJoin {
            if self.group.users.getOrNil(0)?.id != HttpServices.shared.user?.id {
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