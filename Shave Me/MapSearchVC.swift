//
//  MapSearchVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/20/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import GoogleMaps
import SearchTextField
import ObjectMapper
import Alamofire

class MapSearchVC: BaseSideMenuViewController, UITextFieldDelegate, GMSMapViewDelegate {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var searchTextField: SearchTextField!

    fileprivate var autoSuggestionsDataRequest: DataRequest?
    fileprivate var searchListingDataRequest: DataRequest?
    fileprivate var shopLocationMarkersID = [GMSMarker : Int]()
    fileprivate var searchModelController: SearchModelController?
    fileprivate var currentLocationMarker: GMSMarker?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "quicksearch".localized()
        
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
        
        searchTextField.delegate = self
        
        mapView.delegate = self
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
            case ServiceUtils.GET_SEARCHBYLOCATION_API:
                if let newSearchListing = Mapper<SearchListings>().map(JSONObject: response.value), newSearchListing.Shop!.count > 0 {
                    if AppController.sharedInstance.loggedInUser != nil {
                        for shop in newSearchListing.Shop! {
                            DBFavorite.addUpdate(barberID: shop.barberShopId!, isLiked: shop.userlike == 1)
                        }
                    }
                    
                    if let searchModelController = self.searchModelController {
                        searchModelController.add(newSearchListings: newSearchListing)
                    } else {
                        searchModelController = SearchModelController()
                        searchModelController?.searchListings = newSearchListing
                    }
                    
                    searchModelController?.mPageIndex += 1
                    
                    setLocations()
                }
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickListMapButton(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: BarberShopListingsVC.storyBoardID) as! BarberShopListingsVC
        controller.mTitle = "searchresult".localized()
        controller.searchType = SearchListings.SEARCH_BY_LOCATION
        controller.searchModelController = searchModelController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onClickFilterButton(_ sender: UIButton) {
        self.navigationController?.pushViewController(AdvancedSearchVC(), animated: true)
    }
    
    @IBAction func onClickCurrentLocation(_ sender: UIButton) {
        if let currentLocation = AppController.sharedInstance.currenLocation?.coordinate {
            mapView.animate(toLocation: currentLocation)
            mapView.animate(toZoom: 13.0)
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "enableLocation".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickSearchButton(_ sender: UIButton) {
        if let text = self.searchTextField.text, text.characters.count > 2 {
            onSearch(query: text)
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "minumum_3_characters_to_search_message".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    // MARK: - Map View delegates
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let target = mapView.camera.target
        
        let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
        
        searchListingDataRequest = NetworkManager.getSearchByLocation(latitude: String(Double(target.latitude)), longitude: String(Double(target.longitude)), pageIndex: 0, userID: userID, completionHandler: onResponse)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let shopID = shopLocationMarkersID[marker] {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: BarberShopDetailsVC.storyBoardID) as! BarberShopDetailsVC
            controller.shopID = shopID
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        setCurrentLocation()
    }
    
    // MARK: - Textfield delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = self.searchTextField.text, text.characters.count > 2 {
            onSearch(query: text)
            return true
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "minumum_3_characters_to_search_message".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return false
        }
    }
    
    // MARK: - Utility Methods
    
    func onSearch(query: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: BarberShopListingsVC.storyBoardID) as! BarberShopListingsVC
        controller.mTitle = "searchresult".localized()
        controller.searchType = SearchListings.SEARCH_BY_NAME
        controller.searchListingModel = ShopListingSearchModel(name: query)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func addMarkerToMap(searchModel: SearchModel) -> GMSMarker {
        let icon = searchModel.isFeatured ? #imageLiteral(resourceName: "shop_location_featured") : #imageLiteral(resourceName: "shop_location")
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: searchModel.latitude ?? 0, longitude: searchModel.longitude ?? 0)
        marker.icon = icon
        marker.title = searchModel.shopName
        marker.snippet = searchModel.shopAddress.isEmpty ? searchModel.shopName : searchModel.shopAddress
        marker.map = mapView
        
        return marker
    }
    
    func setLocations() {
        if let shops = self.searchModelController?.searchListings.Shop {
            for item in shops {
                if !shopLocationMarkersID.containsValue(value: item.barberShopId!) {
                    shopLocationMarkersID[addMarkerToMap(searchModel: item)] = item.barberShopId!
                }
            }
        }
    }
    
    func setCurrentLocation() {
        if let currentLocation = AppController.sharedInstance.currenLocation?.coordinate {
            let latitude: Double = currentLocation.latitude
            let longitude: Double = currentLocation.longitude
            
            if let currentLocationMarker = self.currentLocationMarker  {
                currentLocationMarker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            } else {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                //marker.icon = #imageLiteral(resourceName: "user_location")
                marker.icon = #imageLiteral(resourceName: "shop_location_featured")
                marker.title = "current_location".localized()
                marker.snippet = "current_location".localized()
                marker.map = mapView
                
                mapView.animate(toLocation: currentLocation)
                mapView.animate(toZoom: 13.0)
                
                currentLocationMarker = marker
                
                let geocoder: GMSGeocoder = GMSGeocoder()
                geocoder.reverseGeocodeCoordinate(currentLocation, completionHandler: { (gmsReverseGeocodeResponse, error) in
                    if let address = gmsReverseGeocodeResponse?.firstResult() {
                        self.currentLocationLabel.text = (address.lines?.first ?? "") + ", " + (address.locality ?? "")
                    }
                })
            }
        }
    }
}
