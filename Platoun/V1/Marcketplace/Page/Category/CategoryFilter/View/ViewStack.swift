//
//  ViewStack.swift
//  Platoun
//
//  Created by Flavian Mary on 12/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class ViewStack: UIView {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.spacing = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var count: Int {
        get { self.stack.arrangedSubviews.count }
    }
    
    
    subscript(index: Int) -> RoundedLabel? {
        get { self.stack.arrangedSubviews.getOrNil(index) as? RoundedLabel }
        set {
            if let view = self.stack.arrangedSubviews.getOrNil(index) as? RoundedLabel {
                view.text = newValue?.text
                view.isSelected = newValue?.isSelected ?? false
            } else {
                self.stack.insertArrangedSubview(newValue!, at: index)
            }
        }
    }
    
    func addView(_ view: UIView) {
        stack.addArrangedSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let maxWidth = UIScreen.main.bounds.size.width
        let ratio: CGFloat = 101 / 375
        
        let width: CGFloat = maxWidth * ratio
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    private func setupView() {
        self.addSubview(stack)
        
        self.stack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
}
