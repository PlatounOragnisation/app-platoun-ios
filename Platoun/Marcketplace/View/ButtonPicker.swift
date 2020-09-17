//
//  ButtonPicker.swift
//  Platoun
//
//  Created by Flavian Mary on 07/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class ButtonPicker: UIButton, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        list[row]
    }
    
    private var list: [String] = []
    
    lazy var picker = UIPickerView()
    
    override var inputView: UIView? {
        get {
            picker
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func updateList(_ list: [String]) {
        self.list = list
        self.picker.reloadComponent(0)
    }
    
    func setupView() {
        picker.delegate = self
        picker.dataSource = self
    }
}
