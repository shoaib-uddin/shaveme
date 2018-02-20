//
//  ReservationVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/22/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import UIView_FDCollapsibleConstraints
import ObjectMapper
import ActionSheetPicker_3_0

class ReservationVC: BaseSideMenuViewController, ViewControllerInterationProtocol, UICollectionViewDataSource, UICollectionViewDelegate {
    
    static let TIMELINE_GAP = 15
    
    var barberShopID: Int?
    var appointmentModel: AppoinmentModel?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopAddress: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectStylistsLabel: UILabel!
    @IBOutlet weak var selectedServicesLabel: UILabel!
    @IBOutlet weak var selectServicesButton: UIButton!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var selectDateLabel: UILabel!
    @IBOutlet weak var statusAndTimeLineContainer: UIView!
    @IBOutlet weak var closedStatusLabel: UILabel!
    @IBOutlet weak var timelineCollectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    
    private var shopModel: BarberModel?
    private var cost: Double = 0
    private var duration: Int = 0
    private var stylistPicker: ActionSheetStringPicker?
    private var selectedDate: Date = Date()
    private var appointmentModels: [AppoinmentModel]?
    private var selectedStylistIndex = 0
    private var selectedServices = [Int : ServiceModel]()
    private var timeLineItems: [TimeLineItem] = []
    
    private var removeYourself = false
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusAndTimeLineContainer.fd_collapsed = true
        
        // Mapping all the click callbacks
        AppUtils.setGestureRecognizers(senders: selectStylistsLabel, selectServicesButton, selectDateLabel, continueButton, target: self, action: #selector(ReservationVC.onClickCallback(_:)))
        
        self.makeServerRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.timelineCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if removeYourself {
            _ = self.navigationController?.popViewController(animated: false)
        }
        
        makeRequest();
        
    }
    
    func makeRequest() {
        guard let userID = AppController.sharedInstance.loggedInUser?.id else {
            
            //AppUtils.showLoginMessage(viewController: self, storyboard: UIStoryboard(name: "Main", bundle: nil), handler: nil)
            AppUtils.showLoginMessage(viewController: self, storyboard: UIStoryboard(name: "Main", bundle: nil), handler: { (action) in
                
                if(action.title!.lowercased() == "cancel"){
                    self.navigationController?.popViewController(animated: true);
                }
                
            })
            
            return
        }
        
    }
    
    // MARK: - Collection view delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let endCount = timeLineItems.count - (TimeLineItem.endingIndex + 1)
        let count = timeLineItems.count - TimeLineItem.startingIndex - endCount
        return count > 0 ? count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TimeLineItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TimeLineItemCell
        let timeLineItem = self.timeLineItems[indexPath.row + TimeLineItem.startingIndex]
        
        let timeFormat = "hh:mm aa"
        cell.startingTime.text = timeLineItem.time.string(fromFormat: timeFormat)
        cell.endingTime.text = timeLineItem.getEndTime().string(fromFormat: timeFormat)
        
