//
//  CheckableItemView.swift
//  Platoun
//
//  Created by Flavian Mary on 08/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol CheckableItemViewAction {
    func toogle(view: CheckableItemView)
}

@IBDesignable
class CheckableItemView: UIView {
    var delegate: CheckableItemViewAction?
    
//    init() {
//        self.title.isLocalized = false
//        super.init()
//    }
    
    @IBInspectable
    var text: String? {
        get { self.title.text }
        set { self.title.localizedText = newValue }
    }
    
    var isLocalized: Bool {
        get { self.title.isLocalized }
        set { self.title.isLocalized = newValue }
    }
    
    @IBInspectable
    var checked: Bool {
        get { self.check.isOn }
        set { self.check.isOn = newValue }
    }
    
    lazy var title: UILabelLocalized = {
        let view = UILabelLocalized()
        view.font = .helvetica(type: .medium, fontSize: 18)
        view.textColor = UIColor(hex: "#B6B6B6")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var check: UISwitch = {
        let view = UISwitch()
        view.onTintColor = UIColor(hex: "#009688")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(toogle(sender:)), for: .valueChanged)
        return view
    }()
    
    @objc func toogle(sender: UISwitch) {
        self.delegate?.toogle(view: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.backgroundColor = .clear
        self.addSubview(title)
        self.addSubview(check)
        
        let constraints = [
            title.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30),
            title.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            check.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            check.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
