//
//  UserProfileVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/5/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import M13Checkbox
import ActionSheetPicker_3_0
import ObjectMapper

class UserProfileVC: BaseSideMenuViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var emiratesLabel: UILabel!
    @IBOutlet weak var termsAndConditionsContainer: UIView!
    @IBOutlet weak var termsAndConditionsCheckbox: M13Checkbox!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    var profilePictureBase64String: String?
    
    var genderPicker: ActionSheetStringPicker?
    var nationalityPicker: ActionSheetStringPicker?
    var emiratePicker: ActionSheetStringPicker?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "myprofile".localized()
        // Mapping all the click callbacks
        AppUtils.setGestureRecognizers(senders: profileImageView, updateButton, genderLabel, nationalityLabel, emiratesLabel, termsAndConditionsContainer, termsOfServiceLabel, target: self, action: #selector(UserRegisterationVC.onClickCallback(_:)))
        // Loading view
        if let user = AppController.sharedInstance.loggedInUser {
            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
            emailTextField.text = user.email
            mobileTextField.text = user.mobileNo
            
            
            nationalityLabel.text = user.nationality
            emiratesLabel.text = user.emirates
            
            if let profileURL = user.profilePic, let url = URL(string: profileURL) {
                profileImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "nouserpic"))
            }
            
            self.hideProgressHUD()
        }
        
        self.hideKeyboardOnTap()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
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
            case ServiceUtils.UPDATE_REGISTRATION_API:
                if let userModel = Mapper<UserModel>().map(JSONObject: response.value), userModel.id > 0 {
                    AppController.sharedInstance.loggedInUser = userModel
                    
                    AppUtils.showMessage(title: "success".localized(), message: "updatedSuccessfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "ServerError".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
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
            self.mobileTextField.becomeFirstResponder()
            return true
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
            let scaledImage = image.resizeImage(newWidth: 600)
            self.profilePictureBase64String = scaledImage?.base64EncodedString()
            
            self.profileImageView.image = scaledImage
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "Incompatible format", buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func onClickCallback(_ sender: UITapGestureRecognizer) {
        switch sender.view! {
        case self.profileImageView:
            onClickPickImage()
        case self.genderLabel:
            onClickGenderDropdown()
        case self.emiratesLabel:
            onClickEmirateDropdown()
        case self.nationalityLabel:
            onClickNationalityDropdown()
        case self.termsAndConditionsContainer:
            onClickTermsAndConditionsCheckBox()
        case self.updateButton:
            onClickUpdate()
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
    
    func onClickUpdate() {
        guard self.termsAndConditionsCheckbox.checkState == .checked else {
            AppUtils.showMessage(title: "alert".localized(), message: "acceptTermsAndCondition".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        guard let gender = self.genderLabel.text, let nationality = self.nationalityLabel.text, let emirate = self.emiratesLabel.text, let firstName = firstNameTextField.text, firstName.characters.count > 0, let lastName = lastNameTextField.text, lastName.characters.count > 0 else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()

        let userModel = UserModel()
        
        if let loggedInUser = AppController.sharedInstance.loggedInUser {
            userModel.id = loggedInUser.id
            userModel.firstName = firstName
            userModel.lastName = lastName
            userModel.mobileNo = mobileTextField.text
            
            userModel.nationality = nationality
            userModel.emirates = emirate
            userModel.profilePic = profilePictureBase64String
            userModel.language = AppController.sharedInstance.language
            userModel.sendAlerts = loggedInUser.sendAlerts
            userModel.displayPic = loggedInUser.displayPic
            userModel.calender = loggedInUser.calender
            
            _ = NetworkManager.updateRegisteration(userID: loggedInUser.id, model: userModel, completionHandler: onResponse)
        }
    }
    
    func onClickGenderDropdown() {
        self.dismissKeyboard()
        
        if genderPicker == nil {
            let rows = "GenderArray".localizedArray()
            var initialSelection = 0
            if let selectedText = genderLabel.text, let selectedIndex = rows.index(of: selectedText) {
                initialSelection = selectedIndex
            }
            genderPicker = ActionSheetStringPicker(title: "gender".localized(), rows: rows, initialSelection: initialSelection, doneBlock: onGenderItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.genderLabel)
        }
        genderPicker?.show()
    }
    
    func onClickEmirateDropdown() {
        self.dismissKeyboard()
        
        if emiratePicker == nil {
            let rows = "EmiratesArray".localizedArray()
            var initialSelection = 0
            if let selectedText = emiratesLabel.text, let selectedIndex = rows.index(of: selectedText) {
                initialSelection = selectedIndex
            }
            emiratePicker = ActionSheetStringPicker(title: "emirates".localized(), rows: rows, initialSelection: initialSelection, doneBlock: onEmirateItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.emiratesLabel)
        }
        emiratePicker?.show()
    }
    
    func onClickNationalityDropdown() {
        self.dismissKeyboard()
        
        if nationalityPicker == nil {
            let rows = "NationalitiesArray".localizedArray()
            var initialSelection = 0
            if let selectedText = nationalityLabel.text, let selectedIndex = rows.index(of: selectedText) {
                initialSelection = selectedIndex
            }
            nationalityPicker = ActionSheetStringPicker(title: "nationality".localized(), rows: rows, initialSelection: initialSelection, doneBlock: onNationalityItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.nationalityLabel)
        }
        nationalityPicker?.show()
    }
    
    func onGenderItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        self.genderLabel.text = selectedValue as? String
    }
    
    func onNationalityItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        self.nationalityLabel.text = selectedValue as? String
    }
    
    func onEmirateItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        self.emiratesLabel.text = selectedValue as? String
    }

    // MARK: - Utility Methods
}
