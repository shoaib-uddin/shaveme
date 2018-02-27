//
//  BarberShopListingsVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/20/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import HCSStarRatingView
import AlamofireImage
import ESPullToRefresh
import Alamofire
import MZFormSheetPresentationController

class BarberShopListingsVC: BaseSideMenuViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellProtocol, ViewControllerInterationProtocol {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var mTitle = ""
    var searchType = 0
    var searchListingModel: ShopListingSearchModel!
    var searchModelController: SearchModelController?
    
    private var dataRequest: DataRequest?
    private var indexPath: IndexPath?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 180
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        footer.loadingDescription = footer.loadingDescription.localized()
        footer.loadingMoreDescription = footer.loadingMoreDescription.localized()
        footer.noMoreDataDescription = footer.noMoreDataDescription.localized()
        _ = self.tableView.es_addInfiniteScrolling(animator: footer) {
            [weak self] in
            self?.loadMore()
        }
        
        self.title = mTitle
        
        if searchType == SearchListings.SEARCH_BY_LOCATION {
            if let shops = searchModelController?.searchListings.Shop, !shops.isEmpty {
                self.tableView.reloadData()
             
                statusLabel.isHidden = true
                tableView.isHidden = false
                
                self.tableView.es_noticeNoMoreData()
            } else {
                statusLabel.isHidden = false
                tableView.isHidden = true
                statusLabel.text = "noitemsfound".localized()
            }
        } else {
            self.showProgressHUD()
            
            makeRequest()
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
                self.tableView.reloadData()
                
                statusLabel.isHidden = true
                tableView.isHidden = false
                
                self.tableView.es_stopLoadingMore()
            } else {
                if let searchModelController = self.searchModelController, let count = searchModelController.searchListings.Shop?.count, count > 0 {
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
            if let indexPath = indexPath, let model = searchModelController?.searchListings.Shop?[indexPath.row] {
                model.reviewCount = reviewModels.count
                model.rating = Float(reviewModels.map({ $0.rating }).reduce(0, +)) / Float(reviewModels.count)
                model.Review = reviewModels
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    // MARK: - Tableview Delegate Methods

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchModelController?.searchListings.Shop?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:BarberShopSearchListingCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! BarberShopSearchListingCell
        let model = (searchModelController?.searchListings.Shop![indexPath.row])!
        
        cell.setCustomDelegateCallback(delegate: self, cellIndex: indexPath, data: model)

        let url = URL(string: searchModelController!.searchListings.baseUrl + model.imgName)!
        cell.backgroundImageView.af_setImage(withURL: url, placeholderImage: AppController.sharedInstance.placeHolderImage)
        
        cell.shopAddressLabel.text = model.shopAddress
        cell.titleLabel.text = model.shopName.uppercased()
        cell.numberOfReviewsButton.setTitle(String(model.reviewCount) + " " + "reviews".localized(), for: .normal)
        
        cell.distanceLabel.textColor = model.isFeatured ? UIColor.COL_GOLDEN() : UIColor.COL_GOLDEN()
        cell.bottomView.backgroundColor = model.isFeatured ? UIColor.COL_GOLDEN() : UIColor.COL_GOLDEN()
        cell.featuredView.isHidden = !model.isFeatured
        cell.distanceLabel.isHidden = model.distance <= 0
        cell.distanceLabel.text = String(model.distance) + " " + "distanceRangeText".localized()
        cell.layoutIfNeeded();
        cell.ratingsView.value = CGFloat(model.rating)
        
        if DBFavorite.isFavourite(barberId: model.barberShopId!) {
            model.userlike = 1
            cell.favouritesButton.image = model.isFeatured ? #imageLiteral(resourceName: "favorite_selected_featured") : #imageLiteral(resourceName: "favorite_selected")
        } else {
            model.userlike = 0
            cell.favouritesButton.image = #imageLiteral(resourceName: "favorite_unselected")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = (searchModelController?.searchListings.Shop![indexPath.row])!
        
        let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: BarberShopDetailsVC.storyBoardID) as! BarberShopDetailsVC
        frontViewController.shopID = model.barberShopId
        self.navigationController?.pushViewController(frontViewController, animated: true)
    }
    
    func didClickOnCell(indexPath: IndexPath, cell: UITableViewCell, data: Any?, sender: Any) {
        let model = data as! SearchModel
        let cell = cell as! BarberShopSearchListingCell
        self.indexPath = indexPath
        
        if sender as? UIButton == cell.viewDetailsButton {
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: BarberShopDetailsVC.storyBoardID) as! BarberShopDetailsVC
            frontViewController.shopID = model.barberShopId
            self.navigationController?.pushViewController(frontViewController, animated: true)
        } else if sender as? UIButton == cell.reserveButton {
            let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: ReservationVC.storyBoardID) as! ReservationVC
            frontViewController.barberShopID = model.barberShopId!
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
                onClickAddReview(barberShopID: model.barberShopId!)
            }
        } else if sender as? UIButton == cell.numberOfReviewsButton {
            if model.reviewCount > 0 {
                let frontViewController = self.storyboard?.instantiateViewController(withIdentifier: ReviewListVC.storyBoardID) as! ReviewListVC
                frontViewController.barberShopID = model.barberShopId!
                frontViewController.title = model.shopName
                self.navigationController?.pushViewController(frontViewController, animated: true)
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func onClickFavourite(shop: SearchModel, cell: BarberShopSearchListingCell) {
        if shop.userlike == 1 {
            shop.userlike = 0
            cell.favouritesButton.image = #imageLiteral(resourceName: "favorite_unselected")
            DBFavorite.addUpdate(barberID: shop.barberShopId!, isLiked: false)
        } else {
            shop.userlike = 1
            cell.favouritesButton.image = shop.isFeatured ? #imageLiteral(resourceName: "favorite_selected_featured") : #imageLiteral(resourceName: "favorite_selected")
            DBFavorite.addUpdate(barberID: shop.barberShopId!, isLiked: true)
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
        if searchType == SearchListings.SEARCH_BY_NAME {
            dataRequest = NetworkManager.getSearchByName(query: searchListingModel.NAME, pageIndex: pageIndex, userID: userID, completionHandler: onResponse)
        } else if searchType == SearchListings.SEARCH_BY_ADVANCED {
            dataRequest = NetworkManager.getAdvancedSearch(searchModel: searchListingModel, pageIndex: pageIndex, userID: userID, completionHandler: onResponse)
        }
    }
}

class BarberShopSearchListingCell: BaseTableViewCell {
    @IBOutlet weak var backgroundImageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var distanceLabel : UILabel!
    @IBOutlet weak var ratingsView : HCSStarRatingView!
    @IBOutlet weak var shopAddressLabel : UILabel!
    @IBOutlet weak var numberOfReviewsButton : UIButton!
    @IBOutlet weak var addReviewsButton : UIButton!
    @IBOutlet weak var viewDetailsButton : UIButton!
    @IBOutlet weak var reserveButton : UIButton!
    @IBOutlet weak var favouritesButton : UIImageView!
    @IBOutlet weak var bottomView : UIView!
    @IBOutlet weak var featuredView : UIView!
    
    override func awakeFromNib() {
        setGestureRecognizer(senders: numberOfReviewsButton, addReviewsButton, viewDetailsButton, reserveButton, favouritesButton)
    }
}
