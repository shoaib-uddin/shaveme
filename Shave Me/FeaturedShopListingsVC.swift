//
//  FeaturedShopListingsVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/3/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import HCSStarRatingView
import AlamofireImage
import ESPullToRefresh
import Alamofire
import MZFormSheetPresentationController

class FeaturedShopListingsVC: BaseSideMenuViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellProtocol, ViewControllerInterationProtocol {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var baseURL = ServiceUtils.BASE_URL
    
    private var searchModelController: FeaturedModelController?
    
    var dataRequest: DataRequest?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showProgressHUD()
        
        self.tableView.estimatedRowHeight = 180
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        makeRequest()
        
        let footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        footer.loadingDescription = footer.loadingDescription.localized()
        footer.loadingMoreDescription = footer.loadingMoreDescription.localized()
        footer.noMoreDataDescription = footer.noMoreDataDescription.localized()
        _ = self.tableView.es_addInfiniteScrolling(animator: footer) {
            [weak self] in
            self?.loadMore()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        dataRequest = nil
        
        if response.status?.code == RequestStatus.CODE_OK {
            // If new shops are not empty
            // If previous shops are also not empty
            // If new shops are empty
            // If pevious shops are empty too show no items found otherwise show no more data
            if let newListing = Mapper<FeaturedListings>().map(JSONObject: response.value), newListing.BarberShop!.count > 0 {
                if AppController.sharedInstance.loggedInUser != nil {
                    for shop in newListing.BarberShop! {
                        DBFavorite.addUpdate(barberID: shop.barberShopid, isLiked: shop.userlike == 1)
                    }
                }
                
                if let searchModelController = self.searchModelController {
                    searchModelController.add(newFeaturedListings: newListing)
                } else {
                    searchModelController = FeaturedModelController()
                    searchModelController?.featuredListings = newListing
                }
                
                searchModelController?.mPageIndex += 1
                self.tableView.reloadData()
                
                statusLabel.isHidden = true
                tableView.isHidden = false
                
                self.tableView.es_stopLoadingMore()
            } else {
                if let searchModelController = self.searchModelController, let count = searchModelController.featuredListings.BarberShop?.count, count > 0 {
                    searchModelController.mStopPagination = true
                    self.tableView.es_noticeNoMoreData()
                } else {
                    statusLabel.isHidden = false
                    tableView.isHidden = true
                    statusLabel.text = "noitemsfound".localized()
                }
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?) {
        if interactionType == .addReview, let reviewModels = data as? [ReviewItemModel] {
            for shop in self.searchModelController!.featuredListings.BarberShop! {
                if shop.barberShopid == reviewModels[0].barberId {
                    shop.reviewCount = reviewModels.count
                    shop.Review = reviewModels
                    self.tableView.reloadData()
                    break
                }
            }
        }
    }
    
    // MARK: - Tableview Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchModelController?.featuredListings.BarberShop?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:BarberShopSearchListingCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! BarberShopSearchListingCell
        let model = (searchModelController?.featuredListings.BarberShop![indexPath.row])!
        
        cell.setCustomDelegateCallback(delegate: self, cellIndex: indexPath, data: model)
        
        let url = URL(string: searchModelController!.featuredListings.baseUrl + model.imageName)!
        cell.backgroundImageView.af_setImage(withURL: url, placeholderImage: AppController.sharedInstance.placeHolderImage)
        cell.distanceLabel.textColor = UIColor.COL_GOLDEN();
        cell.bottomView.backgroundColor = UIColor.COL_GOLDEN();
        cell.backgroundColor = UIColor.COL_GOLDEN();
        
        
        
        cell.shopAddressLabel.text = model.barberShopAddress
        cell.titleLabel.text = model.barberShopName.uppercased()
        cell.numberOfReviewsButton.setTitle(String(model.reviewCount) + " " + "reviews".localized(), for: .normal)
        
        cell.distanceLabel.isHidden = model.distance <= 0
        cell.distanceLabel.text = String(model.distance) + " " + "distanceRangeText".localized()
        
        cell.ratingsView.value = CGFloat(model.barberShopRating)
        
        if DBFavorite.isFavourite(barberId: model.barberShopid) {
            model.userlike = 1
            cell.favouritesButton.image = #imageLiteral(resourceName: "favorite_selected")
        } else {
            model.userlike = 0
            cell.favouritesButton.image = #imageLiteral(resourceName: "favorite_unselected")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = (searchModelController?.featuredListings.BarberShop![indexPath.row])!
        
        let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: BarberShopDetailsVC.storyBoardID) as! BarberShopDetailsVC
        frontViewController.shopID = model.barberShopid
        self.navigationController?.pushViewController(frontViewController, animated: true)
    }
    
    func didClickOnCell(indexPath: IndexPath, cell: UITableViewCell, data: Any?, sender: Any) {
        let model = data as! FeaturedModel
        let cell = cell as! BarberShopSearchListingCell
        
        if sender as? UIButton == cell.viewDetailsButton {
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: BarberShopDetailsVC.storyBoardID) as! BarberShopDetailsVC
            frontViewController.shopID = model.barberShopid
            self.navigationController?.pushViewController(frontViewController, animated: true)
        } else if sender as? UIButton == cell.reserveButton {
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: ReservationVC.storyBoardID) as! ReservationVC
            frontViewController.barberShopID = model.barberShopid
            self.navigationController?.pushViewController(frontViewController, animated: true)
        } else if sender as? UIImageView == cell.favouritesButton {
            if AppController.sharedInstance.loggedInUser == nil {
                AppUtils.showLoginMessage(viewController: self, handler: nil)
            } else {
                onClickFavourite(shop: model, cell: cell)
            }
        } else if sender as? UIButton == cell.addReviewsButton {
            if AppController.sharedInstance.loggedInUser == nil {
                AppUtils.showLoginMessage(viewController: self, handler: nil)
            } else {
                onClickAddReview(barberShopID: model.barberShopid)
            }
        } else if sender as? UIButton == cell.numberOfReviewsButton {
            if model.reviewCount > 0 {
                let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: ReviewListVC.storyBoardID) as! ReviewListVC
                frontViewController.barberShopID = model.barberShopid
                frontViewController.title = model.barberShopName
                self.navigationController?.pushViewController(frontViewController, animated: true)
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func onClickFavourite(shop: FeaturedModel, cell: BarberShopSearchListingCell) {
        if shop.userlike == 1 {
            shop.userlike = 0
            cell.favouritesButton.image = #imageLiteral(resourceName: "favorite_unselected")
            DBFavorite.addUpdate(barberID: shop.barberShopid, isLiked: false)
        } else {
            shop.userlike = 1
            cell.favouritesButton.image = #imageLiteral(resourceName: "favorite_selected")
            DBFavorite.addUpdate(barberID: shop.barberShopid, isLiked: true)
        }
        FavoritesModelController.updateFavoritesWithServer()
    }
    
    func onClickAddReview(barberShopID: Int) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: AddReviewVC.storyBoardID) as! AddReviewVC
        controller.barberShopID = barberShopID
        controller.delegate = self
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: controller)
        formSheetController.presentationController?.contentViewSize = CGSize(width: screenWidth * 0.9, height: screenHeight * 0.5)
        formSheetController.interactivePanGestureDismissalDirection = MZFormSheetPanGestureDismissDirection.all
        self.present(formSheetController, animated: true, completion: nil)
    }
    
    private func loadMore() {
        if let searchModelController = self.searchModelController, searchModelController.mStopPagination == false {
            if dataRequest == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.makeRequest()
                }
            }
        } else {
            self.tableView.es_noticeNoMoreData()
        }
    }
    
    func makeRequest() {
        let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
        let pageIndex = searchModelController?.mPageIndex ?? 0
        dataRequest = NetworkManager.getFeaturedListings(pageIndex: pageIndex, userID: userID, completionHandler: onResponse)
    }
}
