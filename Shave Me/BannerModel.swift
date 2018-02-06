//
//  BannerModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class BannerModel: Mappable {
    
    public static let URL_TYPE_SHOP = "SHOP"
    
    var image: String?
    var caption: String?
    var urlLink: String?
    var barberId: Int?
    var urltype: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        image <- map["image"]
        caption <- map["caption"]
        urlLink <- map["urlLink"]
        barberId <- map["barberId"]
        urltype <- map["urltype"]
    }
}
