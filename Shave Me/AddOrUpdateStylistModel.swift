//
//  AddOrUpdateStylistModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/29/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class AddOrUpdateStylistModel: Mappable {
       
    var StylistId: Int?
    var userId: Int?
    var barberId: Int?
    
    var image: String?
    var name: String?
    var description: String?
    var services: String?
    
    var Availability: [AvailabilityModel]?
    
    var ln: String?
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init() {
        Availability = []
    }
    
    init(stylistModel: StylistModel) {
        self.StylistId = stylistModel.stylistId
        self.image = stylistModel.imgName
        self.name = stylistModel.name
        self.description = stylistModel.description
        self.services = stylistModel.services
        self.Availability = stylistModel.StylistAvailability
    }
    
    func mapping(map: Map) {
        StylistId <- map["StylistId"]
        userId <- map["userId"]
        barberId <- map["barberId"]
        image <- map["image"]
        name <- map["name"]
        description <- map["description"]
        services <- map["services"]
        Availability <- map["Availability"]
        ln <- map["ln"]
        token <- map["token"]
    }
}
