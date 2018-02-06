//
//  InsertFavoriteModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/25/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class InsertFavoriteModel: Mappable {
    var userId: Int?
    var token: String?
    var barberIds: String?
    
    required init?(map: Map) {
        
    }
    
    init(userId: Int?, barberIds: String) {
        self.userId = userId
        self.barberIds = barberIds
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        barberIds <- map["barberIds"]
        token <- map["token"]
    }
}
