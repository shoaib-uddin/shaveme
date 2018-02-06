//
//  ReservationConfirmationVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/2/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import M13Checkbox

class ReservationConfirmationVC: BaseSideMenuViewController, UINavigationControllerDelegate {
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    var reservationId: String?
    var shopId = ""
    var ShopName = ""
    var date = ""
    var StartTime = ""
    var EndTime = ""
    var Duration = ""
    var Stylist = ""
    var StylistId = ""
    var Services = ""
    var ServiceIds = ""
    var TotalCost = ""
    
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var stylistLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var termsAndConditionsCheckbox: M13Checkbox!
    @IBOutlet weak var termsAndConditionsContainer: UIView!
    @IBOutlet weak var termsAndConditionsParent: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    
    private var isReservationHappenedSuccessfully = false
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Mapping all the click callbacks
        AppUtils.setGestureRecognizers(senders: termsAndConditionsContainer, continueButton, termsOfServiceLabel, target: self, action: #selector(ReservationVC.onClickCallback(_:)))
        
        if reservationId != nil {
            self.continueButton.setTitle("update".localized(), for: .normal)
        }
        
        shopLabel.text = ShopName
        stylistLabel.text = Stylist
        dateLabel.text = date
        timeLabel.text = StartTime + " - " + EndTime + "(" + Duration + " " + "mins".localized() + ")"
        servicesLabel.text = Services
        totalCostLabel.text = TotalCost + " " + "aed".localized()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            goBack()
        }
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        if response.status?.code == RequestStatus.CODE_OK {
            self.continueButton.setTitle("ifoundit".localized(), for: .normal)
            isReservationHappenedSuccessfully = true
            switch methodName {
            case ServiceUtils.POST_RESERVATION_API:
                termsAndConditionsParent.isHidden = true
                statusLabel.text = "reservationconfirmationtext2".localized()
                statusLabel.superview!.isHidden = false
                break
            case ServiceUtils.UPDATE_RESERVATION_API:
                AppUtils.showMessage(title: "alert".localized(), message: "updatedSuccessfully".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
                termsAndConditionsParent.isHidden = true
                statusLabel.text = "reservationconfirmationtext2".localized()
                statusLabel.superview!.isHidden = false
                break
            default:
                break
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
        
        self.hideProgressHUD()
    }

    func onClickCallback(_ sender: UITapGestureRecognizer) {
        switch sender.view! {
        case self.termsAndConditionsContainer:
            onClickTermsAndConditionsCheckBox()
        case self.continueButton:
            onClickContinueButton()
        case self.termsOfServiceLabel:
            onClickShowTermsOfService()
        default:
            break
        }
    }
    
    func onClickShowTermsOfService() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: TermsAndConditionsVC.storyBoardID)
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    func onClickContinueButton() {
        guard isReservationHappenedSuccessfully == false else {
            goBack()
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        guard self.termsAndConditionsCheckbox.checkState == M13Checkbox.CheckState.checked else {
            AppUtils.showMessage(title: "alert".localized(), message: "acceptTermsAndCondition".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        if let reservationId = reservationId, reservationId != "0" {
            let alert = UIAlertController(title: "alert".localized(), message: "updateConfirmation".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okay".localized(), style: .default, handler: {(action) in
                self.Reserve()
            }))
            alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.Reserve()
        }
    }
    
    func onClickTermsAndConditionsCheckBox() {
        let state: M13Checkbox.CheckState = self.termsAndConditionsCheckbox.checkState == M13Checkbox.CheckState.checked ? .unchecked : .checked
        self.termsAndConditionsCheckbox.setCheckState(state, animated: false)
    }
    
    // MARK: - Utility Methods

    func Reserve() {
        guard let userId = AppController.sharedInstance.loggedInUser?.id else {
            AppUtils.showLoginMessage(viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        let reservationModel = ReservationConfirmationModel(barberId: Int(shopId)!, userId: userId, styleId: Int(StylistId)!, reservedTimingFrom: StartTime, reservedTimingTo: EndTime, reservedDate: date, services: ServiceIds, servicesCost: TotalCost, servicesDuration: Double(Duration)!, statusId: AppoinmentModel.APPOINMENT_PENDING)
        
        if let reservationId = reservationId, let id = Int(reservationId), id > 0 {
            reservationModel.id = id
            _ = NetworkManager.updateReservation(reservationID: id, reservationModel: reservationModel, completionHandler: { (methodName, response) in
                self.onResponse(methodName: ServiceUtils.UPDATE_RESERVATION_API, response: response)
            })
        } else {
            _ = NetworkManager.postReservation(reservationModel: reservationModel, completionHandler: onResponse)
        }
    }
    
    func goBack() {
        if let delegate = self.delegate, isReservationHappenedSuccessfully {
            delegate.onViewControllerInteractionListener(interactionType: .reservationConfirmed, data: nil, childVC: self)
        }
    }
}
