//
//  GcmModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/12/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class GcmModel: Mappable {
    
    var userId: Int = 0
    var deviceType: String = "ios"
    var deviceId: String?
    var senderId: String?
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(userId: Int, deviceId: String, senderId: String) {
        self.userId = userId
        self.deviceId = deviceId
        self.senderId = senderId
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        deviceType <- map["deviceType"]
        deviceId <- map["deviceId"]
        senderId <- map["senderId"]
        token <- map["token"]
    }
}
