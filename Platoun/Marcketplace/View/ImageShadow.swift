//
//  ImageShadow.swift
//  Platoun
//
//  Created by Flavian Mary on 15/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

@IBDesignable
class ImageShadow: UIView {
    
    @IBInspectable
    var image: UIImage? {
        didSet {
            imageLayer.contents = self.image?.cgImage
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 20
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    lazy var shadows: UIView = {
        let shadows = UIView()
        shadows.clipsToBounds = false
        return shadows
    }()
    
    lazy var layer0: CALayer = {
        let layer0 = CALayer()
        return layer0
    }()
    
    lazy var shapes: UIView = {
        let shapes = UIView()
        shapes.clipsToBounds = true
        return shapes
    }()
    
    lazy var imageLayer: CALayer = {
        let imageLayer = CALayer()
        return imageLayer
    }()
    
    lazy var mainView: UIView = {
        var view = UILabel()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupView() {
        mainView.addSubview(shadows)
        shadows.layer.addSublayer(layer0)
        mainView.addSubview(shapes)
        shapes.layer.addSublayer(imageLayer)
        
        self.addSubview(mainView)
        let constraints = [
            mainView.topAnchor.constraint(equalTo: self.topAnchor),
            mainView.rightAnchor.constraint(equalTo: self.rightAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mainView.leftAnchor.constraint(equalTo: self.leftAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        
        shadows.frame = mainView.frame
        layer0.shadowPath = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: cornerRadius).cgPath
        layer0.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 4
        layer0.shadowOffset = CGSize(width: 0, height: 4)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shapes.frame = mainView.frame
        imageLayer.contents = image?.cgImage
        imageLayer.bounds = shapes.bounds
        imageLayer.position = shapes.center
        imageLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 1.08, tx: 0, ty: -0.04))
        shapes.layer.cornerRadius = cornerRadius
    }
}
