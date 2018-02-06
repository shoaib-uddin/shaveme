//
//  FeaturingRequestModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/22/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class FeaturingRequestModel: Mappable {
    var id: Int?
    var barberId: Int?
    var startDate: String?
    var endDate: String?
    var providedDetails: String?
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(barberID: Int, startDate: String?, endDate: String?, providedDetails: String?) {
        self.barberId = barberID
        self.startDate = startDate
        self.endDate = endDate
        self.providedDetails = providedDetails
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        barberId <- map["barberId"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        providedDetails <- map["providedDetails"]
        token <- map["token"]
    }
}
