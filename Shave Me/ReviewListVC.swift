//
//  ReviewListVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/22/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import HCSStarRatingView

class ReviewListVC: BaseSideMenuViewController, UITableViewDataSource, UITableViewDelegate {

    var barberShopID = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var reviewModels: [ReviewItemModel]?

    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        _ = NetworkManager.getReviews(shopID: barberShopID, completionHandler: onResponse)
    }
    
    // MARK: - Click and Callback Methods

    func onResponse(methodName: String, response: RequestResult) {
        
        if response.status?.code == RequestStatus.CODE_OK {
            reviewModels = Mapper<ReviewItemModel>().mapArray(JSONObject: response.value)
            tableView.reloadData()
            tableView.isHidden = false
            activityIndicator.stopAnimating()
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    // MARK: - Tableview Delegate Methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviewModels?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RatingCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! RatingCell
        let model = self.reviewModels![indexPath.row]
        
        cell.subjectLabel.text = model.subject
        cell.messageLabel.text = model.message
        cell.ratingsView.value = CGFloat(model.rating)
        
        return cell
    }
}

class RatingCell: UITableViewCell {
    @IBOutlet weak var ratingsView : HCSStarRatingView!
    @IBOutlet weak var subjectLabel : UILabel!
    @IBOutlet weak var messageLabel : UILabel!
}
