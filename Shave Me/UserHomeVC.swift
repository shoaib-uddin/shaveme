//
//  UserHomeVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import SWRevealViewController
import ImageSlideshow
import Alamofire
import BadgeSwift
import SearchTextField
import MZFormSheetPresentationController

class UserHomeVC: BaseSideMenuViewController, ViewControllerInterationProtocol, UITextFieldDelegate {
    
    @IBOutlet weak var notificationsLabel: BadgeSwift!
    @IBOutlet weak var autoCompleteTextField: SearchTextField!
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    private var autoSuggestionsDataRequest: DataRequest?
    
    internal var pushMessage: PushMessageModel?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting title logo
        let image = UIImageView(image: UIImage(named: "titlelogo"))
        image.contentMode = .scaleAspectFit
        image.frame.size.height = 40
        self.navigationItem.titleView = image
        
        if let baseModel = AppController.sharedInstance.cachedHomeBannerModel, let homeBannerArray = AppController.sharedInstance.cachedHomeBannerModel?.Banner, homeBannerArray.count > 0 {
            var imageSources = [AlamofireSource]()
            let baseURL = baseModel.baseUrl!
            
            for model in homeBannerArray {
                imageSources.append(AlamofireSource(urlString: baseURL + model.image!)!)
            }
            
            imageSlideShow.setImageInputs(imageSources)
            imageSlideShow.contentScaleMode = .scaleAspectFill
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickHomeBanner(sender:)))
            imageSlideShow.addGestureRecognizer(tapGesture)
            imageSlideShow.slideshowInterval = 5
        }
        
        autoCompleteTextField.theme.bgColor = UIColor.white
        autoCompleteTextField.userStoppedTypingHandler = {
            if let text = self.autoCompleteTextField.text {
                if text.characters.count > 1 {
                    // Show the loading indicator
                    self.autoCompleteTextField.showLoadingIndicator()
                    
                    if !text.isEmpty && text.characters.count > 1 {
                        if let dataTask = self.autoSuggestionsDataRequest {
                            dataTask.cancel()
                        }
                        self.autoSuggestionsDataRequest = NetworkManager.getSuggestions(query: text, completionHandler: self.onResponse)
                    }
                }
            }
        }
        
        self.autoCompleteTextField.delegate = self
        
        if MyUserDefaults.getShowHelpScreen() {
            self.navigationController?.pushViewController(HelpVC(), animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadNotificationLabelVisibility()
        
        if let pushMessage = self.pushMessage, pushMessage.statusID == AppoinmentModel.STANDALONE_PUSH_MESSAGE {
            let alert = UIAlertController(title: "alert".localized(), message: pushMessage.message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "okay".localized(), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if let id = AppController.sharedInstance.loggedInUser?.id {
            _ = NetworkManager.getReservations(userID: id, dateTime: nil, completionHandler: onResponse)
            
            if let pushMessage = self.pushMessage, pushMessage.statusID != AppoinmentModel.APPOINMENT_COMPLETED, pushMessage.statusID != AppoinmentModel.STANDALONE_PUSH_MESSAGE {
                let alert = UIAlertController(title: "alert".localized(), message: pushMessage.message, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "showDetails".localized(), style: .default, handler: { _ in
                    let controller = AppointmentDetailVC()
                    controller.appointmentID = self.pushMessage?.id
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.pushMessage = nil
                }))
                alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in self.pushMessage = nil }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Set empty filter
        self.autoCompleteTextField.filterStrings([])
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_SEARCH_SUGGESTIONS:
                if self.isVisible, let result = Mapper<RequestResult>().map(JSONObject: response.value), let strings = result.value as? [String]? {
                    // Set new items to filter
                    self.autoCompleteTextField.filterStrings(strings!)
                }
                
                // Hide loading indicator
                self.autoCompleteTextField.stopLoadingIndicator()
            case ServiceUtils.GET_RESERVATION_API:
                let models = AppoinmentModel.filterAppointments(response: response.value)
                let upcomingAppointments = AppoinmentModel.filterUpcomingAppointments(models: models)
                let count = upcomingAppointments.map({ appointment -> Int in
                    let id = String(describing: appointment.id ?? 0)
                    return MyUserDefaults.getDefaults().bool(forKey: "SeenHomeNotifications" + id) ? 0 : 1
                }).reduce(0, +)
                self.reloadNotificationLabelVisibility(count: count)
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .userLogin {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: UserLoginVC.storyBoardID) as! UserLoginVC
            self.navigationController?.pushViewController(controller, animated: true)
        } else if interactionType == .openAppointmentDetailVC, let model = data as? AppoinmentModel {
            let frontViewController = AppointmentDetailVC()
            frontViewController.appointmentModel = model
            self.navigationController?.pushViewController(frontViewController, animated: true)
        }
    }
    
    @IBAction func onClickNotifications(_ sender: Any) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        let controller = self.storyboard!.instantiateViewController(withIdentifier: UpcomingAppointmentsVC.storyBoardID) as! UpcomingAppointmentsVC
        controller.delegate = self
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: controller)
        formSheetController.presentationController?.contentViewSize = CGSize(width: screenWidth * 0.9, height: screenHeight * 0.5);
        formSheetController.interactivePanGestureDismissalDirection = MZFormSheetPanGestureDismissDirection.all
        self.present(formSheetController, animated: true, completion: nil)
        
        self.reloadNotificationLabelVisibility()
    }
    
    @IBAction func onClickSearch(_ sender: Any) {
        if let text = self.autoCompleteTextField.text, text.characters.count > 2 {
            onSearch(query: text)
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "minumum_3_characters_to_search_message".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = self.autoCompleteTextField.text, text.characters.count > 2 {
            onSearch(query: text)
            return true
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "minumum_3_characters_to_search_message".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return false
        }
    }
    
    @IBAction func onClickShowAllShops(_ sender: Any) {
        onSearch(query: "")
    }
    
    @IBAction func onClickNearMe(_ sender: Any) {
        self.navigationController?.pushViewController(MapSearchVC(), animated: true)
    }
    
    // This method is called when a tap is recognized on imageSlideShow
    func onClickHomeBanner(sender: UITapGestureRecognizer) {
        if KeyboardStateListener.shared.isVisible {
            self.autoCompleteTextField.resignFirstResponder()
        } else if let baseModel = AppController.sharedInstance.cachedHomeBannerModel, imageSlideShow.pageControl.numberOfPages > 0 {
            let model = baseModel.Banner?[imageSlideShow.pageControl.currentPage];
            if model?.urltype == BannerModel.URL_TYPE_SHOP {
                // Move to next page
                let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: BarberShopDetailsVC.storyBoardID) as! BarberShopDetailsVC
                frontViewController.shopID = model?.barberId
                self.navigationController?.pushViewController(frontViewController, animated: true)
            } else if let url = model?.urlLink {
                UIApplication.shared.open(NSURL(string: url) as! URL, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - Utility Methods

    func onSearch(query: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: BarberShopListingsVC.storyBoardID) as! BarberShopListingsVC
        controller.mTitle = "searchresult".localized()
        controller.searchType = SearchListings.SEARCH_BY_NAME
        controller.searchListingModel = ShopListingSearchModel(name: query)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func reloadNotificationLabelVisibility(count: Int = 0) {
        notificationsLabel.text = String(describing: count)
        notificationsLabel.isHidden = count <= 0
    }
}
