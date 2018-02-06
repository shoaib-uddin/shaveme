//
//  SettingsVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/5/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import M13Checkbox
import ObjectMapper

class SettingsVC: BaseSideMenuViewController {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendAlertsCheckbox: M13Checkbox!
    @IBOutlet weak var displayPictureCheckbox: M13Checkbox!
    @IBOutlet weak var calendarCheckbox: M13Checkbox!
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "settings".localized()
        
        if let user = AppController.sharedInstance.loggedInUser {
            sendAlertsCheckbox.setCheckState((user.sendAlerts ?? false).getCheckState(), animated: false)
            displayPictureCheckbox.setCheckState((user.displayPic ?? false).getCheckState(), animated: false)
            calendarCheckbox.setCheckState((user.calender ?? false).getCheckState(), animated: false)
        }
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
            case ServiceUtils.UPDATE_REGISTRATION_API:
                if let userModel = Mapper<UserModel>().map(JSONObject: response.value), userModel.id > 0 {
                    AppController.sharedInstance.loggedInUser = userModel

                    AppUtils.showMessage(title: "success".localized(), message: "updatedSuccessfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "authenticationFailed".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "Ok", viewController: self, handler: nil)
        }
    }

    @IBAction func onClickUpdate(_ sender: Any) {
        self.showProgressHUD()
        
        let id = AppController.sharedInstance.loggedInUser?.id ?? 0
        
        let userModel = UserModel()
        userModel.id = id
        userModel.sendAlerts = self.sendAlertsCheckbox.checkState == .checked ? true : false
        userModel.calender = self.calendarCheckbox.checkState == .checked ? true : false
        userModel.displayPic = self.displayPictureCheckbox.checkState == .checked ? true : false
        userModel.language = AppController.sharedInstance.language

        _ = NetworkManager.updateRegisteration(userID: id, model: userModel, completionHandler: onResponse)
    }
    
    @IBAction func onClickChangePassword(_ sender: Any) {
        AppUtils.addViewControllerModally(originVC: self, destinationVC: ChangePasswordVC(), widthMultiplier: 0.9, HeightMultiplier: 0.5)
    }
    
    @IBAction func onClickSendAlerts(_ sender: UITapGestureRecognizer) {
        var state = true.getCheckState()
        if self.sendAlertsCheckbox.checkState == .checked {
            state = false.getCheckState()
        }
        
        sendAlertsCheckbox.setCheckState(state, animated: false)
    }
    
    @IBAction func onClickDisplayPicture(_ sender: UITapGestureRecognizer) {
        var state = true.getCheckState()
        if self.displayPictureCheckbox.checkState == .checked {
            state = false.getCheckState()
        }
        
        displayPictureCheckbox.setCheckState(state, animated: false)
    }
    
    @IBAction func onClickAddToCalendar(_ sender: UITapGestureRecognizer) {
        var state = true.getCheckState()
        if self.calendarCheckbox.checkState == .checked {
            state = false.getCheckState()
        }
        
        calendarCheckbox.setCheckState(state, animated: false)
    }
    
    // MARK: - Utility Methods
    
}
