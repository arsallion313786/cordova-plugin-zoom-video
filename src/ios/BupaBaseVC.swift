//
//  BupaBaseVC.swift
//  NativeBupaZoomApp
//
//  Created by Muhammad Arslan Khalid on 26/09/2024.
//

import Foundation
import UIKit

class BupaBaseVC: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - ViewController Methods
    public  override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillChangeFrame(to frame: CGRect) {
    }

}

// MARK: - Keyboard Handler Methods
extension BupaBaseVC {
    
    @objc private func keyboardWillShowNotification(_ sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardWillChangeFrame(to: endFrame)
            }
        }
    }
    @objc private func keyboardWillHideNotification(_ sender: NSNotification) {
        keyboardWillChangeFrame(to: CGRect.zero)
    }
}


//MARK: Btn Actions
extension BupaBaseVC{
    @IBAction func btnPopControllerPressed(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true);
    }
}

extension BupaBaseVC: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
