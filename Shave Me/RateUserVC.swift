//
//  RateUserVC.swift
//  Shave Me
//
//  Created by NoorAli on 2/1/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import HCSStarRatingView
import ObjectMapper
import Alamofire

class RateUserVC: BaseViewController {

    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    var model: BarberAppoinmentModel?
    var isRateUser = false
    
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var reservedOnLabel: UILabel!
    @IBOutlet weak var didntComeButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    
    private var dataRequest: DataRequest?
    
    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = model?.userName ?? ""
        if let imgPath = model?.userProfilePic, let url = URL(string: imgPath) {
            mImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "nouserpic"))
        }
        reservedOnLabel.text = (model?.reservedTimingFrom ?? "") + " " + "to".localized() + " " + (model?.reservedTimingTo ?? "")
        
        if isRateUser {
            crossButton.isHidden = false
            didntComeButton.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let dataRequest = dataRequest {
            dataRequest.cancel()
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.UPDATE_RESERVATION_API: fallthrough
            case ServiceUtils.POST_USERREVIEW_API:
                AppUtils.showMessage(title: "alert".localized(), message: "userReview".localized(), buttonTitle: "okay".localized(), viewController: self, handler: { _ in
                    if let delegate = self.delegate {
                        delegate.onViewControllerInteractionListener(interactionType: .addReview, data: self.model, childVC: self)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                })
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickDidntComeButton(_ sender: UIButton) {
        guard let appointmentModelID = model?.id, let barberID = AppController.sharedInstance.loggedInBarber?.id else {
            return
        }
        
        self.showProgressHUD()
        
        let reservationConfirmationModel = CancelReservationModel(id: appointmentModelID, statusId: AppoinmentModel.APPOINMENT_CONFIRMED_NOT_ATTEND, userId: barberID)
        dataRequest = NetworkManager.updateReservation(reservationID: appointmentModelID, reservationModel: reservationConfirmationModel, completionHandler: onResponse)
    }
    
    @IBAction func onClickRateButton(_ sender: UIButton) {
        guard let appointmentModelID = model?.id, let appointmentModelUserID = model?.userId, let barberID = AppController.sharedInstance.loggedInBarber?.id, let barberShopId = AppController.sharedInstance.loggedInBarber?.barberShopId else {
            return
        }
        
        self.showProgressHUD()

        let userRatingModel = UserRatingModel(barberId: barberShopId, userId: appointmentModelUserID, shopUserId: barberID, subject: "", message: "", rating: String(describing: self.ratingView.value))
        dataRequest = NetworkManager.postUserReview(model: userRatingModel, completionHandler: onResponse)
    }
}
