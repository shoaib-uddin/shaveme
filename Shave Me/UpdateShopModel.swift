//
//  UpdateShopModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/23/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class UpdateShopModel: Mappable {
    
    var userId: Int?
    var barberId: Int?
    var imgPath: String?
    var shopName = ""
    var Description = ""
    var shopAddress = ""
    var street = ""
    var area = ""
    var emirates = ""
    var latitude: String?
    var longitude: String?
    var Services: [ServiceModel]?
    var Availability: [AvailabilityModel]?
    var Facilities: [FacilitiesModel]?
    var ln = ""
    var token: String?
    
    init(object: BarberLoginModel) {
        self.userId = object.id
        self.barberId = object.barberShopId
        self.imgPath = object.imgPath
        self.shopName = object.shopName
        self.Description = ""
        self.shopAddress = object.address
        self.street = object.street
        self.area = object.area
        self.emirates = object.emirates
        self.latitude = String(describing: (object.latitude ?? 0))
        self.longitude = String(describing: (object.longitude ?? 0))
        self.Services = object.Services
        self.Availability = object.Availability
        self.Facilities = object.Facilities
        self.ln = ""
        self.token = ""
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        barberId <- map["barberId"]
        imgPath <- map["imgPath"]
        shopName <- map["shopName"]
        Description <- map["Description"]
        shopAddress <- map["shopAddress"]
        street <- map["street"]
        area <- map["area"]
        emirates <- map["emirates"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        Services <- map["Services"]
        Availability <- map["Availability"]
        Facilities <- map["Facilities"]
        ln <- map["ln"]
        token <- map["token"]
    }
}
