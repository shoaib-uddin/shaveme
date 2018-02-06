//
//  BarberModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/25/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class BarberModel: Mappable {
    var shopid: Int = 0
    var imgPath: String = ""
    var shopName: String = ""
    var shopRating: Float = 0
    var shopAddress: String = ""
    var description: String?
    var reviewCount: Int = 0
    var Services: [ServiceModel]?
    var Availability: [AvailabilityModel]?
    var Stylist: StylistArrayModel?
    var Gallery: GalleryArrayModel?
    var Facilities: [FacilitiesModel]?
    var Review: [ReviewItemModel]?
    var latitude: Double?
    var longitude: Double?
    var minReservationTime: Int = 0
    var distance: Float?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        shopid <- map["shopid"]
        imgPath <- map["imgPath"]
        shopName <- map["shopName"]
        shopRating <- map["shopRating"]
        shopAddress <- map["shopAddress"]
        description <- map["description"]
        reviewCount <- map["reviewCount"]
        Services <- map["Services"]
        Availability <- map["Availability"]
        Stylist <- map["Stylist"]
        Gallery <- map["Gallery"]
        Facilities <- map["Facilities"]
        Review <- map["Review"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        minReservationTime <- map["minReservationTime"]
        distance <- map["distance"]
    }
}
