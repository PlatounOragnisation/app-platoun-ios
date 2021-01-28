//
//  BottomButton.swift
//  Platoun
//
//  Created by Flavian Mary on 28/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import PopBounceButton

class BottomButton: PopBounceButton {

  override init() {
    super.init()
    adjustsImageWhenHighlighted = false
    backgroundColor = .white
    layer.masksToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    layer.cornerRadius = frame.width / 2
  }
}
