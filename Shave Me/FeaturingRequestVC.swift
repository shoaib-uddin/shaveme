//
//  FeaturingRequestVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/22/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import KMPlaceholderTextView
import ObjectMapper

class FeaturingRequestVC: BaseSideMenuViewController {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var provideDetaislTextView: KMPlaceholderTextView!
    
    fileprivate var startSelectedDate = Date()
    fileprivate var endSelectedDate = Date().nextDay
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "featuringrequest".localized()
        
        self.hideKeyboardOnTap()
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
            case ServiceUtils.POST_FEATURING_REQUEST:
                if let model = Mapper<FeaturingRequestModel>().map(JSONObject: response.value), model.id! > 0 {
                    AppUtils.showMessage(title: "success".localized(), message: "featuringrequestsuccesstxt".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                    
                    startSelectedDate = Date()
                    endSelectedDate = Date().nextDay
                    self.endDateLabel.text = "enddate".localized()
                    self.startDateLabel.text = "startdate".localized()
                    self.provideDetaislTextView.text = ""
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "ServerError".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
                break
            default:
                break
            }
            
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickStartDate(_ sender: Any) {
        let title = "startdate".localized()
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.date, selectedDate: startSelectedDate, doneBlock: {
            picker, value, index in
            self.startSelectedDate = value as! Date
            
            self.startDateLabel.text = self.startSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        }, cancel: { ActionStringCancelBlock in return }, origin: self.startDateLabel)
        
        datePicker?.show()
    }
    
    @IBAction func onClickEndDate(_ sender: Any) {
        guard "startdate".localized() != self.startDateLabel.text else {
            AppUtils.showMessage(title: "alert".localized(), message: "ReportChcekstartDate".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        let title = "enddate".localized()
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.date, selectedDate: endSelectedDate, doneBlock: {
            picker, value, index in
            guard let value = value as? Date, self.startSelectedDate.isBefore(to: value) else {
                AppUtils.showMessage(title: "alert".localized(), message: "dateValidation".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
            }
            
            self.endSelectedDate = value
            
            self.endDateLabel.text = self.endSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        }, cancel: { ActionStringCancelBlock in return }, origin: self.startDateLabel)
        
        datePicker?.show()
    }
    
    @IBAction func onClickSendRequestButton(_ sender: UIButton) {
        guard "startdate".localized() != self.startDateLabel.text, "enddate".localized() != self.endDateLabel.text else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        let startDate = startSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        let endDate = endSelectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        let barberID = AppController.sharedInstance.loggedInBarber?.barberShopId ?? 0
        
        let model = FeaturingRequestModel(barberID: barberID, startDate: startDate, endDate: endDate, providedDetails: self.provideDetaislTextView.text)
        
        _ = NetworkManager.postFeaturingRequest(model: model, completionHandler: onResponse)
    }


    // MARK: - Utility Methods
}
