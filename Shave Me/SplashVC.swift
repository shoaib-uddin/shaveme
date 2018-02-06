//
//  SplashVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import SWRevealViewController

class SplashVC: MirroringViewController {
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var arabicButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ifounditLabel: UILabel!
    
    fileprivate var serverCallsAvaiting: Int = 3
    
    fileprivate var pushMessage: PushMessageModel?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start listening for keyboard state
        KeyboardStateListener.shared.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SplashVC.onPushNotificationReceived(notification:)), name: NSNotification.Name.onPushMessageReceived, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppController.sharedInstance.isLanguageInitialized() {
            self.makeServerCalls()
        } else {
            englishButton.isHidden = false
            arabicButton.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.onPushMessageReceived, object: nil)
    }
    
    open func onPushNotificationReceived(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            pushMessage = PushMessageModel(userInfo: userInfo)
        }
    }

    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_SERVICES_API:
                AppController.sharedInstance.cachedServices = Mapper<SyncServiceModel>().mapArray(JSONObject: response.value)
            case ServiceUtils.GET_FACILITIES_API:
                AppController.sharedInstance.cachedFacilities = Mapper<SyncFacilitiesModel>().mapArray(JSONObject: response.value)
            case ServiceUtils.GET_HOMEBANNER_API:
                AppController.sharedInstance.cachedHomeBannerModel = Mapper<HomeBannerModel>().map(JSONObject: response.value)
            case ServiceUtils.GET_FAVORITES_API:
                _ = FavoritesModelController.parseResponse(response: response.value)
            case ServiceUtils.GET_BARBER_USER_DETAILS_API:
                if let array = Mapper<BarberLoginModel>().mapArray(JSONObject: response.value), array.count > 0, array.first!.id! > 0 {
                    AppController.sharedInstance.loggedInUser = nil
                    AppController.sharedInstance.loggedInBarber = array.first!
                }
            default:
                break
            }
        } else if response.status?.code == RequestStatus.CODE_NO_INTERNET_CONNECT {
            AppUtils.showMessage(title: "alert".localized(), message: response.status!.message!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
        
        onServerCallCompleted()
    }
    
    @IBAction func onClickEnglishButton(_ sender: UIButton) {
        AppController.sharedInstance.language = "en"
        
        onLanguageChange()
    }
    
    @IBAction func onClickArabicButton(_ sender: UIButton) {
        AppController.sharedInstance.language = "ar"
        
        onLanguageChange()
    }
    
    // MARK: - Utility Methods
    
    func onServerCallCompleted() {
        serverCallsAvaiting -= 1
        
        if serverCallsAvaiting <= 0, activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
            
            gotoNextScreen()
        }
    }
    
    func gotoNextScreen() {
        // Move to next page
        let viewControllerSBIDString = AppController.sharedInstance.loggedInBarber == nil ? UserHomeVC.storyBoardID : BarberHomeVC.storyBoardID
        
        let revealController = self.storyboard?.instantiateViewController(withIdentifier: SWRevealViewController.storyBoardID) as? SWRevealViewController
        let rearController = self.storyboard?.instantiateViewController(withIdentifier: SideMenuVC.storyBoardID)
        let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: viewControllerSBIDString)
        let navigationController = UINavigationController.init(rootViewController: frontViewController!)
        revealController?.setFront(navigationController, animated: true)
        
        if AppController.sharedInstance.language == "en" {
            revealController?.setRight(rearController, animated: true)
        } else {
            revealController?.setRear(rearController, animated: true)
        }
        
        if let pushMessageController = frontViewController as? UserHomeVC {
            pushMessageController.pushMessage = self.pushMessage
        } else if let pushMessageController = frontViewController as? BarberHomeVC {
            pushMessageController.pushMessage = self.pushMessage
        }
        
        self.present(revealController!, animated: true, completion: nil)
    }
    
    func makeServerCalls() {
        guard AppController.sharedInstance.reachability.isReachable else {
            AppUtils.showMessage(title: "alert".localized(), message: "ConnectionError".localized(), buttonTitle: "retry".localized(), viewController: self, handler: { _ in
                self.makeServerCalls()
            })
            return
        }
        
        activityIndicator.startAnimating()
        ifounditLabel.isHidden = false
        
        serverCallsAvaiting = 1
        _ = NetworkManager.getFacilities(completionHandler: onResponse)
        serverCallsAvaiting += 1
        _ = NetworkManager.getServices(completionHandler: onResponse)
        serverCallsAvaiting += 1
        _ = NetworkManager.getHomeBanner(completionHandler: onResponse)
        
        if let barber = AppController.sharedInstance.loggedInBarber {
            serverCallsAvaiting += 1
            _ = NetworkManager.getBarberUserDetails(barberID: barber.id!, completionHandler: onResponse)
        } else if let user = AppController.sharedInstance.loggedInUser {
            serverCallsAvaiting += 1
            _ = NetworkManager.getFavourites(userID: user.id, completionHandler: onResponse)
        }
        
        if AppUtils.updateDeviceDetailsForPushNotifications(completionHandler: onResponse) != nil {
            serverCallsAvaiting += 1
        }
    }
    
    func onLanguageChange() {
        AppUtils.onLanguageChange()
        
        englishButton.isHidden = true
        arabicButton.isHidden = true
        
        self.makeServerCalls()
    }
}
