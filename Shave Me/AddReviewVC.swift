//
//  AddReviewVC.swift
//  Shave Me
//
//  Created by NoorAli on 12/22/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import HCSStarRatingView
import KMPlaceholderTextView
import ObjectMapper

class AddReviewVC: BaseViewController {

    var barberShopID = 0
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ViewControllerInterationProtocol? = nil
    
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var messageTextView: KMPlaceholderTextView!

    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardOnTap()
        
        self.messageTextView.placeholder = self.messageTextView.placeholder.localized()
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            if let reviewModels = Mapper<ReviewItemModel>().mapArray(JSONObject: response.value), reviewModels.count > 0 {
                AppUtils.showMessage(title: "alert".localized(), message: "reviewaddsuccess".localized(), buttonTitle: "okay".localized(), viewController: self, handler: { (action) in
                    if let delegate = self.delegate {
                        delegate.onViewControllerInteractionListener(interactionType: .addReview, data: reviewModels, childVC: self)
                    }
                    self.dismiss(animated: true, completion: nil)
                })
            }
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickRateUs(_ sender: Any) {
        
        if let subject = subjectTextField.text, let message = messageTextView.text, subject.characters.count > 0, message.characters.count > 0 {
            self.showProgressHUD()
            
            let userID = AppController.sharedInstance.loggedInUser?.id ?? 0
            
            let model = AddReviewModel(barberId: barberShopID, userId: userID, styleId: 0, subject: subject, message: message, rating: String(describing: ratingView.value))
            _ = NetworkManager.postReview(reviewModel: model, completionHandler: onResponse)
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "checkEmptyField".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickNextOnSubject(_ sender: Any) {
        self.messageTextView.becomeFirstResponder()
    }
}
