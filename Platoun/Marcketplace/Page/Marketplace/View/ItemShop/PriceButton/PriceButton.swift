//
//  PriceButton.swift
//  Platoun
//
//  Created by Flavian Mary on 10/01/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit


class PriceButton: UIView{
    var view: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var iconSolo: UIImageView!
    @IBOutlet weak var iconGroup: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBInspectable
    var price: Int = 200{
        didSet {
            priceLabel.text = "\(self.price)€"
        }
    }
    
    @IBInspectable
    var isSolo: Bool = true{
        didSet {
            iconSolo.isHidden = !self.isSolo
            iconGroup.isHidden = self.isSolo
            
            backgroundImage.image = self.isSolo
                ? UIImage(named: "img-background-price-solo")
                : UIImage(named: "img-background-price-group")
            
            let priceColor = self.isSolo
            ? UIColor.rgb(red: 55, green: 71, blue: 79, alpha: 1)
                : UIColor.white
            priceLabel.textColor = priceColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadViewFromNib()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle.platoun
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        self.view = view
        self.view.backgroundColor = .clear
    }
}
