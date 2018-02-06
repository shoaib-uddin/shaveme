//
//  FeaturedListings.swift
//  Shave Me
//
//  Created by NoorAli on 12/25/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class FeaturedListings: Mappable {
    var baseUrl: String = ""
    var BarberShop: [FeaturedModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        baseUrl <- map["baseUrl"]
        BarberShop <- map["BarberShop"]
    }
}
