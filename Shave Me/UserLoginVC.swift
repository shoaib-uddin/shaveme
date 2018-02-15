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
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit

class UserLoginVC: BaseSideMenuViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //
        print("facebook: Hardcoded password - shaveme@17");
        self.showProgressHUD();
        
        if(FBSDKAccessToken.current() != nil){
            
            
            GBHFacebookHelper.shared.fbDataRequest(completion: { (success, userModel) in
                //
                if(success){
                    FBSDKLoginManager().logOut();
                    self.tempUserModel = userModel;
                    _ = NetworkManager.postRegisteration(model: userModel!, completionHandler: self.onRegResponse)
                    
                    
                }else{
                    
                    print("login failed");
                    FBSDKLoginManager().logOut();
                    self.hideProgressHUD();
                }
            });
        }
        
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //
        
    }
    
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil

    @IBOutlet weak var rememberMeCheckBox: M13Checkbox!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var socialView: UIView!
    var tempUserModel: UserModel!;
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = MyUserDefaults.getDefaults().string(forKey: MyUserDefaults.PREFS_REMEMBERME) {
            rememberMeCheckBox.setCheckState(.checked, animated: true)
            emailTextField.text = email
        }
        
        self.hideKeyboardOnTap()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self;
        
        //if FBSDKAccessToken.current() == nil {
            let loginButton = FBSDKLoginButton();
            loginButton.readPermissions = ["public_profile", "email"];
            //loginButton.center = CGPoint(x: 0, y: socialView.frame.width / 2);
            loginButton.frame = CGRect(x: 0, y: 0, width: socialView.frame.width, height: socialView.frame.height / 2);
            loginButton.delegate = self;
            self.socialView.addSubview(loginButton)
        //}
        
        
        // twitter Login Button
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(session?.userName ?? "ME" )");
                
                if let us = session?.userName{
                    self.createOrLoginTwitterAccount(username: us);
                }
                
                
            } else {
                print("error: \(error?.localizedDescription ?? "ME" )");
            }
        })
        //logInButton.center = self.view.center
        logInButton.frame = CGRect(x: 0, y: ( socialView.frame.height / 2 ) + 20, width: socialView.frame.width, height: socialView.frame.height / 2);
//        logInButton.delegate = self;
        
        //logInButton.setTitle("OURS", for: .normal);
        
        self.socialView.addSubview(logInButton)
        
        
        
        
    }
    
    fileprivate func createOrLoginTwitterAccount(username: String){
        
        let firstName = username;
        let lastName = "";
        let password = "shaveme@17";
        let gender = "Male";
        let email = "\(username)@twitter.com";
        let profilePic = "";
        
        let u = UserModel(firstName: firstName, lastName: lastName, password: password, gender: gender, email: email, language: "EN", nationality: "", emirates: "", profilePic: profilePic)
        self.tempUserModel = u;
        _ = NetworkManager.postRegisteration(model: u, completionHandler: self.onRegResponse);
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController, AppController.sharedInstance.loggedInUser != nil {
            navigationController.popViewController(animated: animated)
        }
    }
    
    // MARK: - Click and Callback Methods
    func onRegResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.POST_REGISTRATION_API:
                if let userModel = Mapper<UserModel>().map(JSONObject: response.value), userModel.id > 0 {
                    AppController.sharedInstance.loggedInUser = userModel
                    
                    if AppUtils.updateDeviceDetailsForPushNotifications(completionHandler: onResponse) == nil {
                        showUserLoggedInSuccessMessage()
                    }
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "authenticationFailed".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            case ServiceUtils.POST_GCMREGISTRATIONKEY_API:
                showUserLoggedInSuccessMessage()
            default:
                break
            }
        } else {
            
            //AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "Ok", viewController: self, handler: nil)
            _ = NetworkManager.getUserLoginDetails(email: self.tempUserModel.email, password: self.tempUserModel.password, completionHandler: onResponse)
            
            
            
        }
    }
    
    // MARK: - Utility Methods
    
    func showUserLoggedInSuccessMessage() {
        let userModel = AppController.sharedInstance.loggedInUser!
        
        let name = userModel.firstName + " " + userModel.lastName
        let message = "registrationsuccess".localized().replacingOccurrences(of: "NAME", with: name)
        AppUtils.showMessage(title: "success".localized(), message: message, buttonTitle: "okay".localized(), viewController: self, handler: { _ in
            _ = self.navigationController?.popViewController(animated: true)
            
            if let delegate = self.delegate {
                delegate.onViewControllerInteractionListener(interactionType: .userRegistered, data: userModel, childVC: self)
            }
        })
        
    }
    
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
