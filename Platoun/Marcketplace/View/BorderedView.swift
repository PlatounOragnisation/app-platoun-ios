//
//  BorderedView.swift
//  Platoun
//
//  Created by Flavian Mary on 12/01/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedView: UIView {    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    var visibleView: UIView!
    
    func setupView() {
        visibleView = UIView()
        visibleView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(visibleView, at: 0)
        
        visibleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        visibleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        visibleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        visibleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        
    }
    
    @IBInspectable
    var isShadowed: Bool = false
    
    @IBInspectable
    var borderWidth: CGFloat = 1
    
    @IBInspectable
    var cornerRadius: CGFloat = 3
    
    @IBInspectable
    var shadowAlpha: CGFloat = 25
    
    @IBInspectable
    var shadowRadius: CGFloat = 1
    
    private var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.visibleView.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.visibleView.backgroundColor = self.backgroundColor ?? UIColor.white
        
        if !isShadowed { return }
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.clear.cgColor
        
        shadowLayer.shadowColor = UIColor.rgb(red: 0, green: 0, blue: 0, alpha: shadowAlpha/100).cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = shadowRadius

    }
}
