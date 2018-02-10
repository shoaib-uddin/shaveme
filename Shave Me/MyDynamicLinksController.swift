//
//  MyDynamicLinksController.swift
//  Shave Me
//
//  Created by NoorAli on 3/1/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks
import SWRevealViewController
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit

extension AppDelegate {
    
    fileprivate static let POST_Short_Links_API = "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key="
    fileprivate static let API_KEY = "AIzaSyCkV51OnRB7IAGnzyL1zjNuyPB77vdxu5A"
    fileprivate static let dynamicLinkDomain = "https://yhv6e.app.goo.gl"
    fileprivate static let APP_STORE_ID = "1128291252"
    fileprivate static let ANDROID_PACKAGE_NAME = "essentiallyprecise.shaveme"
    
    // MARK: - Deep Dynamic Linking
    
    // [START openurl]
    
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
//        let handle: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//        return handle;
//        if let dynamicLink = dynamicLink {
//            // Handle the deep link. For example, show the deep-linked content or
//            // apply a promotional offer to the user's account.
//            // [START_EXCLUDE]
//            // In this sample, we just open an alert.
//            //            let message = generateDynamicLinkMessage(dynamicLink)
//            if #available(iOS 8.0, *) {
//                parseAndShowShop(url: dynamicLink.url)
//            } else {
//                // Fallback on earlier versions
//            }
//            // [END_EXCLUDE]
//            return true
//        }
//        
//        // [START_EXCLUDE silent]
//        // Show the deep link that the app was called with.
//        if #available(iOS 8.0, *) {
//            parseAndShowShop(url: url)
//        } else {
//            // Fallback on earlier versions
//        }
//        // [END_EXCLUDE]
//        
//        
//        // Add any custom logic here.
//        return false
//        
//    }
    // [END openurl]
    
    // [START continueuseractivity]
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = FIRDynamicLinks.dynamicLinks() else {
            return false
        }
        
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            // [START_EXCLUDE]
            //            let message = self.generateDynamicLinkMessage(dynamiclink!)
            self.parseAndShowShop(url: dynamiclink?.url)
            // [END_EXCLUDE]
        }
        
        // [START_EXCLUDE silent]
        if !handled {
            // Show the deep link URL from userActivity.
            //            let message = "continueUserActivity webPageURL:\n\(userActivity.webpageURL)"
            parseAndShowShop(url: userActivity.webpageURL)
        }
        // [END_EXCLUDE]
        
        return handled
    }
    // [END continueuseractivity]
    
    fileprivate func generateDynamicLinkMessage(_ dynamicLink: FIRDynamicLink) -> String {
        let matchConfidence: String
        if dynamicLink.matchConfidence == .weak {
            matchConfidence = "Weak"
        } else {
            matchConfidence = "Strong"
        }
        let message = "App URL: \(dynamicLink.url)\nMatch Confidence: \(matchConfidence)\n"
        return message
    }
    
    @available(iOS 8.0, *)
    func parseAndShowShop(url: URL?) {
        guard let urlString = url?.absoluteString, let shopIDStr = urlString.components(separatedBy: "/").last, let shopID = Int(shopIDStr) else {
            return
        }
        
        if let revealVC = getTopViewController() as? SWRevealViewController {
            let frontVC = topViewControllerWithRootViewController(rootViewController: revealVC.frontViewController)
            print(frontVC)
            if let sb = frontVC.storyboard {
                let frontViewController = sb.instantiateViewController(withIdentifier: BarberShopDetailsVC.storyBoardID) as! BarberShopDetailsVC
                frontViewController.shopID = shopID
                frontVC.navigationController?.pushViewController(frontViewController, animated: true)
            }
        }
    }
    
    func getTopViewController() -> UIViewController{
        return topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow!.rootViewController!)
    }
    
    func topViewControllerWithRootViewController(rootViewController:UIViewController)->UIViewController{
        if rootViewController is UITabBarController{
            let tabBarController = rootViewController as! UITabBarController
            return topViewControllerWithRootViewController(rootViewController: tabBarController.selectedViewController!)
        }
        if rootViewController is UINavigationController{
            let navBarController = rootViewController as! UINavigationController
            return topViewControllerWithRootViewController(rootViewController: navBarController.visibleViewController!)
        }
        if let presentedViewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(rootViewController: presentedViewController)
        }
        return rootViewController
    }
    
    static func generateLink(shopID: Int, shopName: String, shopDescription: String, shopImage: String, completionHandler: @escaping (String, Bool) -> Void) {
        let link = "http://myshopid.com/\(shopID)"
        let bundleID = Bundle.main.bundleIdentifier!
        
        let dynamicLink = "\(AppDelegate.dynamicLinkDomain)/?link=\(link)&apn=\(AppDelegate.ANDROID_PACKAGE_NAME)&isi=\(AppDelegate.APP_STORE_ID)&ibi=\(bundleID)&st=\(shopName)&sd=\(shopDescription)&si=\(shopImage)"
        if ServiceUtils.isConnectedToNetwork() {
            let baseURL = AppDelegate.POST_Short_Links_API + AppDelegate.API_KEY
//            let suffixParameters : [String : String] = ["option" : "SHORT"]
            let parameters : [String : Any] = ["longDynamicLink" : dynamicLink]
            
            let dataRequest = Alamofire.request(baseURL, method: .post, parameters: parameters)
            dataRequest.validate().responseJSON { response in
                print("Request: \(response.request)")
                print("Response: \(response.response)")
                
                switch response.result {
                case .success:
                    if let JSON = response.result.value, let jsonDictionar = JSON as? Dictionary<String, String>, let shortLink = jsonDictionar["shortLink"] {
                        completionHandler(shortLink, true)
                    } else {
                        completionHandler("Error parsing response", false)
                    }
                case .failure(let error):
                    let errorString = error.localizedDescription
                    print(errorString)
                    completionHandler(errorString, false)
                }
            }
        }
    }
}
