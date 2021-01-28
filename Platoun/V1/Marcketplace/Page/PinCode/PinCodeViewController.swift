//
//  PinCodeViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 01/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class PinCodeViewController: LightViewController {
    
    static func instance(correctPin: String?, success: @escaping (String) -> Void, error: ((PinError)->Void)? = nil) -> PinCodeViewController {
        let vc = PinCodeViewController.instanceStoryboard()
        vc.correctPin = correctPin
        vc.success = success
        vc.error = error
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    

    @IBOutlet weak var pinCodeLabel: UILabel!
    
    var success: ((String) -> Void)?
    enum PinError: Error {
        case cancel, pinError
    }
    var error: ((PinError)->Void)?
    
    var correctPin: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinCodeLabel.text = ""
    }
    
    @IBAction func action1(_ sender: Any) { addNumber(1) }
    @IBAction func action2(_ sender: Any) { addNumber(2) }
    @IBAction func action3(_ sender: Any) { addNumber(3) }
    @IBAction func action4(_ sender: Any) { addNumber(4) }
    @IBAction func action5(_ sender: Any) { addNumber(5) }
    @IBAction func action6(_ sender: Any) { addNumber(6) }
    @IBAction func action7(_ sender: Any) { addNumber(7) }
    @IBAction func action8(_ sender: Any) { addNumber(8) }
    @IBAction func action9(_ sender: Any) { addNumber(9) }
    @IBAction func action0(_ sender: Any) { addNumber(0) }
    
    @IBAction func actionDelNumber(_ sender: Any) {
        var text = pinCodeLabel.text ?? ""
        guard text.count > 0 else { return }
        text.removeLast()
        pinCodeLabel.text = text
    }
    
    private func addNumber(_ num: Int) {
        let text = pinCodeLabel.text ?? ""
        guard text.count < 4 else { return }
        pinCodeLabel.text = "\(text)\(num)"
    }
    
    @IBAction func actionOK(_ sender: Any) {
        let pin = self.pinCodeLabel.text ?? ""
        
        if let correct = self.correctPin {
            if pin == correct {
                self.dismiss(animated: true) {
                    self.success?(pin)
                }
            } else {
                let alert = UIAlertController(title: "Sorry !".localise(), message: "The entered pin is incorrect. Do you want to try again ?".localise(), preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "YES".localise(), style: .default, handler: { _ in
                    self.pinCodeLabel.text = ""
                })
                yesAction.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
                
                alert.addAction(yesAction)
                
                let noAction = UIAlertAction(title: "NO".localise(), style: .default, handler: { _ in
                    self.dismiss(animated: true) {
                        self.error?(PinError.cancel)
                    }
                })
                noAction.setValue(UIColor(hex: "#222222")!, forKey: "titleTextColor")
                
                alert.addAction(noAction)
                self.present(alert, animated: true)
            }
        } else {
            self.dismiss(animated: true) {
                self.success?(pin)
            }
        }
    }
    @IBAction func actionClose(_ sender: Any) {
        self.error?(PinError.cancel)
        self.dismiss(animated: true)
    }
}
