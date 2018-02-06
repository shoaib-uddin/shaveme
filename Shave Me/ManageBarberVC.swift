//
//  ManageBarberVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/29/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class ManageBarberVC: BaseSideMenuViewController, UITableViewDelegate, UITableViewDataSource, TableViewCellProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    fileprivate var dataRequest: DataRequest?
    fileprivate var models: [ManageBarberModel]?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if let _ = self.revealViewController() {
            let addIconButton = UIBarButtonItem(image: #imageLiteral(resourceName: "addicon"), style: .plain, target: self, action: #selector(onClickAddImage))
            let rightBarButtonItems = [self.navigationItem.rightBarButtonItem!, addIconButton]
            
            self.navigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeRequest()
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        dataRequest = nil
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName  {
            case ServiceUtils.GET_STYLIST_API:
                if let newModels = Mapper<ManageBarberModel>().mapArray(JSONObject: response.value), newModels.count > 0 {
                    statusLabel.isHidden = true
                    tableView.isHidden = false
                    
                    self.models = newModels
                    
                    tableView.reloadData()
                } else {
                    statusLabel.isHidden = false
                    tableView.isHidden = true
                    statusLabel.text = "noitemsfound".localized()
                }
            case "DELETE_STYLIST_REQUEST":
                self.makeRequest()
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    // MARK: - Tableview Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ManageBarberStylistCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! ManageBarberStylistCell
        let model = self.models![indexPath.row]
        
        cell.setCustomDelegateCallback(delegate: self, cellIndex: indexPath, data: model)
        
        if let thumbnailPath = model.thumbnailPath, let url = URL(string: thumbnailPath) {
            cell.mImageView.af_setImage(withURL: url, placeholderImage: AppController.sharedInstance.placeHolderImage)
        }
        
        cell.stylistNameLabel.text = model.name
        cell.currentBookingLabel.text = "currentbookings".localized() + " " + String(describing: model.currentBooking ?? 0)
        
        var availableOn = ""
        for item in model.StylistAvailability! {
            if item.day == Date().dayNumberOfWeek(), let startTime = item.startTime.date(fromFormat: "HH:mm:ss"), let endTime = item.endTime.date(fromFormat: "HH:mm:ss") {
                cell.timingLabel.text = startTime.string(fromFormat: "hh:mm aa") + " - " + endTime.string(fromFormat: "hh:mm aa")
            }
            
            if item.day == 1 {
                availableOn = availableOn + " " + "sun".localized()
            } else if item.day == 2 {
                availableOn = availableOn + " " + "mon".localized()
            } else if item.day == 3 {
                availableOn = availableOn + " " + "tue".localized()
            } else if item.day == 4 {
                availableOn = availableOn + " " + "wed".localized()
            } else if item.day == 5 {
                availableOn = availableOn + " " + "thu".localized()
            } else if item.day == 6 {
                availableOn = availableOn + " " + "fri".localized()
            } else if item.day == 7 {
                availableOn = availableOn + " " + "sat".localized()
            }
        }
        
        cell.availabilityLabel.text = "availableon".localized() + " " + availableOn
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func didClickOnCell(indexPath: IndexPath, cell: UITableViewCell, data: Any?, sender: Any) {
        let model = data as! ManageBarberModel
        let cell = cell as! ManageBarberStylistCell
        
        if sender as? UIButton == cell.editButton {
            if let stylistID = model.stylistId, let stylistModels = AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist {
                for item in stylistModels {
                    if item.stylistId == stylistID {
                        let controller = AddEditStylistViewController()
                        controller.addOrUpdateStylistModel = AddOrUpdateStylistModel(stylistModel: item)
                        self.navigationController?.pushViewController(controller, animated: true)
                        break
                    }
                }
            }
        } else if sender as? UIButton == cell.deleteButton {
            onClickDeleteStylist(stylistId: model.stylistId ?? 0)
        } else {
            onClickDisableEnableStylist(stylistId: model.stylistId ?? 0, stylistName: model.name ?? "")
        }
    }
    
    func onClickDeleteStylist(stylistId: Int) {
        let alert = UIAlertController(title: "alert".localized(), message: "deleteStylist".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "yes".localized(), style: .default, handler: { _ in
            self.showProgressHUD()
            
            self.dataRequest = NetworkManager.deleteStylist(stylistID: stylistId, completionHandler: { (methodName, response) in
                self.onResponse(methodName: "DELETE_STYLIST_REQUEST", response: response)
            })
        }))
        
        alert.addAction(UIAlertAction(title: "no".localized(), style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func onClickDisableEnableStylist(stylistId: Int, stylistName: String) {
        let disableBarberModel = DisableBarberModel(stylistId: stylistId)
        disableBarberModel.ln = AppController.sharedInstance.language
        disableBarberModel.type = "L"
        
        let controller = LongTermDisableBarberVC()
        controller.stylistName = stylistName
        controller.model = disableBarberModel
        AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.95, HeightMultiplier: 0.5)
    }
    
    func onClickAddImage() {
        let controller = AddEditStylistViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Utility Methods
    
    func makeRequest() {
        if let barberShopId = AppController.sharedInstance.loggedInBarber?.barberShopId {
            self.showProgressHUD()
            
            dataRequest = NetworkManager.getStylists(barberID: barberShopId, completionHandler: onResponse)
        }
    }
}

class ManageBarberStylistCell: BaseTableViewCell {
    @IBOutlet weak var mImageView : UIImageView!
    @IBOutlet weak var stylistNameLabel : UILabel!
    @IBOutlet weak var timingLabel : UILabel!
    @IBOutlet weak var availabilityLabel : UILabel!
    @IBOutlet weak var currentBookingLabel : UILabel!
    @IBOutlet weak var editButton : UIButton!
    @IBOutlet weak var deleteButton : UIButton!
    @IBOutlet weak var disableButton : UIButton!
    
    override func awakeFromNib() {
        mImageView.makeCircular()
        setGestureRecognizer(senders: editButton, deleteButton, disableButton)
    }
}
