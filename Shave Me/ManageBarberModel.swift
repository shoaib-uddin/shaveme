//
//  ManageBarberModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/29/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class ManageBarberModel: Mappable {
    var stylistId: Int?
    var name: String?
    var thumbnailPath: String?
    var currentBooking: Int?
    var statusId: Int?
    var StylistAvailability: [AvailabilityModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        stylistId <- map["stylistId"]
        name <- map["name"]
        thumbnailPath <- map["thumbnailPath"]
        currentBooking <- map["currentBooking"]
        statusId <- map["statusId"]
        StylistAvailability <- map["StylistAvailability"]
    }
}
