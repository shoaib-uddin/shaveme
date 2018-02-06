//
//  BarberLoginVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
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

class BarberLoginVC: BaseSideMenuViewController, UITextFieldDelegate {
    
    @IBOutlet weak var rememberMeCheckBox: M13Checkbox!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = MyUserDefaults.getDefaults().string(forKey: MyUserDefaults.PREFS_BARBERREMEMBERME) {
            rememberMeCheckBox.setCheckState(.checked, animated: true)
            emailTextField.text = email
        }
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBER_AUTHETICATION_API:
                if let array = Mapper<BarberLoginModel>().mapArray(JSONObject: response.value), array.count > 0, array.first!.id! > 0 {
                    AppController.sharedInstance.loggedInUser = nil
                    
                    AppController.sharedInstance.loggedInBarber = array.first!
                    
                    if AppUtils.updateDeviceDetailsForPushNotifications(completionHandler: onResponse) == nil {
                        self.openHomeViewController()
                    }
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "authenticationFailed".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            case ServiceUtils.POST_GCMSHOPREGISTRATIONKEY_API:
                openHomeViewController()
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay", viewController: self, handler: nil)
        }
    }

    @IBAction func onClickLogin(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty {
            
            if rememberMeCheckBox.checkState == .checked {
                MyUserDefaults.getDefaults().set(email, forKey: MyUserDefaults.PREFS_BARBERREMEMBERME)
            } else {
                MyUserDefaults.getDefaults().set(nil, forKey: MyUserDefaults.PREFS_BARBERREMEMBERME)
            }
            
            self.showProgressHUD()
            _ = NetworkManager.getBarberLoginDetails(email: email, password: password, completionHandler: onResponse)
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickRememberMe(_ sender: Any) {
        rememberMeCheckBox.toggleCheckState()
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
    
    // MARK: - Utility Methods
    
    func openHomeViewController() {
        let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: BarberHomeVC.storyBoardID)
        self.navigationController?.viewControllers = [frontViewController!]
    }
}
