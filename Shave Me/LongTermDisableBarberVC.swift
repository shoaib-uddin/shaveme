//
//  LongTermDisableBarberVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/18/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import Alamofire
import M13Checkbox
import ActionSheetPicker_3_0
import ObjectMapper

class LongTermDisableBarberVC: BaseViewController {

    fileprivate static let showcaseDateFormat = "dd/MM/yy"
    fileprivate static let dateFormat = "MM/dd/yyyy"
    fileprivate static let timeFormat = "HH:mm"
    
    @IBOutlet weak var allDayCheckbox: M13Checkbox!
    @IBOutlet weak var stylistNameLabel: UILabel!
    @IBOutlet weak var dateFromButton: UIButton!
    @IBOutlet weak var timeFromButton: UIButton!
    @IBOutlet weak var dateToButton: UIButton!
    @IBOutlet weak var timeToButton: UIButton!
    
    var model: DisableBarberModel!
    var stylistName: String!
    
    private var dataRequest: DataRequest?
    private var fromDate = Date().nextDay
    private var toDate = Date().nextDay
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stylistNameLabel.text = "stylistName".localized() + " : " + stylistName
        
        updateTimingButtons()
        onClickAllDayView(nil)
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
            switch methodName {
            case "POST_DISABLE_BARBER_API":
                AppUtils.showMessage(title: "success".localized(), message: "stylist_blocked_successfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: { _ in self.dismiss(animated: true, completion: nil) })
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    
    @IBAction func onClickAllDayView(_ sender: Any?) {
        var isChecked = allDayCheckbox.checkState == .checked
        isChecked = !isChecked
        allDayCheckbox.checkState = isChecked.getCheckState()
        
        if isChecked {
            fromDate = fromDate.startOfDay
            toDate = toDate.endOfDay!
        }
        
        timeFromButton.isUserInteractionEnabled = !isChecked
        timeToButton.isUserInteractionEnabled = !isChecked
        
        let alpha: CGFloat = isChecked ? 0.65 : 1
        timeFromButton.alpha = alpha
        timeToButton.alpha = alpha
        
        updateTimingButtons()
    }
    
    @IBAction func onClickDateFromButton(_ sender: UIButton) {
        let title = "date".localized()
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.date, selectedDate: fromDate, doneBlock: {
            picker, value, index in
            self.fromDate = value as! Date
            
            self.updateTimingButtons()
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        datePicker?.minimumDate = Date().nextDay
        
        datePicker?.show()
    }
    
    @IBAction func onClickTimeFromButton(_ sender: UIButton) {
        let title = "time".localized()
        let timePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.time, selectedDate: fromDate, doneBlock: {
            picker, value, index in
            self.fromDate = value as! Date
            
            self.updateTimingButtons()
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        timePicker?.minimumDate = Date().nextDay
        
        timePicker?.show()
    }
    
    @IBAction func onClickDateToButton(_ sender: UIButton) {
        let title = "date".localized()
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.date, selectedDate: toDate, doneBlock: {
            picker, value, index in
            self.toDate = value as! Date
            
            if self.allDayCheckbox.checkState == .checked {
                self.toDate = self.toDate.endOfDay!
            }
            
            self.updateTimingButtons()
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        datePicker?.minimumDate = fromDate
        
        datePicker?.show()
    }
    
    @IBAction func onClickTimeToButton(_ sender: UIButton) {
        let title = "time".localized()
        let timePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.time, selectedDate: toDate, doneBlock: {
            picker, value, index in
            self.toDate = value as! Date
            
            self.updateTimingButtons()
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        timePicker?.minimumDate = fromDate
        
        timePicker?.show()
    }
    
    @IBAction func onClickBlockButton(_ sender: UIButton) {
        guard fromDate.isBefore(to: toDate) else {
            AppUtils.showMessage(title: "alert".localized(), message: "from_date_before_to".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        model.endDate = toDate.string(fromFormat: LongTermDisableBarberVC.dateFormat)
        model.endTime = toDate.string(fromFormat: LongTermDisableBarberVC.timeFormat)
        model.startDate = fromDate.string(fromFormat: LongTermDisableBarberVC.dateFormat)
        model.startTime = fromDate.string(fromFormat: LongTermDisableBarberVC.timeFormat)

        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
    
        let disableBarberModels: [DisableBarberModel] = [model]
        
        _ = NetworkManager.postDisableBarber(models: disableBarberModels, completionHandler: { method, response in
            self.onResponse(methodName: "POST_DISABLE_BARBER_API", response: response)
        })
    }
    
    @IBAction func onClickCrossButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateTimingButtons() {
        dateFromButton.setTitle(fromDate.string(fromFormat: LongTermDisableBarberVC.showcaseDateFormat), for: .normal)
        dateToButton.setTitle(toDate.string(fromFormat: LongTermDisableBarberVC.showcaseDateFormat), for: .normal)
        timeFromButton.setTitle(fromDate.string(fromFormat: LongTermDisableBarberVC.timeFormat), for: .normal)
        timeToButton.setTitle(toDate.string(fromFormat: LongTermDisableBarberVC.timeFormat), for: .normal)
    }
}
