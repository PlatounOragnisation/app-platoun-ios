//
//  PromocodeCell.swift
//  Platoun
//
//  Created by Flavian Mary on 28/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class PromocodeCell: UITableViewCell {
    static let identifier = "PromocodeCell"
    
    struct Object {
        let imageUrl: String
        let promocode: Int
        let groupId: String
        let title: String
        let subTitle: String
        let timeEnd: Date
        let dateValidated: Date
        let link: String
        let promoCodeValue: String
                
        static func setup(_ from: WebPromoStatus) -> Object {
            return Object(
                imageUrl: from.productPicture,
                promocode: from.percentage,
                groupId: from.groupId,
                title: from.productName,
                subTitle: from.productBrand,
                timeEnd: from.dateValidated.addingTimeInterval(72 * 60 * 60),
                dateValidated: from.dateValidated,
                link: from.buyLink,
                promoCodeValue: from.promoCode
            )
        }
    }
        
    var object: Object?
    private var timer: Timer?
    
    @IBOutlet weak var content: BorderedView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var promocodeLabel: UILabel!
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
        timeLeftLabel.text = object.promoCodeValue
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
            
            statusLabel.text = "\(hours)h \(min)min"
        } else {
            statusLabel.text = "00h 00min"
        }
        return countSecond
    }
}
