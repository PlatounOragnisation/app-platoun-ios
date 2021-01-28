//
//  GroupStatusCell.swift
//  Platoun
//
//  Created by Flavian Mary on 28/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class GroupStatusCell: UITableViewCell {
    static let identifier = "GroupStatusCell"
    
    struct Object {
        let imageUrl: String
        let promocode: Int
        let title: String
        let subTitle: String
        let timeEnd: Date
        let dateAdded: Date
        let promoCodeValue: String
        let link: String
        let state: State
        let productId: String?
        let categoryId: String?
        
        static func setup(_ from: WebGroupStatus) -> Object {
            let state: State
            switch from.status {
            case .pending:
                state = .pending
            case .validated:
                state = .success
            case .failed:
                state = .failed
            }
            
            let count = (from.maxUsers == 5 ? 72 : 48) * 60 * 60
            
            return Object(
                imageUrl: from.productPicture,
                promocode: from.percentage,
                title: from.productName,
                subTitle: from.productBrand,
                timeEnd: from.dateAdded.addingTimeInterval(TimeInterval(count)),
                dateAdded: from.dateAdded,
                promoCodeValue: from.promoCode ?? "",
                link: from.buyLink,
                state: state,
                productId: from.productId,
                categoryId: from.categoryId)
        }
        
        enum State {
            case success
            case pending
            case failed
            
            var value: String {
                switch self {
                case .success:
                    return "Success".localise()
                case .pending:
                    return "Pending".localise()
                case .failed:
                    return "Failed".localise()
                }
            }
            
            var color: UIColor {
                switch self {
                case .success:
                    return UIColor(hex: "#3D9DAA")!
                case .pending:
                    return UIColor(hex: "#FFBA49")!
                case .failed:
                    return UIColor(hex: "#37474F")!
                }
            }
        }
    }
    
    var object: Object?
    private var timer: Timer?
    
    @IBOutlet weak var content: BorderedView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var promocodeLabel: UILabel!
    @IBOutlet weak var promocodeTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        content.layer.masksToBounds = true
    }
    
    lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    func setup(_ object: Object) {
        self.object = object
        
        self.selectedBackgroundView = background
        
        productImage.setImage(with: URL(string: object.imageUrl), placeholder: nil, options: .progressiveLoad)
        promocodeLabel.text = "\(object.promocode)%"
        titleLabel.text = object.title
        subtitleLabel.text = object.subTitle
        statusLabel.text = object.state.value
        
        self.promocodeTitleLabel.isHidden = object.state == .failed || object.promocode == 0
        self.promocodeLabel.isHidden = object.state == .failed || object.promocode == 0
        
        statusLabel.textColor = object.state.color
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
        let endDate = self.object!.timeEnd
        let countSecond = Int(endDate.timeIntervalSince(date))
        if(countSecond >= 0) {
            let hours: Int = (countSecond / (60 * 60))
            let min: Int = (countSecond / 60) - ( 60 * hours )
            
            timeLeftLabel.text = "\(hours)h \(min)min"
        } else {
            timeLeftLabel.text = "00h 00min"
        }
        return countSecond
    }
}
