//
//  UserLoginVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/15/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import SWRevealViewController
import ImageSlideshow
import Alamofire
import BadgeSwift
import SearchTextField
import MZFormSheetPresentationController
import M13Checkbox

class UserLoginVC: BaseSideMenuViewController, UITextFieldDelegate {
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil

    @IBOutlet weak var rememberMeCheckBox: M13Checkbox!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = MyUserDefaults.getDefaults().string(forKey: MyUserDefaults.PREFS_REMEMBERME) {
            rememberMeCheckBox.setCheckState(.checked, animated: true)
            emailTextField.text = email
        }
        
        self.hideKeyboardOnTap()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController, AppController.sharedInstance.loggedInUser != nil {
            navigationController.popViewController(animated: animated)
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_USER_AUTHENTICATION_API:
                if let userArray = Mapper<UserModel>().mapArray(JSONObject: response.value), userArray.count > 0, userArray.first!.id > 0 {
                    AppController.sharedInstance.loggedInUser = userArray.first!
                    
                    if AppUtils.updateDeviceDetailsForPushNotifications(completionHandler: onResponse) == nil {
                        _ = NetworkManager.getFavourites(userID: AppController.sharedInstance.loggedInUser!.id, completionHandler: onResponse)
                    }
                } else {
                    self.hideProgressHUD()
                    
                    AppUtils.showMessage(title: "alert".localized(), message: "authenticationFailed".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            case ServiceUtils.POST_GCMREGISTRATIONKEY_API:
                _ = NetworkManager.getFavourites(userID: AppController.sharedInstance.loggedInUser!.id, completionHandler: onResponse)
            case ServiceUtils.GET_FAVORITES_API:
                _ = FavoritesModelController.parseResponse(response: response.value)
                
                self.hideProgressHUD()
                
                _ = self.navigationController?.popViewController(animated: true)
                
                if let delegate = self.delegate {
                    delegate.onViewControllerInteractionListener(interactionType: .userLogin, data: AppController.sharedInstance.loggedInUser, childVC: self)
                }
            default:
                break
            }
        } else {
            self.hideProgressHUD()
            
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    @IBAction func onClickForgotPassword(_ sender: Any) {
        self.navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty {
            
            if rememberMeCheckBox.checkState == .checked {
                MyUserDefaults.getDefaults().set(email, forKey: MyUserDefaults.PREFS_REMEMBERME)
            } else {
                MyUserDefaults.getDefaults().set(nil, forKey: MyUserDefaults.PREFS_REMEMBERME)
            }
            
            self.showProgressHUD()
            _ = NetworkManager.getUserLoginDetails(email: email, password: password, completionHandler: onResponse)
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickRememberMe(_ sender: Any) {
        rememberMeCheckBox.toggleCheckState()
    }
    
    @IBAction func onClickNewUser(_ sender: Any) {
        self.navigationController?.pushViewController(UserRegisterationVC(), animated: true)
    }
    
    // MARK: - Textfield delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            self.passwordTextField.resignFirstResponder()
        }
        
        // true if the text field should implement its default behavior for the return button; otherwise, false.
        return false
    }
}
