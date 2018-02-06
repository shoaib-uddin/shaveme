//
//  ChangePasswordVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/5/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import Alamofire

class ChangePasswordVC: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    private var dataRequest: DataRequest?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardOnTap()
        
        self.passwordField.delegate = self
        self.newPasswordField.delegate = self
        self.confirmPasswordField.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let dataRequest = dataRequest {
            dataRequest.cancel()
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            AppUtils.showMessage(title: "alert".localized(), message: "passwordchanged".localized(), buttonTitle: "okay".localized(), viewController: self, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            var message = (response.status?.message)!
            if message == "ResultNotFound".localized() {
                message = "checkemailregister".localized()
            } else if message == "OldPasswordWrong".localized() {
                message = "checkoldpassword".localized()
            }
            
            AppUtils.showMessage(title: "alert".localized(), message: message, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    @IBAction func onClickUpdate(_ sender: Any) {
        if let password = passwordField.text, password.characters.count > 0,
            let newPassword = newPasswordField.text, newPassword.characters.count > 0,
            let confirmPassword = confirmPasswordField.text, confirmPassword.characters.count > 0 {
            if newPassword == confirmPassword {
                self.showProgressHUD()
                
                dataRequest = NetworkManager.getPassword(userID: AppController.sharedInstance.loggedInUser!.id, oldPassword: password, newPassword: newPassword, completionHandler: onResponse)
            } else {
                AppUtils.showMessage(title: "alert".localized(), message: "passwordmismatch".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.passwordField == textField {
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
    
    // MARK: - Utility Methods
}
