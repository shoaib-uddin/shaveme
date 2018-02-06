//
//  AppUtils.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import SWRevealViewController
import MZFormSheetPresentationController
import Alamofire

public final class AppUtils {
    
    class func setGestureRecognizers(senders: UIView ..., target: Any, action: Selector) {
        for sender in senders {
            let tapGesture = UITapGestureRecognizer(target: target, action: action)
            tapGesture.numberOfTapsRequired = 1
            sender.addGestureRecognizer(tapGesture)
        }
    }
    
    static func onLanguageChange() {
        L102Language.setAppleLAnguageTo(lang: AppController.sharedInstance.language)
        if AppController.sharedInstance.language == "en" {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        } else {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }
    }
    
    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func logFontNames() {
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
    static func updateDeviceDetailsForPushNotifications(completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        if let token = AppController.sharedInstance.pushNotificationsDeviceToken {
            print("FIREBASE SENDER ID TOKEN: "+token)
            if let barberID = AppController.sharedInstance.loggedInBarber?.id {
                let model = GcmShopModel(shopUserId: barberID, deviceId: token, senderId: token)
                return NetworkManager.postGCMShopRegisterationModel(model: model, completionHandler: completionHandler)
            } else if let userID = AppController.sharedInstance.loggedInUser?.id {
                let model = GcmModel(userId: userID, deviceId: token, senderId: token)
                return NetworkManager.postGCMUserRegisterationModel(model: model, completionHandler: completionHandler)
            }
        }
        return nil
    }
    
    class func addViewControllerModally(originVC: UIViewController, destinationVC: UIViewController, widthMultiplier: CGFloat = 1, HeightMultiplier: CGFloat = 1) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: destinationVC)
        formSheetController.presentationController?.contentViewSize = CGSize(width: screenWidth * widthMultiplier, height: screenHeight * HeightMultiplier)
        formSheetController.interactivePanGestureDismissalDirection = MZFormSheetPanGestureDismissDirection.all
        originVC.present(formSheetController, animated: true, completion: nil)
    }
    
    static func makeImageRoundable(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        imageView.layer.borderWidth = 4.0;
        imageView.layer.borderColor = UIColor.COL15b599().cgColor
    }
    
    static func applyGradientBackground(view: UIView) {
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor.COL15b599().cgColor, UIColor.COL15b599().cgColor]
        backgroundGradientLayer.locations = [0.0, 0.8]
        
        view.backgroundColor = UIColor.clear
        backgroundGradientLayer.frame = view.frame
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    static func showMessage(title: String, message: String, buttonTitle: String, viewController: UIViewController, handler: ((UIAlertAction) -> Void)?) {
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: handler))
        
        viewController.present(refreshAlert, animated: true, completion: nil)
    }
    
    static func showLoginMessage(viewController: UIViewController, handler: ((UIAlertAction) -> Void)?) {
        let loginAlert = UIAlertController(title: "alert".localized(), message: "pleaselogin".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        loginAlert.addAction(UIAlertAction(title: "clickherelogin".localized(), style: .default, handler: {(action) in
            let controller = viewController.storyboard!.instantiateViewController(withIdentifier: UserLoginVC.storyBoardID) as! UserLoginVC
            if let delegate = viewController as? ViewControllerInterationProtocol {
                controller.delegate = delegate
            }
            viewController.navigationController?.pushViewController(controller, animated: true)
            
            if let handler = handler {
                handler(action)
            }
        }))
        
        loginAlert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: handler))
        
        viewController.present(loginAlert, animated: true, completion: nil)
    }
    
    static func showLoginMessage(viewController: UIViewController, storyboard: UIStoryboard, handler: ((UIAlertAction) -> Void)?) {
        let loginAlert = UIAlertController(title: "alert".localized(), message: "pleaselogin".localized(), preferredStyle: UIAlertControllerStyle.alert)
        
        loginAlert.addAction(UIAlertAction(title: "clickherelogin".localized(), style: .default, handler: {(action) in
            let controller = storyboard.instantiateViewController(withIdentifier: UserLoginVC.storyBoardID) as! UserLoginVC
            if let delegate = viewController as? ViewControllerInterationProtocol {
                controller.delegate = delegate
            }
            viewController.navigationController?.pushViewController(controller, animated: true)
            
            if let handler = handler {
                handler(action)
            }
        }))
        
        loginAlert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: handler))
        
        viewController.present(loginAlert, animated: true, completion: nil)
    }
    
    static func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static func share(sharetext: String, currentViewController: UIViewController) {
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [sharetext], applicationActivities: nil);
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll]
        currentViewController.present(activityViewController, animated: true, completion: nil);
    }
    
    static func addGeneralBackgroundImage(parentView: UIView) {
        let ivBG = UIImageView(image: UIImage(named: "general_bg"))
        ivBG.contentMode = .scaleAspectFill
        ivBG.translatesAutoresizingMaskIntoConstraints = false
        parentView.insertSubview(ivBG, at: 0)
        
        NSLayoutConstraint(item: ivBG, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: ivBG, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: ivBG, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: ivBG, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0).isActive = true
    }
    
    static func getImageFromPhotoLibrary(viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        if let viewController = viewController as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
            imagePickerController.delegate = viewController
        } else {
            print("View controller does not conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate protocols")
        }
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    static func takePhoto(viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .front
        imagePickerController.allowsEditing = true
        if let viewController = viewController as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
            imagePickerController.delegate = viewController
        } else {
            print("View controller does not conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate protocols")
        }
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
}

@IBDesignable class GradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.COL15b599()
    @IBInspectable var secondColor: UIColor = UIColor.white
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [firstColor.cgColor, secondColor.cgColor]
    }
}


@IBDesignable class SelectableButton: UIButton {
    @IBInspectable var defaultColor: UIColor = UIColor.COL47d9bf()
    @IBInspectable var highlightedColor: UIColor = UIColor.COL50e9ce()
    
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                backgroundColor = highlightedColor
            case false:
                backgroundColor = defaultColor
            }
        }
    }
}

class KeyboardStateListener: NSObject
{
    static var shared = KeyboardStateListener()
    var isVisible = false
    
    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(didShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func didShow()
    {
        isVisible = true
    }
    
    func didHide()
    {
        isVisible = false
    } 
}

