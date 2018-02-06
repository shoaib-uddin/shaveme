//
//  GcmShopModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/12/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class GcmShopModel: Mappable {
    
    var shopUserId: Int = 0
    var deviceType: String = "ios"
    var deviceId: String?
    var senderId: String?
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(shopUserId: Int, deviceId: String, senderId: String) {
        self.shopUserId = shopUserId
        self.deviceId = deviceId
        self.senderId = senderId
    }
    
    func mapping(map: Map) {
        shopUserId <- map["shopUserId"]
        deviceType <- map["deviceType"]
        deviceId <- map["deviceId"]
        senderId <- map["senderId"]
        token <- map["token"]
    }
}
