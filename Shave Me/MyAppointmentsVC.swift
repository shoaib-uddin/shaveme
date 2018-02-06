//
//  MyAppointmentsVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/9/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire

class MyAppointmentsVC: BaseSideMenuViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, TableViewCellProtocol, ViewControllerInterationProtocol {
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataRequest: DataRequest?
    fileprivate var sectionDataArray: [SectionData<AppoinmentModel>]?
    fileprivate var selectedSectionDataArray: [SectionData<AppoinmentModel>]?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "myappoinments".localized()
        
        self.tableView.estimatedRowHeight = 180
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        segmentControl.setTitle(segmentControl.titleForSegment(at: 0)?.localized(), forSegmentAt: 0)
        segmentControl.setTitle(segmentControl.titleForSegment(at: 1)?.localized(), forSegmentAt: 1)
        
        self.tableView.register(UINib(nibName: "CalendarAppointmentCell", bundle: nil), forCellReuseIdentifier: "CalendarAppointmentReusableCell")
        
        makeRequest()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
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
            case ServiceUtils.GET_RESERVATION_API:
                let models = AppoinmentModel.filterAppointments(response: response.value)
                let appointmentModels = AppoinmentModel.sort(models: models)
                
                self.sectionDataArray = []
                for item in appointmentModels {
                    let dateStr = item.getReservedDate()?.string(fromFormat: "EEE dd, MMM yyyy")
                    
                    if let sectionData = SectionData.getModel(models: self.sectionDataArray, byTitle: dateStr) {
                        sectionData.append(model: item)
                    } else {
                        self.sectionDataArray!.append(SectionData(title: dateStr ?? "", model: item))
                    }
                }
                
