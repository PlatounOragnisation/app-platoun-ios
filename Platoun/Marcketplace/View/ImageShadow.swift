//
//  ImageShadow.swift
//  Platoun
//
//  Created by Flavian Mary on 15/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class ImageShadow: UIView, IDrawRoundView, IDrawShadowView {
    var roundBackgroundColor: UIColor? = UIColor.white
    
    var shadowColor: UIColor = UIColor.black
    
    var shadowColorAlpha: CGFloat = 25
    
    var shadowBlur: CGFloat = 4
    
    var shadowOffsetWidth: CGFloat = 0
    
    var shadowOffsetHeight: CGFloat = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    lazy var imageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    func setup() {
        self.addSubview(imageView)
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    
    @IBInspectable
    var imageContent: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    
    @IBInspectable
    var cornerRadius: CGFloat = 20
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.layer.cornerRadius = cornerRadius
        self.imageView.layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        self.drawRound(rect: rect, context: context)
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        self.drawShadow(layer)
    }
    
}
