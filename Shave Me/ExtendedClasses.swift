//
//  SideMenuViewController.swift
//  Shave Me
//
//  Created by NoorAli on 12/19/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import SWRevealViewController
import ObjectMapper
import FirebaseCrash

class BaseSideMenuViewController: BaseViewController, SWRevealViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure navigation bar
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.setObserver(self, selector: #selector(BaseSideMenuViewController.onPushNotificationReceived(notification:)), name: NSNotification.Name.onPushMessageReceived, object: nil)
        self.revealViewController().delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.onPushMessageReceived, object: nil)
        
        if let revealVC = self.revealViewController() {
            revealVC.frontViewController.view.viewWithTag(1000)?.removeFromSuperview()
        }
    }
    
    open func onPushNotificationReceived(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let pushMessage = PushMessageModel(userInfo: userInfo)
        
        if pushMessage.statusID == AppoinmentModel.STANDALONE_PUSH_MESSAGE {
            let alert = UIAlertController(title: "alert".localized(), message: pushMessage.message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "okay".localized(), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Either one has to be logged in to receive push notifications
        guard let navController = self.navigationController, (AppController.sharedInstance.loggedInBarber != nil || AppController.sharedInstance.loggedInUser != nil) else {
            return
        }
        
        if pushMessage.statusID != AppoinmentModel.APPOINMENT_COMPLETED {
            
            let alert = UIAlertController(title: "alert".localized(), message: pushMessage.message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "showDetails".localized(), style: .default, handler: { _ in
                if AppController.sharedInstance.loggedInBarber != nil {
                    let controller = BarberAppoinmentDetailVC()
                    controller.appointmentID = pushMessage.id
                    navController.pushViewController(controller, animated: true)
                } else if AppController.sharedInstance.loggedInUser != nil {
                    let controller = AppointmentDetailVC()
                    controller.appointmentID = pushMessage.id
                    navController.pushViewController(controller, animated: true)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else if let id = pushMessage.id, AppController.sharedInstance.loggedInBarber != nil {
            // To show user rating dialog on completion of reservation
            _ = NetworkManager.getBarberReservation(reservationID: id, completionHandler: { (_, response) in
                if response.status?.code == RequestStatus.CODE_OK, let model = Mapper<BarberAppoinmentModel>().map(JSONObject: response.value), model.id != 0 {
                    let controller = RateUserVC()
                    controller.model = model
                    controller.isRateUser = false
                    AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.95, HeightMultiplier: 0.65)
                    
                } else {
                    FIRCrashMessage("Getting reservation is found nil in base view controller")
                }
            })
        }
    }
    
    // MARK: - revealViewController Methods
    
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        let positionToCheck: FrontViewPosition = AppController.sharedInstance.language == "en" ? .leftSide : .right
        
        if position == positionToCheck {
            let lockingView = UIView(frame: self.revealViewController().frontViewController.view.frame)
            lockingView.tag = 1000
            let tapGesture = UITapGestureRecognizer(target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            tapGesture.numberOfTapsRequired = 1
            lockingView.addGestureRecognizer(tapGesture)
            self.revealViewController().frontViewController.view.addSubview(lockingView)
        } else {
            self.revealViewController().frontViewController.view.viewWithTag(1000)?.removeFromSuperview()
        }
    }
}

class BaseViewController: MirroringViewController {
    private var progressHUD: ProgressHUD?
    var isVisible = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isVisible = false
    }
    
    var isProgressing: Bool {
        return self.progressHUD != nil
    }
    
    func showProgressHUD(text: String = "Loading...".localized()) {
        self.view.isUserInteractionEnabled = false
        progressHUD = ProgressHUD(text: text)
        self.view.addSubview(progressHUD!)
    }
    
    func hideProgressHUD() {
        if let progressHUD = self.progressHUD {
            self.view.isUserInteractionEnabled = true
            progressHUD.removeFromSuperview()
            self.progressHUD = nil
        }
    }
}
