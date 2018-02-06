//
//  BarberShopDetailsVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import HCSStarRatingView
import MZFormSheetPresentationController
import MapKit
import GoogleMaps

class BarberShopDetailsVC: BaseSideMenuViewController, UICollectionViewDataSource, UICollectionViewDelegate, ViewControllerInterationProtocol, UIScrollViewDelegate {
    internal var shopID: Int?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomLayout: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var reserveHereButton: UIButton!
    @IBOutlet weak var priceListButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var stickyShopTitle: UILabel!
    @IBOutlet weak var shopDistance: UILabel!
    @IBOutlet weak var stickyShopDistance: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var stickyRatingView: HCSStarRatingView!
    @IBOutlet weak var numberOfReviewsButton: UIButton!
    @IBOutlet weak var stickyNumberOfReviewsButton: UIButton!
    @IBOutlet weak var addReviewsButton: UIButton!
    @IBOutlet weak var stickyAddReviewsButton: UIButton!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var stickyTimingLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var stickyTitleView: UIView!
    
    @IBOutlet weak var ourServicesView: UIStackView!
    @IBOutlet weak var facilitiesStackView: UIStackView!
    
    @IBOutlet weak var stylistsCollectionView: UICollectionView!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    private var shopModel: BarberModel?
    private var isLiked = false
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mapping all the click callbacks
        AppUtils.setGestureRecognizers(senders: shareButton, locationButton, reserveHereButton, priceListButton, favoriteImageView, numberOfReviewsButton, addReviewsButton, stickyNumberOfReviewsButton, stickyAddReviewsButton, target: self, action: #selector(BarberShopDetailsVC.onClickCallback(_:)))
        
        makeServerRequest()
        
        self.scrollView.delegate = self
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_BARBERDETAIL_API:
                if let array = Mapper<BarberModel>().mapArray(JSONObject: response.value), array.count > 0 {
                    shopModel = array.first!
                    onBarberModelLoaded()
                } else {
                    AppUtils.showMessage(title: "alert".localized(), message: "authenticationFailed".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                }
            default:
                break
            }
        } else {
            statusLabel.isHidden = false
            statusLabel.text = response.status?.message
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
        
        activityIndicator.stopAnimating()
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        scrollView.isHidden = true
        bottomLayout.isHidden = true
        
        activityIndicator.startAnimating()
        
        makeServerRequest()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > self.coverImageView.bounds.size.height {
            stickyTitleView.isHidden = false
        } else {
            stickyTitleView.isHidden = true
        }
    }
    
