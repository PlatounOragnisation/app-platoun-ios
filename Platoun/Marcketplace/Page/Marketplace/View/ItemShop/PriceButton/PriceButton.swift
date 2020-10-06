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
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    @IBInspectable
    var price: Int = 200{
        didSet {
            priceLabel.text = "\(self.price)€"
        }
    }
    
    @IBInspectable
    var isSolo: Bool = true{
        didSet {
            let imageName: String = self.isSolo ? "ic-solo" : "ic-group"
            icon.image = UIImage(named: imageName, in: Bundle.platoun, compatibleWith: nil)
            
            let priceColor = self.isSolo
            ? UIColor.rgb(red: 55, green: 71, blue: 79, alpha: 1)
                : UIColor.white
            priceLabel.textColor = priceColor
            
            let backgroundColor = self.isSolo
            ? UIColor.rgb(red: 214, green: 212, blue: 220, alpha: 1)
                : ThemeColor.BackgroundGradient2
            content.backgroundColor = backgroundColor
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
    }
    
    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.layer.borderColor = UIColor.white.cgColor
        self.content.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = bounds.height / 2
        self.content.layer.cornerRadius = bounds.height / 2
        self.layer.borderWidth = 2
        self.content.layer.borderWidth = 2
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.layer.cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.rgb(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowLayer.shadowOpacity = 1
            shadowLayer.shadowRadius = 1

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}
