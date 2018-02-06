//
//  AddGalleryVC.swift
//  Shave Me
//
//  Created by NoorAli on 1/22/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class AddGalleryVC: BaseSideMenuViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var captionTextView: KMPlaceholderTextView!
    
    fileprivate var galleryPictureBase64String: String?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "addphototitle".localized()
        
        self.hideKeyboardOnTap()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.topLayoutConstraint.constant = self.topLayoutGuide.length
    }
    
    // MARK: - Click and Callback Methods
    
    func onResponse(methodName: String, response: RequestResult) {
        self.hideProgressHUD()
        
        if response.status?.code == RequestStatus.CODE_OK {
            switch methodName {
            case ServiceUtils.POST_ADD_GALLERY_REQUEST:
                AppUtils.showMessage(title: "success".localized(), message: "imagesuccessfullyUploaded".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            default:
                break
            }
            
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: (response.status?.message)!, buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if let image = image {
            let scaledImage = image.resizeImage(newWidth: 1200)
            self.galleryPictureBase64String = scaledImage?.base64EncodedString()
            
            self.galleryImageView.image = scaledImage
        } else {
            AppUtils.showMessage(title: "alert".localized(), message: "Incompatible format", buttonTitle: "okay".localized(), viewController: self, handler: nil)
        }
    }
    
    @IBAction func onClickSelectImage(_ sender: Any) {
        let alert = UIAlertController(title: "addphoto".localized(), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "choosefromgallery".localized(), style: .default, handler: {(action) in
            AppUtils.getImageFromPhotoLibrary(viewController: self)
        }))
        alert.addAction(UIAlertAction(title: "takephoto".localized(), style: .default, handler:  {(action) in
            AppUtils.takePhoto(viewController: self)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickAddToGallery(_ sender: UIButton) {
        guard let galleryPictureBase64String = galleryPictureBase64String, !galleryPictureBase64String.isEmpty else {
            AppUtils.showMessage(title: "alert".localized(), message: "addimageGallery".localized(), buttonTitle: "okay".localized(), viewController: self, handler: nil)
            return
        }
        
        self.showProgressHUD()
        
        let barberID = AppController.sharedInstance.loggedInBarber?.barberShopId ?? 0
        let userID = AppController.sharedInstance.loggedInBarber?.id ?? 0
        
        let model = AddGalleryModel(barberID: barberID, caption: captionTextView.text, image: galleryPictureBase64String, userId: userID)
        _ = NetworkManager.postGallery(model: model, completionHandler: onResponse)
    }
}
