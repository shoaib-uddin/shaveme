//
//  AdvancedSearchVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/9/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import TTRangeSlider
import SearchTextField
import Alamofire
import ObjectMapper

class AdvancedSearchVC: BaseSideMenuViewController, UITextFieldDelegate, ViewControllerInterationProtocol {

    private static let FROM_COST: Float = 0
    private static let TO_COST: Float = 500
    
    private static let FROM_DISTANCE: Float = 0
    private static let TO_DISTANCE: Float = 25
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var fromKMLabel: UILabel!
    @IBOutlet weak var toKMLabel: UILabel!
    @IBOutlet weak var distanceRangeSlider: TTRangeSlider!
    @IBOutlet weak var fromCostLabel: UILabel!
    @IBOutlet weak var toCostLabel: UILabel!
    @IBOutlet weak var costRangeSlider: TTRangeSlider!
    @IBOutlet weak var selectedServicesLabel: UILabel!
    @IBOutlet weak var selectedFacilitiesLabel: UILabel!

    private var autoSuggestionsDataRequest: DataRequest?

    private var selectedServices = [Int : SyncServiceModel]()
    private var selectedFacilities = [Int : SyncFacilitiesModel]()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "advancesearch".localized()
        
        searchTextField.theme.bgColor = UIColor.white
        searchTextField.userStoppedTypingHandler = {
            if let text = self.searchTextField.text {
                if text.characters.count > 1 {
                    // Show the loading indicator
                    self.searchTextField.showLoadingIndicator()
                    
                    if !text.isEmpty && text.characters.count > 1 {
                        if let dataTask = self.autoSuggestionsDataRequest {
                            dataTask.cancel()
                        }
                        self.autoSuggestionsDataRequest = NetworkManager.getSuggestions(query: text, completionHandler: self.onResponse)
                    }
                }
            }
        }
        
        self.searchTextField.delegate = self
        
        distanceRangeSlider.minValue = AdvancedSearchVC.FROM_DISTANCE
        distanceRangeSlider.maxValue = AdvancedSearchVC.TO_DISTANCE
        costRangeSlider.minValue = AdvancedSearchVC.FROM_COST
        costRangeSlider.maxValue = AdvancedSearchVC.TO_COST
        
        fromCostLabel.text = String(AdvancedSearchVC.FROM_COST) + "\n" + "costRangeText".localized()
        toCostLabel.text = String(AdvancedSearchVC.TO_COST) + "\n" + "costRangeText".localized()
        fromKMLabel.text = String(AdvancedSearchVC.FROM_DISTANCE) + "\n" + "distanceRangeText".localized()
        toKMLabel.text = String(AdvancedSearchVC.TO_DISTANCE) + "\n" + "distanceRangeText".localized()
        
        self.view.removeGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Set empty filter
        self.searchTextField.filterStrings([])
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_SEARCH_SUGGESTIONS:
                if self.isVisible, let result = Mapper<RequestResult>().map(JSONObject: response.value), let strings = result.value as? [String]? {
                    // Set new items to filter
                    self.searchTextField.filterStrings(strings!)
                }
                
                // Hide loading indicator
                self.searchTextField.stopLoadingIndicator()
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .selectServices {
            onServicesSelectionChange(data: data)
        } else if interactionType == .selectFacilities {
            onFacilitiesSelectionChange(data: data)
        }
    }

    @IBAction func onClickSelectServices(_ sender: Any) {
        var itemListArray: [ListItem] = [ListItem]()
        
        if let shopServices = AppController.sharedInstance.cachedServices {
            for model in shopServices {
                if let name = model.name, !name.isEmpty, let id = model.id {
                    let isFound = selectedServices[id] != nil
                    itemListArray.append(ListItem(name: name, id: id, isSelected: isFound))
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
    
    @IBAction func onClickFacilitiesButton(_ sender: Any) {
        var itemListArray: [ListItem] = [ListItem]()
        
        if let facilities = AppController.sharedInstance.cachedFacilities {
            for model in facilities {
                if let id = model.id, !model.name.isEmpty {
                    let isFound = selectedFacilities[id] != nil
                    itemListArray.append(ListItem(name: model.name, id: id, isSelected: isFound))
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
    
    @IBAction func onClickSearchButton(_ sender: Any) {
        let facilitiesID = Array(selectedFacilities.keys.map({ String($0) })).joined(separator: ",")
        let servicesID = Array(selectedServices.keys.map({ String($0) })).joined(separator: ",")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: BarberShopListingsVC.storyBoardID) as! BarberShopListingsVC
        controller.mTitle = "searchresult".localized()
        controller.searchType = SearchListings.SEARCH_BY_ADVANCED
        controller.searchListingModel = ShopListingSearchModel(name: searchTextField.text ?? "", facilitiesID: facilitiesID, servicesID: servicesID, costTo: String(costRangeSlider.selectedMaximum), costFrom: String(costRangeSlider.selectedMinimum), distTo: String(distanceRangeSlider.selectedMaximum), distFrom: String(distanceRangeSlider.selectedMinimum))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func onServicesSelectionChange(data: Any?) {
        let itemList = data as? [ListItem]
        var formattedServiceList = ""
        if let itemList = itemList, let services = AppController.sharedInstance.cachedServices {
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

    func onFacilitiesSelectionChange(data: Any?) {
        let itemList = data as? [ListItem]
        var formattedListString = ""
        if let itemList = itemList, let facilities = AppController.sharedInstance.cachedFacilities {
            for item in itemList {
                if item.isSelected {
                    if selectedFacilities[item.id] == nil, let model = FacilitiesModel.getModel(facilities: facilities, id: item.id) {
                        selectedFacilities[item.id] = model
                    }
                } else {
                    selectedFacilities[item.id] = nil
                }
            }
            
            formattedListString = itemList.flatMap({ $0.isSelected ? "\($0.name)" : nil }).joined(separator: ",")
        }
        
        selectedFacilitiesLabel.text = formattedListString
        selectedFacilitiesLabel.superview?.isHidden = formattedListString.isEmpty
    }

    // MARK: - Utility Methods
}
