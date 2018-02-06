//
//  ReportResultVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/19/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper

class ReportResultVC: BaseSideMenuViewController {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    var startDate: String!
    var endDate: String!
    var stylistIDs: String!
    var statusIDs: String!
    
    @IBOutlet weak var reportDateLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var reportListStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noItemsFoundView: UIView!
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "report".localized()
        
        reportDateLabel.text = "reportfrom".localized() + " " + startDate + " " + "to".localized() + " " + endDate
        
        self.showProgressHUD()
        
        let barberShopId = AppController.sharedInstance.loggedInBarber?.barberShopId ?? 0
        _ = NetworkManager.getReportRequest(barberShopId: barberShopId, startDate: startDate, endDate: endDate, stylistIDs: stylistIDs, statusIDs: statusIDs, completionHandler: onResponse)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.GET_REPORT_REQUEST:
                if let reportArray = Mapper<ReportModel>().mapArray(JSONObject: response.value), !reportArray.isEmpty {
                    scrollView.isHidden = false
                    
                    for item in reportArray {
                        let itemView = ReportItemView()
                        
                        itemView.stylistNameLabel.text = item.StylistName
                        itemView.typeLabel.text = item.Status
                        itemView.countLabel.text = String(item.Count ?? 0)
                        
                        self.reportListStackView.addArrangedSubview(itemView)
                    }
                    
                    totalCountLabel.text = String(reportArray.map({ $0.Count ?? 0 }).reduce(0, +))
                    
                } else {
                    noItemsFoundView.isHidden = false
                }
                break
            default:
                break
            }
            self.hideProgressHUD()
        } else {
            self.hideProgressHUD()
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
}
