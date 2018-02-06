//
//  BarberLoginModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class BarberLoginModel: Mappable {
    
    var id: Int?
    var barberShopId: Int = 0
    var firstName = ""
    var lastName = ""
    var mobileNo = ""
    var userName = ""
    var email = ""
    var imgPath = ""
    var shopName = ""
    var address = ""
    var street = ""
    var area = ""
    var emirates = ""
    var latitude: Double?
    var longitude: Double?
    var Services: [ServiceModel]?
    var Stylist: StylistArrayModel?
    var Availability: [AvailabilityModel]?
    var Facilities: [FacilitiesModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        barberShopId <- map["barberShopId"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        mobileNo <- map["mobileNo"]
        userName <- map["userName"]
        email <- map["email"]
        imgPath <- map["imgPath"]
        shopName <- map["shopName"]
        address <- map["address"]
        street <- map["street"]
        area <- map["area"]
        emirates <- map["emirates"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        Services <- map["Services"]
        Stylist <- map["Stylist"]
        Availability <- map["Availability"]
        Facilities <- map["Facilities"]
    }
}
