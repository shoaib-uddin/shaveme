//
//  ImmediateBarberDisableVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/17/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import ObjectMapper

class ImmediateBarberDisableVC: BaseSideMenuViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    static let TIMELINE_GAP = 15
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectStylistsLabel: UILabel!
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var timelineCollectionView: UICollectionView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var timeLineContainer: UIView!
    
    private var timeLineItems: [DisableTimeLineItem] = []
    private var stylistPicker: ActionSheetStringPicker?
    private var selectedStylistIndex = 0
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "quick_barber_disable".localized()
        
        self.hideKeyboardOnTap()
        
        currentDateLabel.text = "current_date_with_argument".localized() + Date().string(fromFormat: "dd-MM-yyyy")
        
        self.timelineCollectionView.register(UINib(nibName: "DisableTimeLineItemCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        if let stylists = AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist, !stylists.isEmpty {
            let rows = stylists.map({ $0.name ?? "" })
            stylistPicker = ActionSheetStringPicker(title: "selectStylist".localized(), rows: rows, initialSelection: 0, doneBlock: onClickStylistDoneButton, cancel: { ActionStringCancelBlock in return }, origin: self.selectStylistsLabel)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
        self.timelineCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_DISABLE_BARBER_LIST_API:
                if let requestResult = Mapper<RequestResult>().map(JSONObject: response.value), let code = requestResult.status?.code, code == RequestStatus.CODE_OK, let timeRanges = Mapper<DisableBarberModel>().mapArray(JSONObject: requestResult.value) {
                    createTimelineItems(timeRanges: timeRanges)
                }
            case "POST_DISABLE_BARBER_API":
                self.customerNameTextField.text = nil
                AppUtils.showMessage(title: "success".localized(), message: "stylist_blocked_successfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    @IBAction func onClickSelectStylist(_ sender: Any) {
        if let stylistPicker = stylistPicker {
            stylistPicker.show()
        }
    }
    
    @IBAction func onClickBlock(_ sender: UIButton) {
        guard let stylist = AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist?[selectedStylistIndex] else {
            return
        }
        
        self.showProgressHUD()
        
        let customerName = customerNameTextField.text
        
        var disableBarberModelList: [DisableBarberModel] = []
        
        for item in timeLineItems {
            if item.isSelected {
                let customerNameToSelect = item.isPreviouslyCustomerNameAssigned ? item.customerName : customerName
                
                let disableBarberModel = DisableBarberModel(stylistId: stylist.stylistId)
                disableBarberModel.startTime = item.time.string(fromFormat: "HH:mm")
                disableBarberModel.startDate = item.time.string(fromFormat: "MM/dd/yyyy")
                disableBarberModel.customerName = customerNameToSelect
                disableBarberModel.type = "I"
                disableBarberModel.ln = AppController.sharedInstance.language
                disableBarberModel.endDate = item.getEndTime().string(fromFormat: "MM/dd/yyyy")
                disableBarberModel.endTime = item.getEndTime().string(fromFormat: "HH:mm")
                disableBarberModel.token = ServiceUtils.createHashToken(parameters: disableBarberModel.toJSON())
                
                disableBarberModelList.append(disableBarberModel)
            }
        }
        
        // Amit requires at least stylist id and start date in order to delete all the entries from the table
        if disableBarberModelList.isEmpty {
            let disableBarberModel = DisableBarberModel(stylistId: stylist.stylistId)
            
            disableBarberModel.ln = AppController.sharedInstance.language
            disableBarberModel.startDate = Date().string(fromFormat: "MM/dd/yyyy")
            
            disableBarberModelList.append(disableBarberModel)
        }

        _ = NetworkManager.postDisableBarber(models: disableBarberModelList, completionHandler: { method, response in
            self.onResponse(methodName: "POST_DISABLE_BARBER_API", response: response)
        })
    }
    
    @IBAction func onClickLongTermBlock(_ sender: UIButton) {
        guard let stylist = AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist?[selectedStylistIndex] else {
            return
        }
        
        let disableBarberModel = DisableBarberModel(stylistId: stylist.stylistId!)
        disableBarberModel.ln = AppController.sharedInstance.language
        disableBarberModel.type = "L"
        
        let controller = LongTermDisableBarberVC()
        controller.stylistName = stylist.name ?? ""
        controller.model = disableBarberModel
        AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.95, HeightMultiplier: 0.5)
    }
    
    func onClickStylistDoneButton(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        selectedStylistIndex = selectedIndex
        
        selectStylistsLabel.text = selectedValue as? String
        
        timeLineContainer.isHidden = true
        
        self.showProgressHUD()
        let stylistID = AppController.sharedInstance.loggedInBarber!.Stylist!.Stylist![selectedIndex].stylistId!
        
        _ = NetworkManager.getDisableBarberListAPI(stylishtID: stylistID, dateTime: Date().string(fromFormat: "MM/dd/yyyy"), completionHandler: onResponse)
    }

    // MARK: - Collection view delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeLineItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DisableTimeLineItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DisableTimeLineItemCell
        let timeLineItem = self.timeLineItems[indexPath.row]
        
        let timeFormat = "HH:mm"
        cell.startingTime.text = timeLineItem.time.string(fromFormat: timeFormat)
        
        cell.mImageView.image = timeLineItem.isSelected ? #imageLiteral(resourceName: "ic_time_selected") : #imageLiteral(resourceName: "ic_time_unselected")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let timeLineItem = self.timeLineItems[indexPath.row]
        timeLineItem.isSelected = !timeLineItem.isSelected
        
        let cell = collectionView.cellForItem(at: indexPath) as! DisableTimeLineItemCell
        cell.mImageView.image = timeLineItem.isSelected ? #imageLiteral(resourceName: "ic_time_selected") : #imageLiteral(resourceName: "ic_time_unselected")
    }

    // MARK: - Textfield delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Utility Methods
    
    func createTimelineItems(timeRanges: [DisableBarberModel]) {
        timeLineContainer.isHidden = false
        
        timeLineItems = []
        
        var startDateTime = Date()
        let minutesToAdd = ImmediateBarberDisableVC.TIMELINE_GAP - (startDateTime.getMinutes() % ImmediateBarberDisableVC.TIMELINE_GAP)
        startDateTime.addTimeInterval(TimeInterval(minutesToAdd * 60))
        let minutesInDay = startDateTime.getMinutes() + 60 * startDateTime.getHours()
        for _ in stride(from: minutesInDay, to: 1440, by: ImmediateBarberDisableVC.TIMELINE_GAP){
            // Create parent layout
            let item = DisableTimeLineItem(time: startDateTime)
            
            for range in timeRanges {
                if let dateTime = range.getStartDateTime() {
                    if startDateTime.compare(dateTime) == .orderedSame || (startDateTime.isBefore(to: range.getEndDateTime()) && startDateTime.isAfter(to: range.getStartDateTime())) {
                        item.isSelected = true
                        item.isPreviouslyCustomerNameAssigned = true
                        item.customerName = range.customerName
                        break
                    }
                }
            }
            
            timeLineItems.append(item)
            startDateTime.addTimeInterval(TimeInterval(ImmediateBarberDisableVC.TIMELINE_GAP * 60))
        }
        
        self.timelineCollectionView.reloadData()
    }
}

class DisableTimeLineItem {
    var time: Date = Date()
    var isPreviouslyCustomerNameAssigned = false
    var isReserved = false
    var isSelected = false
    var isVisible = true
    var customerName: String?
    
    init(time: Date) {
        self.time = time
    }
    
    func getEndTime() -> Date {
        var endTime = time
        let timeToAdd = 60 * ReservationVC.TIMELINE_GAP
        endTime.addTimeInterval(TimeInterval(timeToAdd))
        return endTime
    }
}

class DisableTimeLineItemCell: UICollectionViewCell {
    @IBOutlet weak var startingTime : UILabel!
    @IBOutlet weak var mImageView : UIImageView!
}