        if timeLineItem.isBlocked {
            cell.alpha = 0.5
            cell.mImageView.image = #imageLiteral(resourceName: "ic_time_unselected")
        } else if timeLineItem.isReserved {
            cell.alpha = 0.95
            cell.mImageView.image = #imageLiteral(resourceName: "ic_time_reserved")
        } else {
            cell.alpha = 1
            cell.mImageView.image = timeLineItem.isSelected ? #imageLiteral(resourceName: "ic_time_selected") : #imageLiteral(resourceName: "ic_time_unselected")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let timeLineItem = self.timeLineItems[indexPath.row + TimeLineItem.startingIndex]
        
        var errorMessage = ""
        if timeLineItem.isReserved {
            errorMessage = "already_made_reservation_error_message".localized()
        } else if timeLineItem.isBlocked {
            errorMessage = "blocked_time_error_message".localized()
        } else {
            // get calendar instance of current item
            // check if last list visible item and currently selected item time difference is greater than equal to duration
            // create new instance and add duration
            // loop through all the items and check if they reside in above range
            // if they conflict with any reserved time and break time
            // if all go well add them in new list
            // now if at the end of the loop if no confliction occurs. unselect previous range and select new one
            let difference = timeLineItem.time.getDifferenceInSeconds(to: timeLineItems[TimeLineItem.endingIndex].getEndTime())
            if difference / 60 >= duration {
                var endTimelineDate = timeLineItem.time
                endTimelineDate.addTimeInterval(TimeInterval(duration * 60))
                
                var itemToChangeList = [TimeLineItem]()
                
                var position = TimeLineItem.startingIndex + indexPath.row
                while position < TimeLineItem.endingIndex + 1 {
                    let childAt = self.timeLineItems[position]
                    
                    if childAt.time.compareTimeOnly(to: timeLineItem.time) == .orderedSame || (childAt.time.isAfterTimeOnly(to: timeLineItem.time) && childAt.time.isBeforeTimeOnly(to: endTimelineDate)) {
                        if childAt.isReserved || childAt.isBlocked {
                            errorMessage = childAt.isReserved ? "already_made_reservation_error_message".localized() : "blocked_time_error_message".localized()
                            break
                        } else {
                            itemToChangeList.append(childAt)
                        }
                    } else {
                        break;
                    }
                    position += 1
                }
                
                if errorMessage.isEmpty {
                    for item in timeLineItems {
                        item.isSelected = false
                    }
                    
                    for item in itemToChangeList {
                        item.isSelected = true
                    }
                    
                    self.timelineCollectionView.reloadData()
                }
            } else {
                errorMessage = "no_room_to_perform_services_error_message".localized()
            }
        }
        
        if !errorMessage.isEmpty {
            AppUtils.showMessage(title: "alert".localized(), message: errorMessage, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBERDETAIL_API:
                if let array = Mapper<BarberModel>().mapArray(JSONObject: response.value), array.count > 0 {
                    shopModel = array.first!
                    onBarberModelLoaded()
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "authenticationFailed".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            case ServiceUtils.GET_RESERVATION_API: fallthrough
            case ServiceUtils.GET_RESERVATIONBYSTYLIST_API:
                let models = AppoinmentModel.filterAppointments(response: response.value)
                let sortedModels = AppoinmentModel.sort(models: models)
                setReservedAppoinments(appointmentModels: sortedModels)
                setDateTime(selectedDate: selectedDate)
            default:
                break
            }
        } else {
            statusLabel.isHidden = false
            statusLabel.text = response.status?.message
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
        
        activityIndicator.stopAnimating()
    }
    
    func onClickCallback(_ sender: UITapGestureRecognizer) {
        switch sender.view! {
        case self.selectStylistsLabel:
            stylistPicker?.show()
        case self.selectServicesButton:
            onClickSelectServices()
        case self.selectDateLabel:
            onClickDatePicker()
        case self.continueButton:
            onClickContinue()
        default:
            break
        }
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .selectServices {
            onServicesSelectionChange(data: data)
        } else if interactionType == .reservationConfirmed {
            removeYourself = true
        }
    }
    
    func onClickSelectServices() {
        resetTimelineSelection()
        
        var itemListArray: [ListItem] = [ListItem]()
        
        if let shopServices = self.shopModel?.Services {
            // If "any" stylist is selected show all services
            if selectedStylistIndex == 0 {
                for model in shopServices {
                    if model.isAssociated == 1 {
                        let isFound = selectedServices[model.serviceId] != nil
                        itemListArray.append(ListItem(name: model.name, id: model.serviceId, isSelected: isFound))
                    }
                }
            } else {
                // else show that particular stylist services
                let stylistServiceIds = (shopModel!.Stylist!.Stylist![selectedStylistIndex - 1].services ?? "").components(separatedBy: ",")
                for serviceID in stylistServiceIds {
                    if let model = ServiceModel.getModel(services: shopServices, id: Int(serviceID)) {
                        let isFound = selectedServices[model.serviceId] != nil
                        itemListArray.append(ListItem(name: model.name, id: model.serviceId, isSelected: isFound))
                    }
                }
            }
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: SelectServicesVC.storyBoardID) as! SelectServicesVC
            controller.originalListItems = itemListArray
            controller.delegate = self
            let navController = UINavigationController(rootViewController: controller)
            AppUtils.addViewControllerModally(originVC: self, destinationVC: navController, widthMultiplier: 0.9, HeightMultiplier: 0.8)
        }
    }
    
    func onClickStylist(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        selectedStylistIndex = selectedIndex
        
        selectStylistsLabel.text = selectedValue as? String
        
        if let userID = AppController.sharedInstance.loggedInUser?.id {
            activityIndicator.startAnimating()
            resetReservedTimings()
            
            let dateString = self.selectedDate.localString(fromFormat: "MM/dd/yyyy")
            if selectedIndex > 0 {
                let stylistID = shopModel?.Stylist?.Stylist?[selectedIndex - 1].stylistId
                _ = NetworkManager.getReservationsByStylist(stylistID: stylistID, dateTime: dateString, completionHandler: onResponse)
                _ = NetworkManager.getReservations(userID: userID, dateTime: dateString, completionHandler: onResponse)
            } else {
                // Selected Any Stylist
                _ = NetworkManager.getReservations(userID: userID, dateTime: dateString, completionHandler: onResponse)
            }
        }
        
        resetSelection()
    }
    
    func onClickContinue() {
        guard let shopModel = shopModel, selectedServices.count > 0 else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkserviceselected".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        let format = "hh:mm aa"
        var startingTimeStr: String?
        for item in timeLineItems {
            if item.isSelected {
                startingTimeStr = item.time.string(fromFormat: format)
                break
            }
        }
        var endingTimeStr: String?
        for item in timeLineItems.reversed() {
            if item.isSelected {
                endingTimeStr = item.getEndTime().string(fromFormat: format)
                break
            }
        }
        
        guard let startingTime = startingTimeStr, let endingTime = endingTimeStr else {
            AppUtils.showMessage(title: "alert".localized(), message: "timeValidation".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        let servideIDs = selectedServices.values.map({ return String($0.serviceId) }).joined(separator: ",")
        let servideNames = selectedServices.values.map({ return String($0.name) }).joined(separator: ", ")
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: ReservationConfirmationVC.storyBoardID) as! ReservationConfirmationVC
        
        controller.shopId = String(shopModel.shopid)
        controller.ShopName = shopModel.shopName
        controller.date = selectedDate.string(fromFormat: "EEE, MMM d, yyyy")
        controller.StartTime = startingTime
        controller.EndTime = endingTime
        controller.Duration = String(duration)
        controller.StylistId = String(selectedStylistIndex > 0 ? shopModel.Stylist!.Stylist![selectedStylistIndex - 1].stylistId! : 0)
        controller.Stylist = selectedStylistIndex > 0 ? shopModel.Stylist!.Stylist![selectedStylistIndex - 1].name! : "any".localized()
        controller.Services = servideNames
        controller.ServiceIds = servideIDs
        controller.TotalCost = String(cost)
        controller.delegate = self
        
        if let appointmentId = self.appointmentModel?.id {
            controller.reservationId = String(appointmentId)
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Utility Methods
    
    func onBarberModelLoaded() {
        guard let shopModel = self.shopModel else {
            return
        }
        
        scrollView.isHidden = false
        shopName.isHidden = false
        shopAddress.isHidden = false
        
        createTimeLine()
        
        self.shopName.text = shopModel.shopName
        self.shopAddress.text = shopModel.shopAddress
        loadStylists()
        setCostAndDuration()
        setDateTime(selectedDate: selectedDate)
        
        if let userID = AppController.sharedInstance.loggedInUser?.id {
            let dateString = self.selectedDate.localString(fromFormat: "MM/dd/yyyy")
            _ = NetworkManager.getReservations(userID: userID, dateTime: dateString, completionHandler: onResponse)
        }
    }
    
    func makeServerRequest() {
        if let shopID = self.barberShopID {
            let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
            _ = NetworkManager.getBarberShopDetails(shopID: shopID, userID: userID, completionHandler: onResponse)
        }
    }
    
    func loadStylists() {
        if let stylists = shopModel?.Stylist?.Stylist {
            var rows = stylists.map({ $0.name ?? "" })
            rows.insert("any".localized(), at: 0)
            
            var selectedIndex = 0
            if let appointmentModel = self.appointmentModel {
                var index = 0
                for s in stylists {
                    if s.stylistId == appointmentModel.styleId {
                        selectedIndex = index + 1
                        break
                    }
                    index += 1
                }
            }
            
            selectedStylistIndex = selectedIndex
            stylistPicker = ActionSheetStringPicker(title: "selectStylist".localized(), rows: rows, initialSelection: selectedIndex, doneBlock: onClickStylist, cancel: { ActionStringCancelBlock in return }, origin: self.selectStylistsLabel)
            selectStylistsLabel.text = rows[selectedIndex]
        }
    }
    
    func resetReservedTimings() {
        for item in timeLineItems {
            item.isBlocked = false
            item.isReserved = false
        }
    }
    
    func resetSelection() {
        // Resetting service selection
//        selectedServices.removeAll()
//        selectedServicesLabel.text = nil
//        selectedServicesLabel.superview?.isHidden = true
        
//        cost = 0
//        duration = 0
        
        resetTimelineSelection()
        
        setCostAndDuration()
        setTimeLine()
    }
    
    func resetTimelineSelection() {
        for item in timeLineItems {
            item.isSelected = false
        }
        self.timelineCollectionView.collectionViewLayout.invalidateLayout()
        self.timelineCollectionView.reloadData()
    }
    
    func setDateTime(selectedDate: Date) {
        var isChanged = false
        var statusText = "shopclosedforselecteddate".localized()
        
        if let availability = getAvailabalityModel(selectedDate: selectedDate) {
            var startTime = availability.startTime.date(fromFormat: "HH:mm")
            var endTime = availability.endTime.date(fromFormat: "HH:mm")
            if startTime == nil {
                startTime = availability.startTime.date(fromFormat: "HH:mm:ss")
            }
            if endTime == nil {
                endTime = availability.endTime.date(fromFormat: "HH:mm:ss")
            }
            
            if let startTime = startTime, let endTime = endTime, startTime.getDifferenceInSecondsOfTimeOnly(to: endTime) > 0 {
                if selectedDate.isCurrentDate() && startTime.isBeforeTimeOnly(to: Date()) {
                    if endTime.isBeforeTimeOnly(to: Date()) {
                        setTimelineStartTime(startTime: endTime)
                    } else {
                        var today = Date()
                        let min = Calendar.current.component(.minute, from: today)
                        let HOUR_INTERVAL = 60 * 60
                        let MINUTE_INTERVAL = 60
                        if min >= 0 && min < 15 {
                            today.addTimeInterval(TimeInterval(HOUR_INTERVAL))
                            today.addTimeInterval(TimeInterval(MINUTE_INTERVAL * (15 - min)))
                        } else if (min >= 15 && min < 30) {
                            today.addTimeInterval(TimeInterval(HOUR_INTERVAL))
                            today.addTimeInterval(TimeInterval(MINUTE_INTERVAL * (30 - min)))
                        } else if (min >= 30 && min < 45) {
                            today.addTimeInterval(TimeInterval(HOUR_INTERVAL))
                            today.addTimeInterval(TimeInterval(MINUTE_INTERVAL * (45 - min)))
                        } else if (min >= 45 && min < 60) {
                            today.addTimeInterval(TimeInterval(2 * HOUR_INTERVAL))
                            today.addTimeInterval(TimeInterval(MINUTE_INTERVAL * (0 - min)))
                        }
                        today.addTimeInterval(TimeInterval(MINUTE_INTERVAL * (shopModel!.minReservationTime - 60)))
                        setTimelineStartTime(startTime: today)
                    }
                } else {
                    setTimelineStartTime(startTime: startTime)
                }
                
                setTimelineEndTime(endTime: endTime)
                
                if !availability.breakStartTime.isEmpty, !availability.breakEndTime.isEmpty {
                    var breakStartTime = availability.breakStartTime.date(fromFormat: "HH:mm")
                    var breakEndTime = availability.breakEndTime.date(fromFormat: "HH:mm")
                    if breakStartTime == nil {
                        breakStartTime = availability.breakStartTime.date(fromFormat: "HH:mm:ss")
                    }
                    if breakEndTime == nil {
                        breakEndTime = availability.breakEndTime.date(fromFormat: "HH:mm:ss")
                    }
                    if let breakStartTime = breakStartTime, let breakEndTime = breakEndTime {
                        blockTimeLine(startTime: breakStartTime, endTime: breakEndTime)
                    }
                }
                
                isChanged = true
            } else if selectedStylistIndex > 0 {
                statusText = "stylistnotavailableforselecteddate".localized()
            }
        }
        
        // If date is calculated that means its changed
        self.timelineCollectionView.collectionViewLayout.invalidateLayout()
        self.timelineCollectionView.reloadData()
        self.closedStatusLabel.text = isChanged ? nil : statusText
        self.closedStatusLabel.isHidden = isChanged
        self.timelineCollectionView.superview!.isHidden = !isChanged
        selectDateLabel.text = selectedDate.localString(fromFormat: "EEE, MMM d, yyyy")
    }
    
    func setTimeLine() {
        statusAndTimeLineContainer.fd_collapsed = duration <= 0
    }
    
    func createTimeLine() {
        timeLineItems = []
        
        var startDateTime = "00:00".date(fromFormat: "HH:mm")!
        for _ in stride(from: 0, to: 1440, by: ReservationVC.TIMELINE_GAP){
            // Create parent layout
            timeLineItems.append(TimeLineItem(time: startDateTime))
            startDateTime.addTimeInterval(TimeInterval(ReservationVC.TIMELINE_GAP * 60))
        }
        
        self.timelineCollectionView.reloadData()
    }
    
    func blockTimeLine(startTime: Date, endTime: Date) {
        for item in timeLineItems {
            if item.time.compareTimeOnly(to: startTime) == .orderedSame || (item.time.isAfterTimeOnly(to: startTime) && item.time.isBeforeTimeOnly(to: endTime)) {
                item.isBlocked = true
            }
        }
    }
    
    func reserveTimeLine(startTime: Date, endTime: Date) {
        for item in timeLineItems {
            if item.time.compareTimeOnly(to: startTime) == .orderedSame || (item.time.isAfterTimeOnly(to: startTime) && item.time.isBeforeTimeOnly(to: endTime)) {
                item.isReserved = true
            }
        }
    }
    
    func setTimelineEndTime(endTime: Date) {
        for i in stride(from: timeLineItems.count - 1, to: 0, by: -1){
            let timeLineItem = timeLineItems[i]
            if endTime.getDifferenceInSecondsOfTimeOnly(to: timeLineItem.time) >= 0 {
                timeLineItem.isVisible = false
            } else {
                TimeLineItem.endingIndex = i
                return
            }
        }
    }
    
    func setTimelineStartTime(startTime: Date) {
        TimeLineItem.startingIndex = 0
        for i in stride(from: 0, to: timeLineItems.count, by: 1){
            let timeLineItem = timeLineItems[i]
            if timeLineItem.time.isBeforeTimeOnly(to: startTime) {
                timeLineItem.isVisible = false
            } else {
                TimeLineItem.startingIndex = i
                return
            }
        }
    }
    
    func setReservedAppoinments(appointmentModels: [AppoinmentModel]) {
        if appointmentModels.count > 0 {
            let format = "yyyy-MM-dd'T'hh:mm:ss"
            for item in appointmentModels {
                if let reservedDateStr = item.reservedDate, let reservedDate = reservedDateStr.date(fromFormat: format), reservedDate.isEqualToDateOnly(dateTo: self.selectedDate) {
                    if !(item.statusId == AppoinmentModel.APPOINMENT_CANCELLED_BY_USER || item.statusId == AppoinmentModel.APPOINMENT_CANCELLED_BY_SHOP || item.statusId == AppoinmentModel.APPOINMENT_CONFIRMED_NOT_ATTEND
                        || item.statusId == AppoinmentModel.APPOINMENT_COMPLETED || item.statusId == AppoinmentModel.APPOINMENT_CANCELLATION_APPROVED || item.statusId == AppoinmentModel.APPOINMENT_AUTO_CANCELLED) {
                        
                        if let reservedTimingFrom = item.reservedTimingFrom?.date(fromFormat: "hh:mm aa"), let reservedTimingTo = item.reservedTimingTo?.date(fromFormat: "hh:mm aa") {
                            reserveTimeLine(startTime: reservedTimingFrom, endTime: reservedTimingTo)
                        }
                    }
                }
            }
            setDateTime(selectedDate: selectedDate)
        }
    }
    
    func setCostAndDuration() {
        costLabel.text = "totalCost".localized() + " " + String(cost) + " " + "aed".localized()
        durationLabel.text = "approxDuration".localized() + " " + String(duration) + " " + "mins".localized()
    }
    
    func getAvailabalityModel(selectedDate: Date) -> AvailabilityModel? {
        if let availabilityArray = shopModel!.Availability, availabilityArray.count > 0 {
            for shopAvailability in availabilityArray {
                if let dayNumberOfWeek = selectedDate.dayNumberOfWeek(), dayNumberOfWeek == shopAvailability.day {
                    if selectedStylistIndex > 0, let stylistAvailabilityArray = shopModel?.Stylist?.Stylist?[selectedStylistIndex - 1].StylistAvailability {
                        for stylistAvailability in stylistAvailabilityArray {
                            if let dayNumberOfWeek = selectedDate.dayNumberOfWeek(), dayNumberOfWeek == stylistAvailability.day {
                                return stylistAvailability
                            }
                        }
                    }
                    return shopAvailability
                }
            }
        }
        return nil
    }
    
    func onServicesSelectionChange(data: Any?) {
        let itemList = data as? [ListItem]
        var formattedServiceList = ""
        if let itemList = itemList {
            for item in itemList {
                if item.isSelected {
                    if selectedServices[item.id] == nil, let model = ServiceModel.getModel(services: shopModel?.Services, id: item.id) {
                        selectedServices[item.id] = model
                        cost += Double(model.cost)
                        duration += model.duration
                    }
                } else {
                    if  let model = selectedServices[item.id] {
                        cost -= Double(model.cost)
                        duration -= model.duration
                        
                        selectedServices[item.id] = nil
                    }
                }
            }
            
            formattedServiceList = itemList.flatMap({ $0.isSelected ? "\($0.name)" : nil }).joined(separator: ", ")
        }
        
        setCostAndDuration()
        setTimeLine()
        
        selectedServicesLabel.text = formattedServiceList
        selectedServicesLabel.superview?.isHidden = formattedServiceList.isEmpty
    }
    
    func onClickDatePicker() {
        let title = "select".localized() + " " + "date".localized()
        let datePicker = ActionSheetDatePicker(title: title, datePickerMode: UIDatePickerMode.date, selectedDate: self.selectedDate, doneBlock: {
            picker, value, index in
            self.selectedDate = value as! Date
            
            self.resetReservedTimings()
            self.resetSelection()
            
            if let userID = AppController.sharedInstance.loggedInUser?.id {
                self.activityIndicator.startAnimating()
                
                let dateString = self.selectedDate.localString(fromFormat: "MM/dd/yyyy")
                if self.selectedStylistIndex > 0 {
                    let stylistID = self.shopModel?.Stylist?.Stylist?[self.selectedStylistIndex - 1].stylistId
                    _ = NetworkManager.getReservationsByStylist(stylistID: stylistID, dateTime: dateString, completionHandler: self.onResponse)
                    _ = NetworkManager.getReservations(userID: userID, dateTime: dateString, completionHandler: self.onResponse)
                } else {
                    // Selected Any Stylist
                    _ = NetworkManager.getReservations(userID: userID, dateTime: dateString, completionHandler: self.onResponse)
                }
            } else {
                self.setDateTime(selectedDate: self.selectedDate)
            }
        }, cancel: { ActionStringCancelBlock in return }, origin: self.selectDateLabel)
        datePicker?.minimumDate = Date()
        let secondsInSixMonths: TimeInterval = 6 * 30 * 24 * 60 * 60;
        var sixMonthsDate = Date()
        sixMonthsDate.addTimeInterval(secondsInSixMonths)
        datePicker?.maximumDate = sixMonthsDate
        
        datePicker?.show()
    }
}

class TimeLineItem {
    static var startingIndex = 0
    static var endingIndex = 0
    
    var time: Date = Date()
    var isBlocked = false
    var isReserved = false
    var isSelected = false
    var isVisible = true
    
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

class TimeLineItemCell: UICollectionViewCell {
    @IBOutlet weak var startingTime : UILabel!
    @IBOutlet weak var endingTime : UILabel!
    @IBOutlet weak var mImageView : UIImageView!
}
