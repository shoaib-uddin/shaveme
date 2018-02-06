//
//  ReportModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/19/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class ReportModel: Mappable {
    var Count: Int?
    var Status: String?
    var StylistName: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        Count <- map["Count"]
        Status <- map["Status"]
        StylistName <- map["StylistName"]
    }
}
