//
//  HomeBannerModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import Foundation

import ObjectMapper

class HomeBannerModel: Mappable {
    
    var baseUrl: String?
    var Banner: [BannerModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        baseUrl <- map["baseUrl"]
        Banner <- map["Banner"]
    }
}
