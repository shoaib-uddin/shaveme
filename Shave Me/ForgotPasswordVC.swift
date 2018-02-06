//
//  ForgotPasswordVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/11/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit

class ForgotPasswordVC: BaseSideMenuViewController, UITextFieldDelegate {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var resetPasswordContainer: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "forgetpasswordtitle".localized()
        
        self.hideKeyboardOnTap()
        
        self.emailTextField.delegate = self
        self.passwordField.delegate = self
        self.newPasswordField.delegate = self
        self.confirmPasswordField.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        switch methodName {
        case ServiceUtils.GET_FORGET_PASSWORD_API:
            
            if let message = response.status?.message, message == "resultfound".localized() {
                emailTextField.isHidden = true
                forgotPasswordButton.isHidden = true
                resetPasswordContainer.isHidden = false
            } else {
                AppUtils.showMessage(title: "alert".localized(), message: "emailIdNotRegistered".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            }
            default:
            break
        }
    }
    
    @IBAction func onClickGetForgotPassword(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        _ = NetworkManager.getForgotPassword(email: email, completionHandler: onResponse)
    }
    
    @IBAction func onClickResetPassowrd(_ sender: Any) {
        guard let code = passwordField.text, !code.isEmpty, let newPassword = newPasswordField.text, !newPassword.isEmpty, let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        guard newPassword == confirmPassword else {
            AppUtils.showMessage(title: "alert".localized(), message: "passwordmismatch".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()

        _ = NetworkManager.getUpdatePassword(code: code, password: newPassword, completionHandler: { (methodName, response) in
            self.hideProgressHUD()
            
            if let message = response.status?.message, message == "resultfound".localized() {
                AppUtils.showMessage(title: "success".localized(), message: "passwordresetsuccess".localized(), buttonTitle: "okay".localized(), viewController: self, handler: { _ in
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                AppUtils.showMessage(title: "alert".localized(), message: "invalidecodepasswordreset".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.emailTextField == textField {
            textField.resignFirstResponder()
            return true
        } else if self.passwordField == textField {
            self.newPasswordField.becomeFirstResponder()
            return true
        } else if self.newPasswordField == textField {
            self.confirmPasswordField.becomeFirstResponder()
            return true
        } else {
            self.dismissKeyboard()
        }
        
        return false
    }

}
