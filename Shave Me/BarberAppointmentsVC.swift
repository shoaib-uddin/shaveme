//
//  BarberAppointmentsVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/31/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import FSCalendar
import ObjectMapper
import Alamofire

class BarberAppointmentsVC: BaseSideMenuViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    fileprivate static let TOTAL_APIS_TO_WAIT_FOR = 2
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    fileprivate var reservationModels: [BarberAppoinmentModel]?
    fileprivate var disableBarberModelList: [DisableBarberModel] = []
    fileprivate var appointmentModels: [BarberCalendarAppointmentModel] = []
    fileprivate var dataRequest: DataRequest?
    fileprivate var currentApisToWaitFor = 0
    fileprivate var selectedDate = Date()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = "appoinments".localized()
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.register(UINib(nibName: "BarberCalendarAppointmentTVCell", bundle: nil), forCellReuseIdentifier: "BarberCalendarAppointmentReusableCell")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.makeRequest()
    }
    
    override func onPushNotificationReceived(notification: NSNotification) {
        super.onPushNotificationReceived(notification: notification)
        
        if let userInfo = notification.userInfo {
            let pushMessage = PushMessageModel(userInfo: userInfo)
            
            if pushMessage.statusID != AppoinmentModel.STANDALONE_PUSH_MESSAGE {
                
                makeRequest()
            }
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBERRESERVATION_API:
                reservationModels = BarberAppoinmentModel.filterAppointments(response: response.value)
            case ServiceUtils.GET_DISABLE_BARBER_ALL_LIST_API:
                if let requestResult = Mapper<RequestResult>().map(JSONObject: response.value), let code = requestResult.status?.code, code == RequestStatus.CODE_OK, let timeRanges = Mapper<DisableBarberModel>().mapArray(JSONObject: requestResult.value) {
                    for item in timeRanges {
                        if item.isIn(models: self.disableBarberModelList) == false {
                            disableBarberModelList.append(item)
                        }
                    }
                }
            default:
                break
            }
        } else {
            self.hideProgressHUD()
            
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
            self.setStatus(text: "ServerError".localized())
        }
        
        updateProgress()
    }
    
    @IBAction func onClickDisableButton(_ sender: UIButton) {
        let controller = ImmediateBarberDisableVC()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onClickRefreshButton(_ sender: UIButton) {
        self.makeRequest()
    }
    
    // MARK: - Calendar View Methods
    
    //    func minimumDate(for calendar: FSCalendar) -> Date {
    //        var today = Date()
    //        today.addDays(numberOfDays: -2)
    //        return today
    //    }
    
    //    func maximumDate(for calendar: FSCalendar) -> Date {
    //        var today = Date()
    //        today.addDays(numberOfDays: 7)
    //        return today
    //    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        selectedDate = date
        
        loadReservations()
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    // MARK: - Table View Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointmentModels.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:BarberCalendarAppointmentTVCell = self.tableView.dequeueReusableCell(withIdentifier: "BarberCalendarAppointmentReusableCell") as! BarberCalendarAppointmentTVCell
        let model = self.appointmentModels[indexPath.row]
        
        cell.stylistNameLabel.text = model.title
        cell.descriptionLabel.text = model.description
        cell.startTimeLabel.text = model.startTime
        cell.endTimeLabel.text = model.endTime
        cell.verticalLineView.backgroundColor = model.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let model = self.appointmentModels[indexPath.row].model {
            let frontViewController = BarberAppoinmentDetailVC()
            frontViewController.appointmentID = model.id
            self.navigationController?.pushViewController(frontViewController, animated: true)
        }
    }
    
    // MARK: - Utility Methods
    
    func makeRequest() {
        guard let id = AppController.sharedInstance.loggedInBarber?.barberShopId else {
            self.setStatus(text: "pleaseloginbarber".localized())
            return
        }
        
        currentApisToWaitFor = 0
        
        if let dataRequest = dataRequest {
            dataRequest.cancel()
        }
        
        self.showProgressHUD()
        
        dataRequest = NetworkManager.getBarberReservations(barberID: id, completionHandler: onResponse)
        dataRequest = NetworkManager.getDisableBarberAllList(barberID: id, completionHandler: onResponse)
        
    }
    
    func setStatus(text: String) {
        self.tableView.isHidden = true
        self.statusLabel.text = text
        self.statusLabel.isHidden = false
    }
    
    func loadReservations() {
        guard let barber = AppController.sharedInstance.loggedInBarber else {
            return
        }
        
        self.appointmentModels.removeAll()
        
        if let model = AvailabilityModel.getModel(models: barber.Availability, day: selectedDate.dayNumberOfWeek()), !model.startTime.isEmpty {
            
            if let reservationModels = reservationModels, !reservationModels.isEmpty {
                for item in reservationModels {
                    if self.selectedDate.isEqualToDateOnly(dateTo: item.getReservedDate()), item.statusId == AppoinmentModel.APPOINMENT_CONFIRMED {
                        var description = item.stylistName! + " has reservation at this time"
                        if let userName = item.userName, !userName.isEmpty {
                            description += " for customer " + userName
                        }
                        
                        let barberCalAppModel = BarberCalendarAppointmentModel(startTime: item.reservedTimingFrom!, endTime: item.reservedTimingTo!, color: UIColor.COL47d9bf(), stylistID: item.styleId!, title: "reservation".localized(), description: description)
                        barberCalAppModel.model = item
                        self.appointmentModels.append(barberCalAppModel)
                    }
                }
            }
            
            // Implement disable timings
            if !disableBarberModelList.isEmpty {
                for item in disableBarberModelList {
                    if self.selectedDate.isDateBetweenBothInclusive(dateFrom: item.getStartDateOnly(), dateTo: item.getEndDateOnly()), let stylist = StylistModel.getModel(models: barber.Stylist?.Stylist, id: item.stylistId) {
                        var description = stylist.name! + " is blocked at this time"
                        if let customerName = item.customerName, !customerName.isEmpty {
                            description += " for customer " + customerName
                        }
                        
                        let barberCalAppModel = BarberCalendarAppointmentModel(startTime: item.startTime!.to12HourString()!, endTime: item.endTime!.to12HourString()!, color: UIColor.gray, stylistID: item.stylistId!, title: "blocked".localized(), description: description)
                        self.appointmentModels.append(barberCalAppModel)
                    }
                }
            }
            
            self.tableView.reloadData()
            
            self.tableView.isHidden = false
            self.statusLabel.isHidden = true
        } else{
            setStatus(text: "shopclosedforselecteddate".localized())
        }
    }
    
    func updateProgress() {
        currentApisToWaitFor += 1
        if currentApisToWaitFor >= BarberAppointmentsVC.TOTAL_APIS_TO_WAIT_FOR {
            self.hideProgressHUD()
            
            loadReservations()
        }
    }
}

class BarberCalendarAppointmentModel {
    let startTime: String
    let endTime: String
    let title: String
    let description: String
    let color: UIColor
    let stylistID: Int
    var model: BarberAppoinmentModel?
    
    init(startTime: String, endTime: String, color: UIColor, stylistID: Int, title: String, description: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.stylistID = stylistID
        self.title = title
        self.description = description
    }
}

