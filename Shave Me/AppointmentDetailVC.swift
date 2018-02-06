//
//  AppointmentDetailVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/10/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit

class AppointmentDetailVC: BaseSideMenuViewController {

    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    var appointmentModel: AppoinmentModel?
    var appointmentID: Int?
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var stylistLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "appoinment".localized()
        
        if self.appointmentModel != nil {
            loadModel()
        } else if self.appointmentID != nil {
            self.showProgressHUD()
            
            let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
            _ = NetworkManager.getReservations(userID: userID, dateTime: nil, completionHandler: onResponse)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    override func onPushNotificationReceived(notification: NSNotification) {
        super.onPushNotificationReceived(notification: notification)
        
        guard AppController.sharedInstance.loggedInUser != nil else {
            return
        }
        
        if let userInfo = notification.userInfo {
            let pushMessage = PushMessageModel(userInfo: userInfo)
            
            if pushMessage.statusID != AppoinmentModel.STANDALONE_PUSH_MESSAGE {
                self.appointmentID = pushMessage.id
                
                self.showProgressHUD()
                
                let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
                _ = NetworkManager.getReservations(userID: userID, dateTime: nil, completionHandler: onResponse)
            }
        }

    }
    
    // MARK: - Click and Callback Methods

    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_RESERVATION_API:
                let models = AppoinmentModel.filterAppointments(response: response.value)
                for item in models {
                    if item.id == self.appointmentID {
                        self.appointmentModel = item
                        loadModel()
                        return
                    }
                }
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    
    @IBAction func onClickCancelButton(_ sender: UIButton?) {
        guard let model = self.appointmentModel else {
            return
        }
        
        let alert = UIAlertController(title: "alert".localized(), message: "cancelAppoinment".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "yes".localized(), style: .default, handler: { _ in
            self.showProgressHUD()
            
            let cancelModel = CancelReservationModel(id: model.id!, statusId: AppoinmentModel.APPOINMENT_CANCELLED_BY_USER, userId: AppController.sharedInstance.loggedInUser?.id ?? 0)
            _ = NetworkManager.updateReservation(reservationID: model.id!, reservationModel: cancelModel, completionHandler: { (methodName, response) in
                
                self.hideProgressHUD()
                if response.status?.code == RequestStatus.CODE_OK {
                    AppUtils.showMessage(title: "alert".localized(), message: "updatedSuccessfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                    
                    model.statusId = AppoinmentModel.APPOINMENT_CANCELLED_BY_USER
                    
                    self.setCancelButtonVisibility()
                    self.setStatus()
                    
                    if let delegate = self.delegate {
                        delegate.onViewControllerInteractionListener(interactionType: .appointmentCancelled, data: model, childVC: self)
                    }
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "no".localized(), style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Utility Methods
    
    func loadModel() {
        guard let model = self.appointmentModel else {
            return
        }
        
        self.shopLabel.text = model.shopName
        self.stylistLabel.text = model.stylistName
        self.dateLabel.text = model.getReservedDate()?.string(fromFormat: "EEE, MMM d, yyyy")
        let appDescription = (model.reservedTimingFrom ?? "") + " - " + (model.reservedTimingTo ?? "")
        self.timeLabel.text = appDescription + ", " + String(describing: model.servicesDuration ?? 0) + " " + "mins".localized()
        self.totalCostLabel.text = String(describing: model.servicesCost ?? 0) + " " + "aed".localized()
        self.servicesLabel.text = model.Services!.map({ $0.name }).joined(separator: ", ")
        setCancelButtonVisibility()
        setStatus()

    }
    
    func setCancelButtonVisibility() {
        guard let statusId = appointmentModel?.statusId, let reservedDate = appointmentModel?.reservedDate, let reservedTimingFrom = appointmentModel?.reservedTimingFrom, !reservedDate.isEmpty, !reservedTimingFrom.isEmpty else {
            cancelButton.isHidden = true
            return
        }
        
        guard statusId == AppoinmentModel.APPOINMENT_CONFIRMED || statusId == AppoinmentModel.APPOINMENT_PENDING else {
            cancelButton.isHidden = true
            return
        }
        
        let index = reservedDate.index(reservedDate.startIndex, offsetBy: 10)
        let dateStrOnly = reservedDate.substring(to: index)
        let dateAndTimeStr = dateStrOnly + " " + reservedTimingFrom
        
        guard let reservedDateWithTime = dateAndTimeStr.date(fromFormat: "yyyy-MM-dd hh:mm aa"), reservedDateWithTime.compare(Date()) == .orderedDescending else {
            cancelButton.isHidden = true
            return
        }
        
        cancelButton.isHidden = false
    }
    
    func setStatus() {
        guard let statusId = appointmentModel?.statusId else {
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
