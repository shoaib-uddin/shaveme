//
//  BarberAppoinmentDetailVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/17/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import HCSStarRatingView
import ObjectMapper

class BarberAppoinmentDetailVC: BaseSideMenuViewController {
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    var appointmentModel: BarberAppoinmentModel?
    var appointmentID: Int?
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var stylistLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "appoinment".localized()
        
        if self.appointmentModel != nil {
            loadModel()
        } else if let appointmentID = self.appointmentID {
            self.showProgressHUD()
            
            _ = NetworkManager.getBarberReservation(reservationID: appointmentID, completionHandler: onAppointmentResponse)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
        setStatus()
    }
    
    override func onPushNotificationReceived(notification: NSNotification) {
        super.onPushNotificationReceived(notification: notification)
        
        guard AppController.sharedInstance.loggedInBarber != nil else {
            return
        }
        
        if let userInfo = notification.userInfo {
            let pushMessage = PushMessageModel(userInfo: userInfo)
            
            if pushMessage.statusID != AppoinmentModel.STANDALONE_PUSH_MESSAGE {
                
                self.appointmentID = pushMessage.id
                
                self.showProgressHUD()
                
                _ = NetworkManager.getBarberReservation(reservationID: appointmentID!, completionHandler: onAppointmentResponse)
            }
        }
    }
    
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBERRESERVATION_API:
                let models = BarberAppoinmentModel.filterAppointments(response: response.value)
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
    
    func onAppointmentResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBERRESERVATION_API:
                if let model = Mapper<BarberAppoinmentModel>().map(JSONObject: response.value), model.id != 0 {
                    self.appointmentModel = model
                    loadModel()
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "Error parsing response.", buttonTitle: "okay".localized(), viewController: self, handler: nil)
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
            
            let cancelModel = CancelReservationModel(id: model.id!, statusId: AppoinmentModel.APPOINMENT_CANCELLED_BY_SHOP, userId: AppController.sharedInstance.loggedInBarber?.id ?? 0)
            _ = NetworkManager.updateReservation(reservationID: model.id!, reservationModel: cancelModel, completionHandler: { (methodName, response) in
                
                self.hideProgressHUD()
                if response.status?.code == RequestStatus.CODE_OK, let cancelModel = Mapper<CancelReservationModel>().map(JSONObject: response.value) {
                    AppUtils.showMessage(title: "alert".localized(), message: "updatedSuccessfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                    
                    model.statusId = cancelModel.statusId
                    
                    self.setCancelButtonVisibility()
                    self.setReviewButtonVisibility()
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
    
    @IBAction func onClickReviewButton(_ sender: UIButton?) {
        guard let model = self.appointmentModel else {
            return
        }
        
        let controller = RateUserVC()
        controller.model = model
        controller.isRateUser = true
        AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.95, HeightMultiplier: 0.65)
    }
    
    // MARK: - Utility Methods
    
    func loadModel() {
        guard let model = self.appointmentModel else {
            return
        }
        
        setStatus()
        
        if let profilePicStr = model.userProfilePic, let url = URL(string: profilePicStr) {
            self.profileImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "nouserpic"))
        }
        
        self.userNameLabel.text = model.userName
        self.stylistLabel.text = model.stylistName
        self.dateLabel.text = model.getReservedDate()?.string(fromFormat: "EEE, MMM d, yyyy")
        let appDescription = (model.reservedTimingFrom ?? "") + " - " + (model.reservedTimingTo ?? "")
        self.timeLabel.text = appDescription + ", " + String(describing: Int(model.servicesDuration ?? 0)) + " " + "mins".localized()
        self.ratingView.value = CGFloat(model.rating ?? 0)
        self.servicesLabel.text = model.Services!.map({ $0.name }).joined(separator: ", ")
        setCancelButtonVisibility()
        setReviewButtonVisibility()
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
    
    func setReviewButtonVisibility() {
        guard let statusId = appointmentModel?.statusId, let reservedDate = appointmentModel?.reservedDate, let reservedTimingTo = appointmentModel?.reservedTimingTo, !reservedDate.isEmpty, !reservedTimingTo.isEmpty else {
            reviewButton.isHidden = true
            return
        }
        
        guard self.cancelButton.isHidden else {
            self.reviewButton.isHidden = true
            return
        }
        
        if statusId == AppoinmentModel.APPOINMENT_CONFIRMED  {
            let index = reservedDate.index(reservedDate.startIndex, offsetBy: 10)
            let dateStrOnly = reservedDate.substring(to: index)
            let dateAndTimeStr = dateStrOnly + " " + reservedTimingTo
            
            if let reservedDateWithTime = dateAndTimeStr.date(fromFormat: "yyyy-MM-dd hh:mm aa"), reservedDateWithTime.compare(Date()) == .orderedDescending {
                reviewButton.isHidden = false
            } else {
                reviewButton.isHidden = true
            }
            
            return
        }
        
        self.reviewButton.isHidden = false
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
        
        self.profileImageView.makeCircular(borderWidth: 5, borderColor: statusColor)
    }
}
