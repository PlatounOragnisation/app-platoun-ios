//
//  DropDownPostView.swift
//  Platoun
//
//  Created by Flavian Mary on 20/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import DropDown

class DropDownPostView: UIView {

    var items: [String] = [] {
        didSet {
            self.dropDown.dataSource = self.items
            if text?.isEmpty ?? true {
                self.text = self.items.first
            }
        }
    }
    
    func getItemSelected() -> String {
        if let text = self.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            return text
        } else {
            return self.items.first ?? ""
        }
    }
    
    private var text: String? {
        get { self.label.text }
        set { self.label.text = newValue }
    }
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var label: UILabel!
    
    
    private var dropDown = DropDown()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("DropDownPostView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.text = ""
        dropDown.anchorView = self
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.text = item
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.backgroundColor = self.backgroundColor
        
        self.layer.borderWidth = 1
        self.layer.borderColor = ThemeColor.ValidateBorder.cgColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClick)))
    }
    
    @objc private func actionClick() {
        self.dropDown.show()
    }
}
