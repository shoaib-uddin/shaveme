//
//  GBHFacebookHelper.swift
//  GBHFacebookImagePicker
//
//  Created by Florian Gabach on 28/09/2016.
//  Copyright (c) 2016 Florian Gabach <contact@floriangabach.fr>

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

class GBHFacebookHelper {
    
    // MARK: - Singleton
    
    static let shared = GBHFacebookHelper()
    
    // MARK: - Var
    
    /// User's album list
    
    
    /// Picture url path for the API
    fileprivate let pictureUrl = "https://graph.facebook.com/%@/picture?type=small&access_token=%@"
    
    // MARK: - Retrieve Facebook's Albums
    
    /// Make GRAPH API's request for user's album
    ///
    /// - Parameter after: after page identifier (optional)
    func fbDataRequest(after: String? = nil, completion: @escaping (Bool, UserModel?) -> Void) {
        
        // Build path album request
        //var  path = "me/albums?fields=id,name,count,cover_photo"
        var  path = "me?fields=id,name,first_name,last_name,email,gender,picture"
        if let afterPath = after {
            path = path.appendingFormat("&after=%@", afterPath)
        }
        
        // Build Facebook's request
        //let graphRequest = FBSDKGraphRequest(graphPath: "/me/albums", parameters: ["fields":"id,name,count,cover_photo"])
        
        let graphRequest = FBSDKGraphRequest(graphPath: path, parameters: nil)
        
        // Start Facebook Request
        _ = graphRequest?.start { _, result, error in
            if error != nil {
                print(error.debugDescription)
                completion(false, nil);
            } else {
                // Try to parse request's result
                
                if let dataArray = result as? [String: AnyObject] {
                    
                    // Parse Data
                    let a = Int(dataArray["id"] as! String)!
                    print(a)
                    
                    
                    let firstName = dataArray["first_name"] as! String;
                    let lastName = dataArray["last_name"] as! String;
                    let password = "shaveme@17";
                    let gender = dataArray["gender"] as! String;
                    let email = dataArray["email"] as! String;
                    let profilePic = dataArray["picture"]!["url"] as? String;
                    
                    let u = UserModel(firstName: firstName, lastName: lastName, password: password, gender: gender, email: email, language: "EN", nationality: "", emirates: "", profilePic: profilePic)
                    
                    completion(true, u);
                    
                    
                    
                    
                }
                
                
            }
        }
    }
    
    
    
    // MARK: - Logout
    
    /// Logout with clear session, token & user's album
    fileprivate func logout() {
        FBSDKLoginManager().logOut()
    }
    
    // MARK: - Login
    
    /// Start login with Facebook SDK
    ///
    /// - parameters vc: source controller
    /// - parameters completion: (success , error if needed)
    
    
    // MARK: - checkLogin
    
    /// check login with Facebook SDK
    ///
    /// - parameters completion: (success , error if needed)
    func checklogin() -> Bool{
        
        if FBSDKAccessToken.current() == nil {
            // No token, we need to login
            return true;
        } else {
            return false;
        }
    }
    
    // MARK: - checkLogin
    
    /// check login with Facebook SDK
    ///
    /// - parameters completion: (success , error if needed)
    func isTokenExist() -> Bool {
        return (FBSDKAccessToken.current() == nil) ? false : true;
    }
    
    // MARK: - checkLogin
    
    /// check login with Facebook SDK
    ///
    /// - parameters completion: (success , error if needed)
    func dologout() {
        
        if FBSDKAccessToken.current() == nil {
            // No token, we need to login
            print("Already logged out");
        } else {
            self.logout();
        }
    }
    
}

