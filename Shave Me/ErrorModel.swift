//
//  ErrorModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/7/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class ErrorModel: Mappable {
    var Message: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        Message <- map["Message"]
    }
}
