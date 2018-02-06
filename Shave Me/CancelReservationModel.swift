//
//  CancelReservationModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/10/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class CancelReservationModel: Mappable {
    
    var id: Int = 0
    var statusId: Int = 0
    var userId: Int = 0
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(id: Int, statusId: Int, userId: Int) {
        self.id = id
        self.statusId = statusId
        self.userId = userId
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        statusId <- map["statusId"]
        userId <- map["userId"]
        token <- map["token"]
    }
}
