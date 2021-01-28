//
//  RateView.swift
//  Platoun
//
//  Created by Flavian Mary on 11/01/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class RateView: UIView {
    var view: UIView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var numberRate: UILabel!
    
    var stars: [UIImageView] {
        get { [star1, star2, star3, star4, star5] }
    }
    
    @IBInspectable
    var rate: Int = 5{
        didSet {
            stars.enumerated().forEach { (arg0) in
                let (index, img) = arg0
                img.image = (index+1) <= self.rate ? UIImage(named: "ic-star-on") : UIImage(named: "ic-star-off")
            }
        }
    }
    
    @IBInspectable
    var rateNumber: Int = 10{
        didSet {
            numberRate.text = "(\(self.rateNumber))"
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
}
