//
//  DropDownView.swift
//  Platoun
//
//  Created by Flavian Mary on 11/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

@IBDesignable
class DropDownView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBInspectable
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = UIFont.helvetica(type: .medium, fontSize: 14)
        view.textColor = UIColor(hex: "#222222")!
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var arrowIsDown = true
    private lazy var arrow: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ic-arrow-right"))
        let rotations: CGFloat = 90
        view.transform = CGAffineTransform(rotationAngle: rotations.radian)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func toogleArrow() {
        UIView.animate(withDuration: 0.3) {
            UIView.setAnimationCurve(.linear)
            let rotations: CGFloat = self.arrowIsDown ? -90 : 90
            self.arrowIsDown = !self.arrowIsDown
            self.arrow.transform = CGAffineTransform(rotationAngle: rotations.radian)
        }
    }
    
    private func setupView() {
        self.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        self.addSubview(arrow)
        
        arrow.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        arrow.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 16).isActive = true
        arrow.widthAnchor.constraint(equalToConstant: 15).isActive = true

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor(hex: "#038091")?.cgColor
    }
}
