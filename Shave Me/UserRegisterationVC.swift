//
//  UserRegisterationVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/4/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import M13Checkbox
import ActionSheetPicker_3_0
import ObjectMapper

class UserRegisterationVC: BaseSideMenuViewController, ViewControllerInterationProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var emiratesLabel: UILabel!
    @IBOutlet weak var termsAndConditionsContainer: UIView!
    @IBOutlet weak var termsAndConditionsCheckbox: M13Checkbox!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    private var selectedGenderValue: String?
    private var selectedNationalityValue: String?
    private var selectedEmirateValue: String?
    private var profilePictureBase64String: String?
    
    var genderPicker: ActionSheetStringPicker?
    var nationalityPicker: ActionSheetStringPicker?
    var emiratePicker: ActionSheetStringPicker?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "registration".localized()
        
        // Mapping all the click callbacks
        AppUtils.setGestureRecognizers(senders: profileImageView, loginButton, genderLabel, nationalityLabel, emiratesLabel, termsAndConditionsContainer, registerButton, termsOfServiceLabel, target: self, action: #selector(UserRegisterationVC.onClickCallback(_:)))
        
        self.hideKeyboardOnTap()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.mobileTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
        
        // Making image view circular
        profileImageView.makeCircular()
    }
    
    // MARK: - Click and Callback Methods

    func onResponse(methodName: String, response: RequestResult) {
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
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "Ok", viewController: self, handler: nil)
        }
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
            self.passwordTextField.becomeFirstResponder()
            return true
        } else if self.passwordTextField == textField {
            self.confirmPasswordTextField.becomeFirstResponder()
            return true
        } else {
            self.dismissKeyboard()
        }
        
        return false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if let image = image {
            let scaledImage = image.resizeImage(newWidth: 1200)
            self.profilePictureBase64String = scaledImage?.base64EncodedString()
            
            self.profileImageView.image = scaledImage
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "Incompatible format", buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .userLogin {
            _ = self.navigationController?.popViewController(animated: false)
        }
    }

    func onClickCallback(_ sender: UITapGestureRecognizer) {
        switch sender.view! {
        case self.profileImageView:
            onClickPickImage()
        case self.loginButton:
            onClickLogin()
        case self.genderLabel:
            onClickGenderDropdown()
        case self.emiratesLabel:
            onClickEmirateDropdown()
        case self.nationalityLabel:
            onClickNationalityDropdown()
        case self.termsAndConditionsContainer:
            onClickTermsAndConditionsCheckBox()
        case self.registerButton:
            onClickRegister()
        case self.termsOfServiceLabel:
            onClickShowTermsOfService()
        default:
            break
        }
    }
    
    func onClickTermsAndConditionsCheckBox() {
        let state: M13Checkbox.CheckState = self.termsAndConditionsCheckbox.checkState == M13Checkbox.CheckState.checked ? .unchecked : .checked
        self.termsAndConditionsCheckbox.setCheckState(state, animated: true)
    }
    
    func onClickShowTermsOfService() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: TermsAndConditionsVC.storyBoardID)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onClickPickImage() {
        let alert = UIAlertController(title: "addphoto".localized(), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "choosefromgallery".localized(), style: .default, handler: {(action) in
            AppUtils.getImageFromPhotoLibrary(viewController: self)
        }))
        alert.addAction(UIAlertAction(title: "takephoto".localized(), style: .default, handler:  {(action) in
            AppUtils.takePhoto(viewController: self)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onClickRegister() {
        guard self.termsAndConditionsCheckbox.checkState == .checked else {
            AppUtils.showMessage(title: "alert".localized(), message: "acceptTermsAndCondition".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        guard self.confirmPasswordTextField.text == self.passwordTextField.text else {
            AppUtils.showMessage(title: "alert".localized(), message: "passwordmismatch".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        guard let gender = selectedGenderValue, let nationality = selectedNationalityValue, let emirate = selectedEmirateValue, let firstName = firstNameTextField.text, firstName.characters.count > 0, let lastName = lastNameTextField.text, lastName.characters.count > 0, let password = passwordTextField.text, password.characters.count > 0, let email = emailTextField.text, email.characters.count > 0 else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        let language = AppController.sharedInstance.language
        let userModel = UserModel(firstName: firstName, lastName: lastName, password: password, gender: gender, email: email, language: language, nationality: nationality, emirates: emirate, profilePic: profilePictureBase64String)
        userModel.mobileNo = mobileTextField.text
        _ = NetworkManager.postRegisteration(model: userModel, completionHandler: onResponse)
    }
    
    func onClickLogin() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: UserLoginVC.storyBoardID) as! UserLoginVC
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onClickGenderDropdown() {
        if genderPicker == nil {
            let rows = "GenderArray".localizedArray()
            genderPicker = ActionSheetStringPicker(title: "gender".localized(), rows: rows, initialSelection: 0, doneBlock: onGenderItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.genderLabel)
        }
        genderPicker?.show()
    }
    
    func onClickEmirateDropdown() {
        if emiratePicker == nil {
            let rows = "EmiratesArray".localizedArray()
            emiratePicker = ActionSheetStringPicker(title: "emirates".localized(), rows: rows, initialSelection: 0, doneBlock: onEmirateItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.emiratesLabel)
        }
        emiratePicker?.show()
    }

    func onClickNationalityDropdown() {
        if nationalityPicker == nil {
            let rows = "NationalitiesArray".localizedArray()
            nationalityPicker = ActionSheetStringPicker(title: "nationality".localized(), rows: rows, initialSelection: 0, doneBlock: onNationalityItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.nationalityLabel)
        }
        nationalityPicker?.show()
    }
    
    func onGenderItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        selectedGenderValue = selectedValue as? String
        self.genderLabel.text = selectedValue as? String
    }
    
    func onNationalityItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        selectedNationalityValue = selectedValue as? String
        self.nationalityLabel.text = selectedValue as? String
    }
    
    func onEmirateItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        selectedEmirateValue = selectedValue as? String
        self.emiratesLabel.text = selectedValue as? String
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
}
