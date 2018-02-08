//
//  UpdateShopDetailsVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/23/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import ActionSheetPicker_3_0
import GooglePlacePicker

class UpdateShopDetailsVC: BaseSideMenuViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ViewControllerInterationProtocol {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var shopNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var selectedEmiratesLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var selectedServicesLabel: UILabel!
    @IBOutlet weak var selectedFacilitiesLabel: UILabel!
    @IBOutlet weak var timingsView: TimingView!
    
    fileprivate var pictureBase64String: String?
    fileprivate var updateShopModel: UpdateShopModel?
    
    private var selectedServices = [Int : SyncServiceModel]()
    
    var emiratePicker: ActionSheetStringPicker?

    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "shopdetails".localized()
        
        self.hideKeyboardOnTap()
        
        self.showProgressHUD()
        _ = NetworkManager.getBarberUserDetails(barberID: AppController.sharedInstance.loggedInBarber!.id!, completionHandler: onResponse)
        
        // Mapping all the click callbacks
        AppUtils.setGestureRecognizers(senders: mImageView, locationView, selectedEmiratesLabel, target: self, action: #selector(onClickCallback(_:)))
        
        self.shopNameTextField.delegate = self
        self.addressTextField.delegate = self
        self.streetTextField.delegate = self
        self.areaTextField.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    // MARK: - Click and Callback Methods

    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBER_USER_DETAILS_API:
                if let array = Mapper<BarberLoginModel>().mapArray(JSONObject: response.value), let barberModel = array.first, barberModel.id! > 0 {
                    AppController.sharedInstance.loggedInUser = nil
                    AppController.sharedInstance.loggedInBarber = barberModel
                    
                    self.updateShopModel = UpdateShopModel(object: barberModel)
                    
                    timingsView._viewController = self
                    
                    if self.updateShopModel?.Availability == nil {
                       self.updateShopModel?.Availability? = []
                    }
                    
                    timingsView.loadModel(availability: self.updateShopModel!.Availability!)
                    
                    self.loadShopDetails()
                }
            case ServiceUtils.POST_BARBER_DETAILS_API:
                if let array = Mapper<BarberLoginModel>().mapArray(JSONObject: response.value), let barberModel = array.first, barberModel.id! > 0 {
                    AppController.sharedInstance.loggedInUser = nil
                    AppController.sharedInstance.loggedInBarber = barberModel
                    
                    self.updateShopModel = UpdateShopModel(object: barberModel)
                    
                    timingsView._viewController = self
                    
                    if self.updateShopModel?.Availability == nil {
                        self.updateShopModel?.Availability? = []
                    }
                    
                    timingsView.loadModel(availability: self.updateShopModel!.Availability!)
                    
                    self.loadShopDetails()
                    
                    AppUtils.showMessage(title: "alert".localized(), message: "updatedSuccessfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay", viewController: self, handler: nil)
        }
    }
    
    func onClickCallback(_ sender: UITapGestureRecognizer) {
        switch sender.view! {
        case self.locationView:
            onClickLocation()
        case self.mImageView:
            onClickSelectImage()
        case self.selectedEmiratesLabel:
            onClickEmirateDropdown()
        default:
            break
        }
    }

