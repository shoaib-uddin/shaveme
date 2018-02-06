//
//  AddEditStylistViewController.swift
//  Shave Me
//
//  Created by NoorAli on 1/29/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import ActionSheetPicker_3_0
import KMPlaceholderTextView

class AddEditStylistViewController: BaseSideMenuViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ViewControllerInterationProtocol {
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    var addOrUpdateStylistModel: AddOrUpdateStylistModel?
    var isUpdating = false
    
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    @IBOutlet weak var selectedServicesLabel: UILabel!
    @IBOutlet weak var timingsView: TimingView!
    @IBOutlet weak var addUpdateButton: UIButton!
    
    fileprivate var pictureBase64String: String?
    
    private var selectedServices = [Int : ServiceModel]()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "stylist".localized()
        
        self.hideKeyboardOnTap()
        
        self.fullNameTextField.delegate = self
        timingsView.viewController = self
        
        if let model = addOrUpdateStylistModel {
            isUpdating = true
            
            descriptionTextView.text = model.description ?? ""
            fullNameTextField.text = model.name
            
            addUpdateButton.setTitle("updateStylist".localized(), for: .normal)
            
            if let serviceIDs = model.services?.components(separatedBy: ","), let services = AppController.sharedInstance.loggedInBarber?.Services {
                var formattedServiceList = ""
                for item in serviceIDs {
                    if let id = Int(item), let model = ServiceModel.getModel(services: services, id: id) {
                        selectedServices[id] = model
                    }
                }
                
                formattedServiceList = selectedServices.values.flatMap({ "\($0.name)" }).joined(separator: ", ")
                
                selectedServicesLabel.text = formattedServiceList
                selectedServicesLabel.superview?.isHidden = formattedServiceList.isEmpty
            }
            
            if let baseUrl = AppController.sharedInstance.loggedInBarber?.Stylist?.baseUrl, let imgPath = model.image, let url = URL(string: baseUrl + imgPath) {
                mImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "imagefetcher"))
            }
            
            if self.addOrUpdateStylistModel?.Availability == nil {
                self.addOrUpdateStylistModel?.Availability = []
            }
        } else {
            addOrUpdateStylistModel = AddOrUpdateStylistModel()
        }
        
        timingsView.loadModel(availability: addOrUpdateStylistModel!.Availability!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            if let model = Mapper<StylistArrayModel>().map(JSONObject: response.value) {
                if isUpdating {
                    if let stylistArray = AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist, let newStylist = model.Stylist?.first {
                        for (index, item) in stylistArray.enumerated() {
                            if item.stylistId == newStylist.stylistId! {
                                AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist?[index] = newStylist
                                break
                            }
                        }
                    } else {
                        AppController.sharedInstance.loggedInBarber?.Stylist = model
                    }
                } else {
                    if AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist != nil, let newStylist = model.Stylist?.first {
                        AppController.sharedInstance.loggedInBarber?.Stylist?.Stylist?.append(newStylist)
                    } else {
                        AppController.sharedInstance.loggedInBarber?.Stylist = model
                    }
                }
                
                let string = AppController.sharedInstance.loggedInBarber?.toJSONString()
                MyUserDefaults.getDefaults().set(string, forKey: MyUserDefaults.PREFS_BARBER)
                
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                AppUtils.showMessage(title: "alert".localized(), message: "ServerError".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            }
        } else if response.status?.message == "alreadyexist".localized() {
            AppUtils.showMessage(title: "alert".localized(), message: "stylistnamealreadyexists".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if let image = image {
            let scaledImage = image.resizeImage(newWidth: 1200)
            self.pictureBase64String = scaledImage?.base64EncodedString()
            
            self.mImageView.image = scaledImage
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "Incompatible format", buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .selectServices {
            onServicesSelectionChange(data: data)
        }
    }
    
    @IBAction func onClickSelectServicesButton(_ sender: UIButton) {
        var itemListArray: [ListItem] = [ListItem]()
        
        if let shopServices = AppController.sharedInstance.loggedInBarber?.Services {
            for model in shopServices {
                if !model.name.isEmpty {
                    let isFound = selectedServices[model.serviceId] != nil
                    itemListArray.append(ListItem(name: model.name, id: model.serviceId, isSelected: isFound))
                }
            }
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: SelectServicesVC.storyBoardID) as! SelectServicesVC
            controller.originalListItems = itemListArray
            controller.delegate = self
            let navController = UINavigationController(rootViewController: controller)
            AppUtils.addViewControllerModally(originVC: self, destinationVC: navController, widthMultiplier: 0.9, HeightMultiplier: 0.8)
        }
    }
    
    @IBAction func onClickAddUpdateButton(_ sender: UIButton) {
        guard let fullNameStr = fullNameTextField.text, !fullNameStr.isEmpty else {
            AppUtils.showMessage(title: "alert".localized(), message: "enterStylistName".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        self.addOrUpdateStylistModel?.userId = AppController.sharedInstance.loggedInBarber?.id
        self.addOrUpdateStylistModel?.barberId = AppController.sharedInstance.loggedInBarber?.barberShopId
        self.addOrUpdateStylistModel?.image = pictureBase64String
        self.addOrUpdateStylistModel?.name = fullNameStr
        self.addOrUpdateStylistModel?.description = descriptionTextView.text
        self.addOrUpdateStylistModel?.services = selectedServices.keys.flatMap({ String($0) }).joined(separator: ", ")
        self.addOrUpdateStylistModel?.ln = AppController.sharedInstance.language
        self.addOrUpdateStylistModel?.Availability = timingsView.originalAvailabilityModel
        
        if isUpdating {
            _ = NetworkManager.updateStylistDetails(model: self.addOrUpdateStylistModel!, completionHandler: onResponse)
        } else {
            _ = NetworkManager.postStylistDetails(model: self.addOrUpdateStylistModel!, completionHandler: onResponse)
        }
    }
    
    @IBAction func onClickPickImageView(_ sender: Any) {
        let alert = UIAlertController(title: "addphoto".localized(), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "choosefromgallery".localized(), style: .default, handler: {(action) in
            AppUtils.getImageFromPhotoLibrary(viewController: self)
        }))
        alert.addAction(UIAlertAction(title: "takephoto".localized(), style: .default, handler:  {(action) in
            AppUtils.takePhoto(viewController: self)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func onServicesSelectionChange(data: Any?) {
        let itemList = data as? [ListItem]
        var formattedServiceList = ""
        if let itemList = itemList, let services = AppController.sharedInstance.loggedInBarber?.Services {
            for item in itemList {
                if item.isSelected {
                    if selectedServices[item.id] == nil, let model = ServiceModel.getModel(services: services, id: item.id) {
                        selectedServices[item.id] = model
                    }
                } else {
                    selectedServices[item.id] = nil
                }
            }
            
            formattedServiceList = itemList.flatMap({ $0.isSelected ? "\($0.name)" : nil }).joined(separator: ", ")
        }
        
        selectedServicesLabel.text = formattedServiceList
        selectedServicesLabel.superview?.isHidden = formattedServiceList.isEmpty
    }
    
    // MARK: - Textfield delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.fullNameTextField == textField {
            self.descriptionTextView.becomeFirstResponder()
            return true
        } else {
            self.dismissKeyboard()
        }
        
        return false
    }
}
