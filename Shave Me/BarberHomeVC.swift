//
//  BarberHomeVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import SWRevealViewController
import Alamofire
import MZFormSheetPresentationController
import HCSStarRatingView
import ESPullToRefresh

class BarberHomeVC: BaseSideMenuViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var disableBarberButton: UIButton!
    
    fileprivate var sectionDataArray: [SectionData<BarberAppoinmentModel>]?
    fileprivate var timer: Timer?
    
    internal var pushMessage: PushMessageModel?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        header.loadingDescription = header.loadingDescription.localized()
        header.releaseToRefreshDescription = header.releaseToRefreshDescription.localized()
        header.pullToRefreshDescription = header.pullToRefreshDescription.localized()
        
        _ = self.tableView.es_addPullToRefresh(animator: header) {
            [weak self] in
            self?.refreshRequests()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let barber = AppController.sharedInstance.loggedInBarber {
            self.showProgressHUD()
            
            statusLabel.isHidden = true
            disableBarberButton.isHidden = false
            
            _ = NetworkManager.getBarberReservations(barberID: barber.barberShopId, completionHandler: onResponse)
            
            // Schedule timer for autorefresh
            timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.refreshRequests), userInfo: nil, repeats: true);
            
            checkPushNotifications()
        } else {
            tableView.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "pleaseloginbarber".localized() + " " + "clickherelogin".localized()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        /// Set ignore footer or not
        self.tableView.es_stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBERRESERVATION_API:
                let filteredReservationModels = BarberAppoinmentModel.filterAppointments(response: response.value)
                let reservationModels = BarberAppoinmentModel.filterUpcomingAppointments(models: filteredReservationModels)
                let sortedUpcomingModels = BarberAppoinmentModel.sort(models: reservationModels)
                
                self.sectionDataArray = []
                var cancelledByUserModels = [BarberAppoinmentModel]()
                var confirmedModels = [BarberAppoinmentModel]()
                
                for item in sortedUpcomingModels {
                    if item.statusId == AppoinmentModel.APPOINMENT_CANCELLED_BY_USER {
                        cancelledByUserModels.append(item)
                    } else if item.statusId == AppoinmentModel.APPOINMENT_CONFIRMED {
                        confirmedModels.append(item)
                    }
                }
                
                if !cancelledByUserModels.isEmpty {
                    self.sectionDataArray?.append(SectionData<BarberAppoinmentModel>(title: "cancellationrequest".localized(), models: cancelledByUserModels))
                }
                
                if !confirmedModels.isEmpty {
                    self.sectionDataArray?.append(SectionData<BarberAppoinmentModel>(title: "confirmedrequest".localized(), models: confirmedModels))
                }
                
                if sectionDataArray!.isEmpty {
                    statusLabel.isHidden = false
                    statusLabel.text = "noitemsfound".localized()
                } else {
                    tableView.isHidden = false
                }
                
                self.tableView.reloadData()
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickStatus(_ sender: Any) {
        if AppController.sharedInstance.loggedInBarber == nil {
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: BarberLoginVC.storyBoardID) as! BarberLoginVC
            self.navigationController?.pushViewController(frontViewController, animated: true)
        }
    }
    
    @IBAction func onClickDisableBarber(_ sender: Any) {
        let controller = ImmediateBarberDisableVC()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Tableview Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionDataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionDataArray![section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let color: UIColor
        
        switch self.sectionDataArray![section].title {
        case "recentrequest".localized():
            color = UIColor.COL47d9bf()
        case "cancellationrequest".localized():
            color = UIColor.COLfd8080()
        case "confirmedrequest".localized():
            color = UIColor.COLffa800()
        default:
            color = UIColor.COL47d9bf()
        }
        
        view.tintColor = color
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionDataArray?[section].numberOfItems ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:BarberReservationCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! BarberReservationCell
        let model = self.sectionDataArray![indexPath.section][indexPath.row]
        
        cell.userNameLabel.text = model.userName
        if let reservedDate = model.getReservedDate(), let reservedTimeFrom = model.reservedTimingFrom {
            cell.timeLabel.text = reservedDate.string(fromFormat: "dd-MMM-yyyy") + " " + "AT".localized() + " " + reservedTimeFrom
        } else {
            cell.timeLabel.text = nil
        }
        
        let color: UIColor
        
        switch model.statusId ?? AppoinmentModel.APPOINMENT_CONFIRMED {
        case AppoinmentModel.APPOINMENT_PENDING:
            color = UIColor.COL47d9bf()
        case AppoinmentModel.APPOINMENT_CANCELLED_BY_USER:
            color = UIColor.COLfd8080()
        case AppoinmentModel.APPOINMENT_CONFIRMED:
            color = UIColor.COLffa800()
        default:
            color = UIColor.COL47d9bf()
        }
        
        cell.stylistNameLabel.text = model.stylistName
        if let stylistNameBG = cell.stylistNameLabel.superview {
            stylistNameBG.layer.cornerRadius = 5
            stylistNameBG.layer.masksToBounds = true
            stylistNameBG.backgroundColor = color
        }
        cell.ratingView.value = CGFloat(model.rating ?? 0)
        
        cell.profileImageView.makeCircular(borderWidth: 5, borderColor: color)
        if let profilePicStr = model.userProfilePic, let url = URL(string: profilePicStr) {
            cell.profileImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "nouserpic"))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = self.sectionDataArray![indexPath.section][indexPath.row]
        
        let frontViewController = BarberAppoinmentDetailVC()
        frontViewController.appointmentModel = model
        self.navigationController?.pushViewController(frontViewController, animated: true)
    }
    
    // MARK: - Utility Methods
    
    func refreshRequests() {
        if let shopID = AppController.sharedInstance.loggedInBarber?.barberShopId {
            _ = NetworkManager.getBarberReservations(barberID: shopID, completionHandler: onResponse)
        }
    }
    
    func checkPushNotifications() {
        guard let pushMessage = self.pushMessage, let barber = AppController.sharedInstance.loggedInBarber else {
            return
        }
        
        if pushMessage.statusID == AppoinmentModel.STANDALONE_PUSH_MESSAGE {
            let alert = UIAlertController(title: "alert".localized(), message: pushMessage.message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "okay".localized(), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if pushMessage.statusID != AppoinmentModel.APPOINMENT_COMPLETED {
            let alert = UIAlertController(title: "alert".localized(), message: pushMessage.message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "showDetails".localized(), style: .default, handler: { _ in
                let controller = BarberAppoinmentDetailVC()
                controller.appointmentID = self.pushMessage?.id
                self.navigationController?.pushViewController(controller, animated: true)
                self.pushMessage = nil
            }))
            alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in self.pushMessage = nil }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.pushMessage = nil
            
            _ = NetworkManager.getBarberReservations(barberID: barber.barberShopId, completionHandler: { (_, response) in
                if response.status?.code == RequestStatus.CODE_OK {
                    let models = BarberAppoinmentModel.filterAppointments(response: response.value)
                    for item in models {
                        if item.id == pushMessage.id {                            
                            let controller = RateUserVC()
                            controller.model = item
                            controller.isRateUser = false
                            AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.95, HeightMultiplier: 0.65)
                            return
                        }
                    }
                }
            })
        }
    }
}

class BarberReservationCell: UITableViewCell {
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var stylistNameLabel : UILabel!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var ratingView: HCSStarRatingView!
}
