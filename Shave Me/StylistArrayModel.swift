//
//  StylistArrayModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class StylistArrayModel: Mappable {
    var baseUrl: String?
    var Stylist: [StylistModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        baseUrl <- map["baseUrl"]
        Stylist <- map["Stylist"]
    }
}
