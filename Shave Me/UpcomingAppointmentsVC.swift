//
//  UpcomingAppointmentsVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/13/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper

class UpcomingAppointmentsVC: MirroringViewController, UITableViewDataSource, UITableViewDelegate {
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    private var appointmentModels: [AppoinmentModel]?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //contentView.applyBorder()
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect.zero);
        self.titleLabel.text = "upcoming_appionment".localized()
        
        if let user = AppController.sharedInstance.loggedInUser {
            // Making server request
            self.activityIndicator.startAnimating()
            _ = NetworkManager.getReservations(userID: user.id, dateTime: nil, completionHandler: onResponse)
        } else {
            self.statusLabel.text = "pleaselogin".localized()
            self.statusLabel.isHidden = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickLogin(sender:)))
            statusLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.activityIndicator.stopAnimating()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_RESERVATION_API:
                let models = AppoinmentModel.filterAppointments(response: response.value)
                let upcomingModels = AppoinmentModel.filterUpcomingAppointments(models: models)
                let sortedUpcomingModels = AppoinmentModel.sort(models: upcomingModels)
                if sortedUpcomingModels.count > 0 {
                    self.tableView.isHidden = false
                    self.statusLabel.isHidden = true
                    self.appointmentModels = sortedUpcomingModels
                    self.tableView.reloadData()
                    
                    // Mark upcoming models as read
                    sortedUpcomingModels.forEach({ appointment in
                        let id = String(describing: appointment.id ?? 0)
                        MyUserDefaults.getDefaults().set(true, forKey: "SeenHomeNotifications" + id)
                    })
                } else {
                    self.tableView.isHidden = true
                    self.statusLabel.isHidden = false
                    self.statusLabel.text = "no_upcoming_appionment".localized()
                }
            default:
                break
            }
        } else {
            self.statusLabel.text = response.status?.message
        }
    }
    
    
    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // This method is called when a tap is recognized on imageSlideShow
    func onClickLogin(sender: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.onViewControllerInteractionListener(interactionType: .userLogin, data: nil, childVC: nil)
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Tableview Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointmentModels?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UpcomingAppointmentCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! UpcomingAppointmentCell
        let model = self.appointmentModels![indexPath.row]
        
        cell.titleLabel.text = model.shopName
        
        var message = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = dateFormatter.date(from: model.reservedDate!) {
            let todayDate = Date()
            let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: todayDate)!
            if Calendar.current.compare(Date(), to: date, toGranularity: .day) == .orderedSame {
                message = "Today".localized()
            } else if Calendar.current.compare(tomorrowDate, to: date, toGranularity: .day) == .orderedSame {
                message = "Tomorrow".localized()
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")

                message = dateFormatter.string(from: date)
            }
        }
        cell.messageLabel.text = message + " - " + (model.reservedTimingFrom ?? "")
        
        let status: String
        let statusColor: UIColor
        switch model.statusId! {
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
        cell.statusLabel.text = status
        cell.statusLabel.textColor = statusColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = self.appointmentModels![indexPath.row]
        
        if let delegate = delegate {
            delegate.onViewControllerInteractionListener(interactionType: .openAppointmentDetailVC, data: model, childVC: self)
        }
        self.dismiss(animated: false, completion: nil)
    }
}

class UpcomingAppointmentCell: UITableViewCell {
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var statusLabel : UILabel!
}


