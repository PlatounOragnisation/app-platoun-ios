//
//  BottomTab.swift
//  Platoun
//
//  Created by Flavian Mary on 29/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

class BottomTab: UIView {
    
    
    let tabButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: -15, left: -10, bottom: -12, right: -10)
        button.setImage(UIImage(named: "ic-bottom-tab"), for: .normal)
        return button
    }()
    
    let tabSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeColor.c979797
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func initialize() {
        addSubview(tabButton)
        addSubview(tabSeparator)
        
        backgroundColor = UIColor.clear
        
        let constraints = [
            tabButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5),
            tabButton.heightAnchor.constraint(equalToConstant: 36),
            tabButton.widthAnchor.constraint(equalToConstant: 42),
            
            
            tabSeparator.bottomAnchor.constraint(equalTo: tabButton.topAnchor, constant: -12),
            tabSeparator.heightAnchor.constraint(equalToConstant: 0.2),
            tabSeparator.leftAnchor.constraint(equalTo: leftAnchor),
            tabSeparator.rightAnchor.constraint(equalTo: rightAnchor),
            tabSeparator.topAnchor.constraint(equalTo: topAnchor),
            
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
