//
//  PushMessageModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/15/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit

class PushMessageModel {
    fileprivate static let KEY_MESSAGE_ENGLISH = "message"
    fileprivate static let KEY_MESSAGE_ARABIC = "messageAr"
    fileprivate static let KEY_STATUS_ID = "statusId"
    fileprivate static let KEY_ID = "id"
    
    var message = ""
    var id: Int?
    var statusID: Int?
    
    var isForeground = false
    
    init() {
        
    }
    
    init(id: Int, statusID: Int, message: String) {
        self.id = id
        self.statusID = statusID
        self.message = message
    }
    
    init(userInfo: [AnyHashable : Any]) {
        if let aps = userInfo["aps"] as? NSDictionary, let alert = aps["alert"] as? String {
            self.message = alert
        }
        
        if let isForeground = userInfo["isForeground"] as? Bool {
            self.isForeground = isForeground
        }
        
        if let otherDetails = userInfo["other_details"] as? NSDictionary {
            self.id = otherDetails[PushMessageModel.KEY_ID] as? Int
            self.statusID = otherDetails[PushMessageModel.KEY_STATUS_ID] as? Int
        }
    }
}
