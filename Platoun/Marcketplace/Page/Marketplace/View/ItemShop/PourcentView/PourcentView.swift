//
//  PourcentView.swift
//  Platoun
//
//  Created by Flavian Mary on 11/01/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class PourcentView: UIView {
    var view: UIView!
    
    @IBOutlet weak var prctLabel: UILabel!
    
    
    @IBInspectable
    var prct: Int = 8{
        didSet {
            self.prctLabel.text = "- \(self.prct)%"
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
        
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
    }
}
