//
//  FacebookLoginHelper.swift
//  Shave Me
//
//  Created by Xtreme Hardware on 10/02/2018.
//  Copyright © 2018 NoorAli. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookLoginHelper{
    
    
    
    class func login(){
        
        
        
    }
    
    class func fetchInfoFromFacebook(){
        
    }
    
    class func logout(){
        if FBSDKAccessToken.current() == nil {
            // No token, we need to login
            print("Already logged out");
        } else {
            FBSDKLoginManager().logOut()
        }
    }
    
    
}