    func onClickLocation() {
        let center = AppController.sharedInstance.currenLocation?.coordinate ?? CLLocationCoordinate2DMake(25.135597, 55.200582)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: { (place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place selected")
                return
            }
            
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place attributions \(place.attributions)")
            
            self.locationTextField.text = String(Double(place.coordinate.latitude)) + "," + String(Double(place.coordinate.longitude))
        })
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
        } else if interactionType == .selectFacilities {
            onFacilitiesSelectionChange(data: data)
        }
    }
    
    func onClickSelectImage() {
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

    @IBAction func onClickSelectServices(_ sender: UIButton) {
        var itemListArray: [BarberServiceModel] = []
        
        if let shopServices = AppController.sharedInstance.cachedServices {
            for model in shopServices {
                let barberServiceModel = BarberServiceModel(name: model.name!, serviceId: model.id!)
                if let serviceModel = ServiceModel.getModel(services: updateShopModel?.Services, id: barberServiceModel.serviceId) {
                    barberServiceModel.setServiceModel(model: serviceModel)
                }
                itemListArray.append(barberServiceModel)
            }
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: AddBarberServicesVC.storyBoardID) as! AddBarberServicesVC
            controller.originalListItems = itemListArray
            controller.delegate = self
            let navController = UINavigationController(rootViewController: controller)
            AppUtils.addViewControllerModally(originVC: self, destinationVC: navController, widthMultiplier: 0.9, HeightMultiplier: 0.8)
        }
    }
    
    @IBAction func onClickFacilitiesButton(_ sender: UIButton) {
        var itemListArray: [ListItem] = [ListItem]()
        
        if let facilities = AppController.sharedInstance.cachedFacilities {
            for model in facilities {
                if let id = model.id, !model.name.isEmpty {
                    let updatedShopFacilityModel = FacilitiesModel.getModel(facilities: updateShopModel?.Facilities, id: id)
                    let isFound = updatedShopFacilityModel != nil
                    itemListArray.append(ListItem(name: model.name, id: id, associatedFacilitiesId: updatedShopFacilityModel?.associatedFacilitiesId, isSelected: isFound))
                }
            }
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: SelectServicesVC.storyBoardID) as! SelectServicesVC
            controller.originalListItems = itemListArray
            controller.delegate = self
            controller.title = "facilitiesavialable".localized()
            controller.interactionType = .selectFacilities
            let navController = UINavigationController(rootViewController: controller)
            AppUtils.addViewControllerModally(originVC: self, destinationVC: navController, widthMultiplier: 0.9, HeightMultiplier: 0.8)
        }
    }
    
    @IBAction func onClickUpdateButton(_ sender: UIButton) {
        for item in updateShopModel!.Services! {
            if item.cost <= 0 || item.duration <= 0 {
                AppUtils.showMessage(title: "alert".localized(), message: "setcostanddurationforservices".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                return
            }
        }
        
        guard self.selectedEmiratesLabel.text != "emirates".localized() else {
            AppUtils.showMessage(title: "alert".localized(), message: "selectemirates".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        updateShopModel?.imgPath = pictureBase64String ?? ""
        updateShopModel?.shopName = shopNameTextField.text ?? ""
        updateShopModel?.Description = ""
        updateShopModel?.shopAddress = addressTextField.text ?? ""
        updateShopModel?.street = streetTextField.text ?? ""
        updateShopModel?.area = areaTextField.text ?? ""
        updateShopModel?.emirates = self.selectedEmiratesLabel.text!
        
        let locationComponents = locationTextField.text?.components(separatedBy: ",")
        
        if let latitudeStr = locationComponents?.first, let latitude = Double(latitudeStr) {
            updateShopModel?.latitude = latitude > 0 ? latitudeStr : "0"
        }
        
        if let longitudeStr = locationComponents?.last, let longitude = Double(longitudeStr) {
            updateShopModel?.longitude = longitude > 0 ? longitudeStr : "0"
        }
        
        updateShopModel?.ln = AppController.sharedInstance.language
        
        _ = NetworkManager.updateBarberDetails(model: updateShopModel!, completionHandler: onResponse)
    }

    func onServicesSelectionChange(data: Any?) {
        let itemList = data as? [BarberServiceModel]
        var formattedServiceList = ""
        if let itemList = itemList {
            let list: [ServiceModel] = itemList.flatMap({ return $0.isSelected ? ServiceModel(model: $0) : nil })
            
            updateShopModel?.Services = list
            
            formattedServiceList = list.map({ "\($0.name)" }).joined(separator: ", ")
        }
        
        selectedServicesLabel.text = formattedServiceList
        selectedServicesLabel.superview?.isHidden = formattedServiceList.isEmpty
    }
    
    func onFacilitiesSelectionChange(data: Any?) {
        self.updateShopModel?.Facilities?.removeAll()
        
        let itemList = data as? [ListItem]
        var formattedListString = ""
        if let itemList = itemList, let facilities = AppController.sharedInstance.cachedFacilities {
            for item in itemList {
                if item.isSelected {
                    if let model = FacilitiesModel.getModel(facilities: facilities, id: item.id) {
                       self.updateShopModel?.Facilities?.append(FacilitiesModel(model: model, associatedFacilitiesId: item.associatedFacilitiesId))
                    }
                }
            }
            
            formattedListString = itemList.flatMap({ $0.isSelected ? "\($0.name)" : nil }).joined(separator: ", ")
        }
        
        selectedFacilitiesLabel.text = formattedListString
        selectedFacilitiesLabel.superview?.isHidden = formattedListString.isEmpty
    }
    
    func onClickEmirateDropdown() {
        if emiratePicker == nil {
            let rows = "EmiratesArray".localizedArray()
            var initialSelection = 0
            for (index, element) in rows.enumerated() {
                if element == self.selectedEmiratesLabel.text {
                    initialSelection = index
                    break
                }
            }
            emiratePicker = ActionSheetStringPicker(title: "emirates".localized(), rows: rows, initialSelection: initialSelection, doneBlock: onEmirateItemSelected, cancel: { ActionStringCancelBlock in return }, origin: self.selectedEmiratesLabel)
        }
        emiratePicker?.show()
    }
    
    func onEmirateItemSelected(picker: ActionSheetStringPicker?, selectedIndex: Int, selectedValue: Any?) {
        self.selectedEmiratesLabel.text = selectedValue as? String
    }
    
    // MARK: - Textfield delegate methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.shopNameTextField == textField {
            self.addressTextField.becomeFirstResponder()
            return true
        } else if self.addressTextField == textField {
            self.streetTextField.becomeFirstResponder()
            return true
        } else if self.streetTextField == textField {
            self.areaTextField.becomeFirstResponder()
            return true
        } else if self.areaTextField == textField {
            self.onClickEmirateDropdown()
            return true
        } else {
            self.dismissKeyboard()
        }
        
        return false
    }

    // MARK: - Utility Methods

    func loadShopDetails() {
        guard let model = self.updateShopModel else {
            return
        }
        
        shopNameTextField.text = model.shopName
        addressTextField.text = model.shopAddress
        streetTextField.text = model.street
        areaTextField.text = model.area
        locationTextField.text = (model.latitude ?? "") + "," + (model.longitude ?? "") 
        selectedEmiratesLabel.text = model.emirates
        if let imgPath = model.imgPath, let url = URL(string: imgPath) {
            mImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "imagefetcher"))
        }
        
        if let serviceList = model.Services {
            let formattedServiceList = serviceList.flatMap({ "\($0.name)" }).joined(separator: ", ")
            selectedServicesLabel.text = formattedServiceList
            selectedServicesLabel.superview?.isHidden = serviceList.isEmpty
        }
        
        if let facilitiesList = model.Facilities {
            let formattedFacilityList = facilitiesList.flatMap({ "\($0.name)" }).joined(separator: ", ")
            selectedFacilitiesLabel.text = formattedFacilityList
            selectedFacilitiesLabel.superview?.isHidden = facilitiesList.isEmpty
        }
    }
}
