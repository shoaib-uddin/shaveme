//
//  StylistAvailbilityModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class StylistAvailbilityModel: Mappable {
    var stylistTimingsid: Int?
    var day: Int?
    var startTime: String?
    var endTime: String?
    var breakStartTime: String?
    var breakEndTime: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        stylistTimingsid <- map["stylistTimingsid"]
        day <- map["day"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        breakStartTime <- map["breakStartTime"]
        breakEndTime <- map["breakEndTime"]
    }
}