    func onClickCallback(_ sender: UITapGestureRecognizer) {
        switch sender.view! {
        case self.favoriteImageView:
            onClickFavourite()
        case self.numberOfReviewsButton: fallthrough
        case self.stickyNumberOfReviewsButton:
            onClickNumberOfReviews()
        case self.addReviewsButton: fallthrough
        case self.stickyAddReviewsButton:
            onClickAddReview(barberShopID: shopModel!.shopid)
        case self.priceListButton:
            onClickPriceList()
        case self.locationButton:
            onClickLocation()
        case self.shareButton:
            onClickShare()
        case self.reserveHereButton:
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: ReservationVC.storyBoardID) as! ReservationVC
            frontViewController.barberShopID = shopModel!.shopid
            self.navigationController?.pushViewController(frontViewController, animated: true)
        default:
            break
        }
    }
    
    func onClickPriceList() {
        if let services = shopModel!.Services {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: PriceListVC.storyBoardID) as! PriceListVC
            controller.serviceModels = services
            AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 1, HeightMultiplier: 0.8)
        }
    }
    
    func onClickShare() {
        self.showProgressHUD()
        
        // text to share
        let text = "share".localized().replacingOccurrences(of: "SHOPNAME", with: shopModel!.shopName)

        AppDelegate.generateLink(shopID: shopModel!.shopid, shopName: shopModel!.shopName, shopDescription: text, shopImage: shopModel!.imgPath, completionHandler: { (shortLink, isSuccessfull) in
            self.hideProgressHUD()
            
            if isSuccessfull {
                // set up activity view controller
                let textToShare = [ shortLink ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
                
                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
            } else {
                AppUtils.showMessage(title: "alert".localized(), message: shortLink, buttonTitle: "okay".localized(), viewController: self, handler: nil)
            }
        })
    }
    
    func onClickLocation()  {
        if let shopModel = shopModel, let lat = shopModel.latitude, let long = shopModel.longitude {
            let latitude: CLLocationDegrees =  lat
            let longitude: CLLocationDegrees =  long
            
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            
            let marker = GMSMarker()
            marker.position = coordinates
            marker.icon = #imageLiteral(resourceName: "shop_location")
            marker.title = shopModel.shopName
            marker.snippet = shopModel.shopAddress.isEmpty ? shopModel.shopName : shopModel.shopAddress
            
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: OpenLocationVC.storyBoardID) as! OpenLocationVC
            frontViewController.currentLocationMarker = marker
            frontViewController.coordinates = coordinates
            frontViewController.title = shopModel.shopName
            self.navigationController?.pushViewController(frontViewController, animated: true)
        }
    }
    
    func onClickFavourite() {
        if AppController.sharedInstance.loggedInUser == nil {
            AppUtils.showLoginMessage(viewController: self, handler: nil)
        } else {
            isLiked = !isLiked
            DBFavorite.addUpdate(barberID: shopModel!.shopid, isLiked: isLiked)
            self.favoriteImageView.image = isLiked ? #imageLiteral(resourceName: "favorite_selected") : #imageLiteral(resourceName: "favorite_unselected")
            FavoritesModelController.updateFavoritesWithServer()
        }
    }
    
    func onClickNumberOfReviews() {
        if shopModel!.reviewCount > 0 {
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: ReviewListVC.storyBoardID) as! ReviewListVC
            frontViewController.barberShopID = shopModel!.shopid
            frontViewController.title = shopModel!.shopName
            self.navigationController?.pushViewController(frontViewController, animated: true)
        }
    }
    
    func onClickAddReview(barberShopID: Int) {
        if AppController.sharedInstance.loggedInUser == nil {
            AppUtils.showLoginMessage(viewController: self, handler: nil)
        } else {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: AddReviewVC.storyBoardID) as! AddReviewVC
            controller.barberShopID = barberShopID
            controller.delegate = self
            AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.9, HeightMultiplier: 0.5)
        }
    }
    
    // MARK: - Collection view delegate methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let shopModel = self.shopModel else {
            return 0
        }
        
        if collectionView == stylistsCollectionView {
            return shopModel.Stylist?.Stylist?.count ?? 0
        } else {
            return shopModel.Gallery?.Gallery?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageView = cell.subviews[0].subviews[0] as! UIImageView
        
        
        var urlString = ""
        if collectionView == self.stylistsCollectionView {
            urlString = (shopModel!.Stylist!.baseUrl ?? "") + (shopModel!.Stylist!.Stylist?[indexPath.row].thumbnailName ?? "")
        } else {
            urlString = (shopModel!.Gallery!.baseUrl ?? "") + (shopModel!.Gallery!.Gallery?[indexPath.row].thumbnailName ?? "")
        }
        
        let url = URL(string: urlString)!
        imageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "smallimagefetcher"))

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.stylistsCollectionView {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: StylistDetailVC.storyBoardID) as! StylistDetailVC
            controller.baseURL = shopModel!.Stylist!.baseUrl
            controller.stylistModel = shopModel!.Stylist!.Stylist![indexPath.row]
            
            AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.9, HeightMultiplier: 0.45)
        } else {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: GalleryDetailsVC.storyBoardID) as! GalleryDetailsVC
            controller.baseURL = shopModel!.Gallery!.baseUrl
            controller.galleryModels = shopModel!.Gallery!.Gallery!
            controller.selectedModelIndex = indexPath.row
            self.navigationController?.pushViewController(controller, animated: true)
