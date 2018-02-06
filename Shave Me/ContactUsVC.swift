//
//  ContactUsVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/8/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class ContactUsVC: BaseSideMenuViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageTextView: KMPlaceholderTextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private weak var activeField: UIView?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "contatcus".localized()
        // Loading view
        prepopulateTextFields()
        
        messageTextView.placeholder = messageTextView.placeholder.localized()
        
        self.hideKeyboardOnTap()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.mobileTextField.delegate = self
        self.emailTextField.delegate = self
        self.subjectTextField.delegate = self
        self.messageTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unregisterFromKeyboardNotifications()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }

    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.POST_FEEBACK_API:
                AppUtils.showMessage(title: "success".localized(), message: "contatcUsSuccesstext".localized(), buttonTitle: "okay".localized(), viewController: self, handler: { _ in
                    self.resetTextFields(view: self.view)
                    self.messageTextView.text = ""
                    self.prepopulateTextFields()
                })
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "Ok", viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickSubmit(_ sender: Any) {
        guard let firstName = firstNameTextField.text, firstName.characters.count > 0,
            let lastName = lastNameTextField.text, lastName.characters.count > 0,
            let mobile = mobileTextField.text, mobile.characters.count > 0,
            let email = emailTextField.text, email.characters.count > 0,
            let subject = subjectTextField.text, subject.characters.count > 0,
            let message = messageTextView.text, message.characters.count > 0 else {
                AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
        }
        
        self.showProgressHUD()
        
        let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
        let name = firstName + " " + lastName
        let model = FeedbackModel(userId: userID, name: name, email: email, mobile: mobile, subject: subject, message: message)
        _ = NetworkManager.postFeedback(model: model, completionHandler: onResponse)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.firstNameTextField == textField {
            self.lastNameTextField.becomeFirstResponder()
            return true
        } else if self.lastNameTextField == textField {
            self.emailTextField.becomeFirstResponder()
            return true
        } else if self.emailTextField == textField {
            self.mobileTextField.becomeFirstResponder()
            return true
        } else if self.mobileTextField == textField {
            self.subjectTextField.becomeFirstResponder()
            return true
        } else if self.subjectTextField == textField {
            self.messageTextView.becomeFirstResponder()
            return true
        } else {
            self.dismissKeyboard()
        }
        
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    // MARK: - Utility Methods
    
    func resetTextFields(view: UIView?) {
        if let view = view {
            for v in view.subviews {
                if let textField = v as? UITextField {
                    textField.text = ""
                } else {
                    resetTextFields(view: v)
                }
            }
        }
    }
    
    func prepopulateTextFields() {
        if let user = AppController.sharedInstance.loggedInUser {
            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
            emailTextField.text = user.email
            mobileTextField.text = user.mobileNo
        }
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func unregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}
