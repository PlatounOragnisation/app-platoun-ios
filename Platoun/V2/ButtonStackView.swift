//
//  ButtonStackView.swift
//  Platoun
//
//  Created by Flavian Mary on 28/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import PopBounceButton

protocol ButtonStackViewDelegate: AnyObject {
    func didTapButton(buttonType: ButtonStackView.ButtonType)
}

class ButtonStackView: UIStackView {
    
    enum ButtonType {
        case category, pass, star, like, messages
    }
    
    weak var delegate: ButtonStackViewDelegate?
    
    private let categoryButton: BottomButton = {
        let button = BottomButton()
        button.setImage(UIImage(named: "ic-category"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 1
        return button
    }()
    
    private let passButton: BottomButton = {
        let button = BottomButton()
        button.setImage(UIImage(named: "ic-pass"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 2
        return button
    }()
    
    private let superLikeButton: BottomButton = {
        let button = BottomButton()
        button.setImage(UIImage(named: "ic-star"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 3
        return button
    }()
    
    private let likeButton: BottomButton = {
        let button = BottomButton()
        button.setImage(UIImage(named: "ic-like"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 4
        return button
    }()
    
    private let messagesButton: BottomButton = {
        let button = BottomButton()
        button.setImage(UIImage(named: "ic-messages"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .equalSpacing
        alignment = .center
        configureButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButtons() {
        addEnmptySubview()
        addArrangedSubview(from: categoryButton, size: 42)
        addArrangedSubview(from: passButton, size: 56)
        addArrangedSubview(from: superLikeButton, size: 60)
        addArrangedSubview(from: likeButton, size: 56)
        addArrangedSubview(from: messagesButton, size: 42)
        addEnmptySubview()
    }
    
    private func addArrangedSubview(from button: UIView, size: CGFloat) {
        let container = ButtonContainer()
        container.addSubview(button)
        button.anchorToSuperview()
        addArrangedSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(equalToConstant: size).isActive = true
        container.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }
    
    private func addEnmptySubview() {
        let view = UIView()
        addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 0).isActive = true
    }
        
    @objc
    private func handleTap(_ button: BottomButton) {
        
        let type: ButtonType
        switch button {
        case categoryButton:
            type = .category
        case passButton:
            type = .pass
        case superLikeButton:
            type = .star
        case likeButton:
            type = .like
        case messagesButton:
            type = .messages
        default: return
        }
        
        delegate?.didTapButton(buttonType: type)
    }
}

private class ButtonContainer: UIView {
    
    override func draw(_ rect: CGRect) {
        applyShadow(radius: 0.03 * bounds.width, opacity: 0.12, offset: CGSize(width: 0, height: 0.05 * bounds.width))
    }
}
