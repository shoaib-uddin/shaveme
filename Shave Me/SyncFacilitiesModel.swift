//
//  SyncFacilitiesModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import Foundation

import ObjectMapper

class SyncFacilitiesModel: Mappable {
    var id: Int?
    var name: String = ""
    var icon: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        icon <- map["icon"]
    }
}