                self.selectedSectionDataArray = self.sectionDataArray
                self.calendar.reloadData()
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .appointmentCancelled {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onSegmentValueChange(_ sender: UISegmentedControl) {
        
        // Month segment
        if sender.selectedSegmentIndex == 0 {
            self.calendar.isHidden = false
            self.tableView.isHidden = true
        } else {
            // List Selected
            self.selectedSectionDataArray = self.sectionDataArray
            
            self.calendar.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Calendar View Methods
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date().startOfMonth()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        var today = Date()
        today.addMonths(numberOfMonths: 6)
        return today
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let models = self.sectionDataArray, !models.isEmpty {
            let format = "EEE dd, MMM yyyy"
            for item in models {
                if let reservedDate = item.title.date(fromFormat: format), reservedDate.isEqualToDateOnly(dateTo: date) {
                    return item.numberOfItems
                }
            }
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        var clickedModels = [SectionData<AppoinmentModel>]()
        if let models = self.sectionDataArray, !models.isEmpty {
            let format = "EEE dd, MMM yyyy"
            for item in models {
                if let reservedDate = item.title.date(fromFormat: format), reservedDate.isEqualToDateOnly(dateTo: date) {
                    clickedModels.append(item)
                    break
                }
            }
        }
        
        if !clickedModels.isEmpty {
            if clickedModels.first!.numberOfItems == 1 {
                _ = openDetailActivity(model: clickedModels.first!.models.first!)
            } else {
                self.selectedSectionDataArray = clickedModels
                self.tableView.reloadData()
                
                self.calendar.isHidden = true
                self.tableView.isHidden = false
                
                self.segmentControl.selectedSegmentIndex = 1
            }
        }
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    // MARK: - Tableview Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.selectedSectionDataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.selectedSectionDataArray![section].title
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedSectionDataArray?[section].numberOfItems ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CalendarAppointmentCell = self.tableView.dequeueReusableCell(withIdentifier: "CalendarAppointmentReusableCell") as! CalendarAppointmentCell
        let model = self.selectedSectionDataArray![indexPath.section][indexPath.row]
        
        cell.setCustomDelegateCallback(delegate: self, cellIndex: indexPath, data: model)
        
        cell.shopNameLabel.text = model.shopName
        cell.stylistNameLabel.text = model.stylistName
        let appDescription = (model.reservedTimingFrom ?? "") + " - " + (model.reservedTimingTo ?? "")
        cell.appoinmentDescriptionLabel.text = appDescription + ", " + String(describing: model.servicesDuration ?? 0) + " " + "mins".localized()
        cell.setStatus(statusId: model.statusId)
        cell.setCancelButtonVisibility(statusId: model.statusId, reservedDate: model.reservedDate, reservedTimingFrom: model.reservedTimingFrom)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = self.selectedSectionDataArray![indexPath.section][indexPath.row]
        let controller = openDetailActivity(model: model)
        controller.delegate = self
    }
    
    func didClickOnCell(indexPath: IndexPath, cell: UITableViewCell, data: Any?, sender: Any) {
        let model = data as! AppoinmentModel
        let cell = cell as! CalendarAppointmentCell
        
        if sender as? UIButton == cell.cancelButton {
            let alert = UIAlertController(title: "alert".localized(), message: "cancelAppoinment".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "yes".localized(), style: .default, handler: { _ in
                self.showProgressHUD()
                
                let cancelModel = CancelReservationModel(id: model.id!, statusId: AppoinmentModel.APPOINMENT_CANCELLED_BY_USER, userId: AppController.sharedInstance.loggedInUser?.id ?? 0)
                _ = NetworkManager.updateReservation(reservationID: model.id!, reservationModel: cancelModel, completionHandler: { (methodName, response) in
                    
                    self.hideProgressHUD()
                    if response.status?.code == RequestStatus.CODE_OK {
                        AppUtils.showMessage(title: "alert".localized(), message: "updatedSuccessfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                        
                        model.statusId = AppoinmentModel.APPOINMENT_CANCELLED_BY_USER
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    } else {
                        AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "no".localized(), style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Utility Methods
    
    func makeRequest() {
        guard let userID = AppController.sharedInstance.loggedInUser?.id else {
            AppUtils.showLoginMessage(viewController: self, storyboard: UIStoryboard(name: "Main", bundle: nil), handler: nil)
            return
        }
        
        dataRequest = NetworkManager.getReservations(userID: userID, dateTime: nil, completionHandler: onResponse)
    }
    
    func openDetailActivity(model: AppoinmentModel) -> AppointmentDetailVC  {
        let controller = AppointmentDetailVC()
        controller.appointmentModel = model
        self.navigationController?.pushViewController(controller, animated: true)
        return controller
    }
}

class CalendarAppointmentCell: BaseTableViewCell {
    @IBOutlet weak var shopNameLabel : UILabel!
    @IBOutlet weak var stylistNameLabel : UILabel!
    @IBOutlet weak var appoinmentDescriptionLabel : UILabel!
    @IBOutlet weak var statusLabel : UILabel!
    @IBOutlet weak var cancelButton : UIButton!
    
    override func awakeFromNib() {
        setGestureRecognizer(senders: cancelButton)
    }
    
    func setCancelButtonVisibility(statusId: Int?, reservedDate: String?, reservedTimingFrom: String?) {
        guard let statusId = statusId, let reservedDate = reservedDate, let reservedTimingFrom = reservedTimingFrom, !reservedDate.isEmpty, !reservedTimingFrom.isEmpty else {
            cancelButton.fd_collapsed = true
            cancelButton.isHidden = true
            return
        }
        
        guard statusId == AppoinmentModel.APPOINMENT_CONFIRMED || statusId == AppoinmentModel.APPOINMENT_PENDING else {
            cancelButton.fd_collapsed = true
            cancelButton.isHidden = true
            return
        }
        
        let index = reservedDate.index(reservedDate.startIndex, offsetBy: 10)
        let dateStrOnly = reservedDate.substring(to: index)
        let dateAndTimeStr = dateStrOnly + " " + reservedTimingFrom
        
        guard let reservedDateWithTime = dateAndTimeStr.date(fromFormat: "yyyy-MM-dd hh:mm aa"), reservedDateWithTime.compare(Date()) == .orderedDescending else {
            cancelButton.fd_collapsed = true
            cancelButton.isHidden = true
            return
        }
        
        cancelButton.fd_collapsed = false
        cancelButton.isHidden = false
    }
    
    func setStatus(statusId: Int?) {
        guard let statusId = statusId else {
            self.statusLabel.text = nil
            return
        }
        
        let status: String
        let statusColor: UIColor
        switch statusId {
        case AppoinmentModel.APPOINMENT_CANCELLED_BY_SHOP:
            status = "cancelledbybarber".localized()
            statusColor = UIColor.COLfd8080()
            break
        case AppoinmentModel.APPOINMENT_PENDING:
            status = "pending".localized()
            statusColor = UIColor.COL47d9bf()
            break
        case AppoinmentModel.APPOINMENT_CONFIRMED:
            status = "confirmed".localized()
            statusColor = UIColor.COLffa800()
            break
        case AppoinmentModel.APPOINMENT_CANCELLED_BY_USER, AppoinmentModel.APPOINMENT_CANCELLATION_APPROVED:
            status = "cancelled".localized()
            statusColor = UIColor.COLfd8080()
            break
        case AppoinmentModel.APPOINMENT_CONFIRMED_NOT_ATTEND:
            status = "notAttend".localized()
            statusColor = UIColor.COLfd8080()
            break
        case AppoinmentModel.APPOINMENT_COMPLETED:
            status = "completed".localized()
            statusColor = UIColor.COLffa800()
            break
        case AppoinmentModel.APPOINMENT_AUTO_CANCELLED:
            status = "autocancelled".localized()
            statusColor = UIColor.COLfd8080()
            break
        default:
            status = ""
            statusColor = UIColor.black
            break
        }
        self.statusLabel.text = status
        self.statusLabel.textColor = statusColor
    }
}