//            AppUtils.addViewControllerModally(originVC: self, destinationVC: controller, widthMultiplier: 0.9, HeightMultiplier: 0.8)
        }
    }
    
    // MARK: - Utility Methods
    
    func onBarberModelLoaded() {
        guard let shopModel = self.shopModel else {
            return
        }
        
        scrollView.isHidden = false
        bottomLayout.isHidden = false
        
        // Setting cover image
        let url = URL(string: shopModel.imgPath)!
        self.coverImageView.af_setImage(withURL: url, placeholderImage: AppController.sharedInstance.placeHolderImage)
        // Setting Rating
        ratingView.value = CGFloat(shopModel.shopRating)
        stickyRatingView.value = CGFloat(shopModel.shopRating)
        // Setting Favorite
        if DBFavorite.isFavourite(barberId: shopModel.shopid) {
            isLiked = true;
            favoriteImageView.image = #imageLiteral(resourceName: "favorite_selected")
        } else {
            isLiked = false;
            favoriteImageView.image = #imageLiteral(resourceName: "favorite_unselected")
        }
        // Setting timing
        let timingsStr = calculateOpenTimings()
        timingLabel.text = timingsStr
        stickyTimingLabel.text = timingsStr
        // Setting description
        addressLabel.text = shopModel.description ?? shopModel.shopAddress
        // Setting shop name
        shopTitle.text = shopModel.shopName.uppercased()
        stickyShopTitle.text = shopModel.shopName.uppercased()
        if let distance = shopModel.distance, distance > 0 {
            shopDistance.text = String(distance) + " " + "distanceRangeText".localized()
            stickyShopDistance.text = String(distance) + " " + "distanceRangeText".localized()
        } else {
            shopDistance.isHidden = true
            stickyShopDistance.isHidden = true
        }
        // Setting number of reviews
        let reviewCountString = String(shopModel.reviewCount) + " " + (shopModel.reviewCount > 1 ? "reviews".localized() : "review".localized())
        numberOfReviewsButton.setTitle(reviewCountString, for: .normal)
        stickyNumberOfReviewsButton.setTitle(reviewCountString, for: .normal)
        // Load services
        createServicesSplitColumnView()
        createFacilitiesSplitColumnView()
        // Load Stylists and gallery
        self.stylistsCollectionView.reloadData()
        self.galleryCollectionView.reloadData()
    }
    
    func createServicesSplitColumnView() {
        if self.ourServicesView.subviews.count > 0 {
            return
        }
        
        guard let services = shopModel!.Services, services.count > 0 else {
            self.ourServicesView.isHidden = true
            return
        }
        
        var i = 0
        while i < services.count {
            let splitView = SplitColumnView()
            
            splitView.setFirstLabel(text: services[i].name)
            if i + 1 < services.count {
                splitView.setSecondLabel(text: services[i+1].name)
            } else {
                splitView.secondServiceView.isHidden = true
            }
            
            self.ourServicesView.addArrangedSubview(splitView)
            i += 2
        }
    }
    
    func createFacilitiesSplitColumnView() {
        if self.facilitiesStackView.subviews.count > 0 {
            return
        }
        
        guard let facilities = shopModel!.Facilities, facilities.count > 0 else {
            self.facilitiesStackView.isHidden = true
            return
        }
        
        var i = 0
        while i < facilities.count {
            let splitView = SplitColumnView()
            
            splitView.setFirstLabel(text: facilities[i].name)
            if i + 1 < facilities.count {
                splitView.setSecondLabel(text: facilities[i+1].name)
            } else {
                splitView.secondServiceView.isHidden = true
            }
            
            self.facilitiesStackView.addArrangedSubview(splitView)
            i += 2
        }
    }
    
    func calculateOpenTimings() -> String {
        guard let availability = getCurrentAvailabalityModel() else {
            return "closed".localized()
        }
        
        let today = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let startTime = dateFormatter.date(from: availability.startTime), let endTime = dateFormatter.date(from: availability.endTime) else {
            return "closed".localized()
        }
        
        if today.isAfterTimeOnly(to: startTime) {
            if today.isBeforeTimeOnly(to: endTime) {
                let breakStartTime = dateFormatter.date(from: availability.breakStartTime)
                let breakEndTime = dateFormatter.date(from: availability.breakEndTime)
                
                if let breakStartTime = breakStartTime, let breakEndTime = breakEndTime, today.compareTimeOnly(to: breakStartTime) == .orderedAscending, today.compareTimeOnly(to: breakEndTime) == .orderedAscending {
                    let diffInSeconds = today.getDifferenceInSecondsOfTimeOnly(to: breakEndTime)
                    let timeComponenetsTuple = Date.getHourMinutesSeconds(fromSeconds: diffInSeconds)
                    
                    var status = "openin".localized()
                    if timeComponenetsTuple.0 > 0 {
                        status += " " + String(timeComponenetsTuple.0) + " " + "hrs".localized()
                    }
                    if timeComponenetsTuple.1 > 0 {
                        status += " " + String(timeComponenetsTuple.1) + " " + "mins".localized()
                    }
                    
                    return status
                }
                return "nowopen".localized()
            }
        } else {
            let diffInSeconds = today.getDifferenceInSecondsOfTimeOnly(to: startTime)
            let timeComponenetsTuple = Date.getHourMinutesSeconds(fromSeconds: diffInSeconds)
            
            var status = "openin".localized()
            if timeComponenetsTuple.0 > 0 {
                status += " " + String(timeComponenetsTuple.0) + " " + "hrs".localized()
            }
            if timeComponenetsTuple.1 > 0 {
                status += " " + String(timeComponenetsTuple.1) + " " + "mins".localized()
            }
            return status
        }
        
        return "closed".localized()
    }
    
    func getCurrentAvailabalityModel() -> AvailabilityModel? {
        if let availabilityArray = shopModel!.Availability, availabilityArray.count > 0 {
            let today = Date()
            for availability in availabilityArray {
                if let dayNumberOfWeek = today.dayNumberOfWeek(), dayNumberOfWeek == availability.day {
                    return availability
                }
            }
        }
        return nil
    }
    
    func makeServerRequest() {
        if let shopID = self.shopID {
            let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
            _ = NetworkManager.getBarberShopDetails(shopID: shopID, userID: userID, completionHandler: onResponse)
        }
    }
}
