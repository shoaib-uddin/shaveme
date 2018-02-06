//
//  SearchModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/20/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class SearchModel: Mappable {
    var barberShopId: Int?
    var imgName: String = ""
    var shopName: String = ""
    var shopAddress: String = ""
    var rating: Float = 0
    var reviewCount: Int = 0
    var userlike: Int = 0
    var latitude: Double?
    var longitude: Double?
    var Review: [ReviewItemModel]?
    var distance: Float = 0
    var isFeatured: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        barberShopId <- map["barberShopId"]
        imgName <- map["imgName"]
        shopName <- map["shopName"]
        shopAddress <- map["shopAddress"]
        rating <- map["rating"]
        reviewCount <- map["reviewCount"]
        userlike <- map["userlike"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        Review <- map["Review"]
        distance <- map["distance"]
        isFeatured <- map["isFeatured"]
    }
}
