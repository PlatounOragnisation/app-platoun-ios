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

//@IBDesignable
//class ImageShadow: UIView {
//
//    @IBInspectable
//    var image: UIImage? {
//        didSet {
//            imageLayer.contents = self.image?.cgImage
//        }
//    }
//
//    @IBInspectable
//    var cornerRadius: CGFloat = 20
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        self.setupView()
//    }
//
//    lazy var shadows: UIView = {
//        let shadows = UIView()
//        shadows.clipsToBounds = false
//        return shadows
//    }()
//
//    lazy var layer0: CALayer = {
//        let layer0 = CALayer()
//        return layer0
//    }()
//
//    lazy var shapes: UIView = {
//        let shapes = UIView()
//        shapes.clipsToBounds = true
//        return shapes
//    }()
//
//    lazy var imageLayer: CALayer = {
//        let imageLayer = CALayer()
//        return imageLayer
//    }()
//
//    lazy var mainView: UIView = {
//        var view = UILabel()
//        view.backgroundColor = .clear
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    private func setupView() {
//        mainView.addSubview(shadows)
//        shadows.layer.addSublayer(layer0)
//        mainView.addSubview(shapes)
//        shapes.layer.addSublayer(imageLayer)
//
//        self.addSubview(mainView)
//        let constraints = [
//            mainView.topAnchor.constraint(equalTo: self.topAnchor),
//            mainView.rightAnchor.constraint(equalTo: self.rightAnchor),
//            mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            mainView.leftAnchor.constraint(equalTo: self.leftAnchor)
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.backgroundColor = .clear
//
//        shadows.frame = mainView.frame
//        layer0.shadowPath = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: cornerRadius).cgPath
//        layer0.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//        layer0.shadowOpacity = 1
//        layer0.shadowRadius = 4
//        layer0.shadowOffset = CGSize(width: 0, height: 4)
//        layer0.bounds = shadows.bounds
//        layer0.position = shadows.center
//        shapes.frame = mainView.frame
//        imageLayer.contents = image?.cgImage
//        imageLayer.bounds = shapes.bounds
//        imageLayer.position = shapes.center
//        imageLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 1.08, tx: 0, ty: -0.04))
//        shapes.layer.cornerRadius = cornerRadius
//    }
//}
