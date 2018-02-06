//
//  SideMenuVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import SWRevealViewController

class SideMenuVC: MirroringViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Date for side menu
    private static let UserLoggedInSectionCount = 3
    private static let BarberLoggedInSectionCount = 4
    private static let NeitherLoggedInSectionCount = 3
    
    static let loggedInUserRowsInEachSection: [[String]] = [
        ["menu_home", "menu_featured_shops", "menu_quick_search", "menu_advanced_search", "menu_recommend_a_shop", "menu_contact_us"],
        ["menu_logout", "menu_settings", "menu_my_appointments", "menu_my_favorites", "menu_my_profile"],
        ["menu_barber", "menu_terms", "menu_help"],
        ]
    
    static let loggedInBarberRowsInEachSection: [[String]] = [
        ["menu_home", "menu_appointments", "menu_report"],
        ["menu_manage_stylist", "menu_manage_gallery", "menu_shop_details"],
        ["menu_request_for_featured"], ["menu_logout"]
    ]
    
    static let NeitherloggedInRowsInEachSection: [[String]] = [
        ["menu_home", "menu_featured_shops", "menu_quick_search", "menu_advanced_search", "menu_recommend_a_shop", "menu_contact_us"],
        ["menu_login", "menu_register", "menu_my_appointments", "menu_my_favorites"],
        ["menu_barber", "menu_terms", "menu_help"],
        ]
    
    var sectionCount = 0
    var selectedRows = [[String]]()
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Reload
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }
    
    // MARK: - Click and Callback Methods

    func onClickTableViewItem(title: String) {
        let revealController = self.revealViewController()
        var controllerNameToOpen = UserHomeVC.storyBoardID
        let isBarberLogin = AppController.sharedInstance.loggedInBarber != nil
        var shouldResetBacktrack = false
        var controller: UIViewController?
        let previouslyOpenedScreen = revealController?.frontViewController.childViewControllers.last?.storyBoardID ?? ""
        
        switch title {
        case "menu_home":
            controllerNameToOpen = isBarberLogin ? BarberHomeVC.storyBoardID : UserHomeVC.storyBoardID
            shouldResetBacktrack = true
        case "menu_featured_shops":
            controllerNameToOpen = FeaturedShopListingsVC.storyBoardID
        case "menu_quick_search":
            controllerNameToOpen = MapSearchVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : MapSearchVC()
        case "menu_advanced_search":
            controllerNameToOpen = AdvancedSearchVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : AdvancedSearchVC()
        case "menu_contact_us":
            controllerNameToOpen = ContactUsVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : ContactUsVC()
        case "menu_settings":
            controllerNameToOpen = SettingsVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : SettingsVC()
        case "menu_my_appointments":
            controllerNameToOpen = MyAppointmentsVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : MyAppointmentsVC()
        case "menu_appointments":
            controllerNameToOpen = BarberAppointmentsVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : BarberAppointmentsVC()
        case "menu_my_favorites":
            controllerNameToOpen = FavoriteShopListingsVC.storyBoardID
        case "menu_barber":
            controllerNameToOpen = BarberHomeVC.storyBoardID
        case "menu_terms":
            controllerNameToOpen = TermsAndConditionsVC.storyBoardID
        case "menu_help":
            controllerNameToOpen = HelpVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : HelpVC()
        case "menu_report":
            controllerNameToOpen = ReportVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : ReportVC()
        case "menu_manage_stylist":
            controllerNameToOpen = ManageBarberVC.storyBoardID
        case "menu_manage_gallery":
            controllerNameToOpen = BarberGalleryVC.storyBoardID
        case "menu_shop_details":
            controllerNameToOpen = UpdateShopDetailsVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : UpdateShopDetailsVC()
        case "menu_request_for_featured":
            controllerNameToOpen = FeaturingRequestVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : FeaturingRequestVC()
        case "menu_login":
            controllerNameToOpen = UserLoginVC.storyBoardID
        case "menu_register":
            controllerNameToOpen = UserRegisterationVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : UserRegisterationVC()
        case "menu_logout":
            if AppController.sharedInstance.loggedInUser != nil {
                DBFavorite.deleteAll()
            }
            
            AppController.sharedInstance.loggedInUser = nil
            AppController.sharedInstance.loggedInBarber = nil
            controllerNameToOpen = UserHomeVC.storyBoardID
            shouldResetBacktrack = true
            if let token = AppController.sharedInstance.pushNotificationsDeviceToken {
                _ = NetworkManager.logout(token: token, completionHandler: { (_, _) in
                    print("User logged out successfully")
                })
            }
        case "menu_recommend_a_shop":
            controllerNameToOpen = RecommendationVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : RecommendationVC()
        case "menu_my_profile":
            controllerNameToOpen = UserProfileVC.storyBoardID
            controller = controllerNameToOpen == previouslyOpenedScreen ? nil : UserProfileVC()
        default:
            break
        }
        
        if previouslyOpenedScreen != controllerNameToOpen {
            
            if controller == nil {
                controller = self.storyboard?.instantiateViewController(withIdentifier: controllerNameToOpen)
            }
            
            if shouldResetBacktrack {
                let nav = UINavigationController.init(rootViewController: controller!)
                revealController?.setFront(nav, animated:false)
            } else {
                (revealController?.frontViewController as? UINavigationController)?.pushViewController(controller!, animated: true)
            }
        }
        
        if AppController.sharedInstance.language == "en" {
            revealController?.rightRevealToggle(animated: true)
        } else {
            revealController?.revealToggle(true)
        }
    }
    
    @IBAction func onClickSwitchLanguage(_ sender: Any) {
        if AppController.sharedInstance.language == "ar" {
            AppController.sharedInstance.language = "en"
        } else {
            AppController.sharedInstance.language = "ar"
        }
        
        if let user = AppController.sharedInstance.loggedInUser {
            let userModel = UserModel()
            userModel.id = user.id
            userModel.language = AppController.sharedInstance.language
            userModel.sendAlerts = user.sendAlerts
            userModel.calender = user.calender
            userModel.displayPic = user.displayPic
            userModel.language = AppController.sharedInstance.language
            
            _ = NetworkManager.updateRegisteration(userID: user.id, model: userModel, completionHandler: { _, _ in
                print("Language switched")
            })
        }
        
        AppUtils.onLanguageChange()
        let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: "SplashVCSBID")
        switchLanguage(viewController: frontViewController!)
    }
    
    // MARK: - Tableview Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedRows[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.5
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.tintColor = UIColor.COL15b599()
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:SideMenuCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! SideMenuCell
        cell.selectionStyle = .none
        
        // Fetching text
        let title = selectedRows[indexPath.section][indexPath.row]
        
        // set the text from the data model
        cell.label?.text = title.localized()
        cell.mImageView.image = SideMenuVC.getRespectiveImageName(title: title)
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onClickTableViewItem(title: selectedRows[indexPath.section][indexPath.row])
    }
    
    // MARK: - Utility Methods
    
    func reload() {
        if AppController.sharedInstance.loggedInBarber != nil {
            sectionCount = SideMenuVC.BarberLoggedInSectionCount
            selectedRows = SideMenuVC.loggedInBarberRowsInEachSection
        } else if AppController.sharedInstance.loggedInUser != nil {
            sectionCount = SideMenuVC.UserLoggedInSectionCount
            selectedRows = SideMenuVC.loggedInUserRowsInEachSection
        } else {
            sectionCount = SideMenuVC.NeitherLoggedInSectionCount
            selectedRows = SideMenuVC.NeitherloggedInRowsInEachSection
        }
        self.tableView.reloadData()
    }
    
    static func getRespectiveImageName(title: String) -> UIImage {
        var image = #imageLiteral(resourceName: "ic_help")
        
        switch title {
        case "menu_home":
            image = #imageLiteral(resourceName: "ic_home")
        case "menu_featured_shops":
            image = #imageLiteral(resourceName: "ic_featured_shop")
        case "menu_quick_search":
            image = #imageLiteral(resourceName: "ic_quick_search")
        case "menu_advanced_search":
            image = #imageLiteral(resourceName: "ic_advanced_search")
        case "menu_contact_us":
            image = #imageLiteral(resourceName: "ic_contact")
        case "menu_settings":
            image = #imageLiteral(resourceName: "ic_settings")
        case "menu_my_appointments", "menu_appointments":
            image = #imageLiteral(resourceName: "ic_appointment")
        case "menu_my_favorites":
            image = #imageLiteral(resourceName: "ic_my_favourites")
        case "menu_barber":
            image = #imageLiteral(resourceName: "ic_barber")
        case "menu_terms":
            image = #imageLiteral(resourceName: "ic_terms")
        case "menu_help":
            image = #imageLiteral(resourceName: "ic_help")
        case "menu_report":
            image = #imageLiteral(resourceName: "ic_report")
        case "menu_manage_stylist":
            image = #imageLiteral(resourceName: "ic_manage_stylist")
        case "menu_manage_gallery":
            image = #imageLiteral(resourceName: "ic_gallery")
        case "menu_shop_details":
            image = #imageLiteral(resourceName: "ic_shop_detail")
        case "menu_request_for_featured":
            image = #imageLiteral(resourceName: "ic_request_featured")
        case "menu_login":
            image = #imageLiteral(resourceName: "ic_login")
        case "menu_register":
            image = #imageLiteral(resourceName: "ic_register")
        case "menu_logout":
            image = #imageLiteral(resourceName: "ic_logout")
        case "menu_recommend_a_shop":
            image = #imageLiteral(resourceName: "ic_recommended")
        case "menu_my_profile":
            image = #imageLiteral(resourceName: "ic_profile")
        default:
            image = #imageLiteral(resourceName: "ic_help")
        }
        return image
    }
}

class SideMenuCell: UITableViewCell {
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var mImageView : UIImageView!
}
