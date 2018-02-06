//
//  FeaturedModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class FeaturedModel: Mappable {
    var barberShopid: Int = 0
    var imageName: String = ""
    var barberShopName: String = ""
    var barberShopAddress: String = ""
    var barberShopRating: Float = 0
    var distance: Float = 0
    var reviewCount: Int = 0
    var userlike: Int = 0
    var Review: [ReviewItemModel]?
    

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        barberShopid <- map["barberShopid"]
        imageName <- map["imageName"]
        barberShopName <- map["barberShopName"]
        barberShopAddress <- map["barberShopAddress"]
        barberShopRating <- map["barberShopRating"]
        distance <- map["distance"]
        reviewCount <- map["reviewCount"]
        userlike <- map["userlike"]
        Review <- map["Review"]
    }
}
