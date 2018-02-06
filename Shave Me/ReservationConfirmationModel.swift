//
//  ReservationConfirmationModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/2/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class ReservationConfirmationModel: Mappable {
    var id: Int = 0
    var barberId: Int = 0
    var userId: Int = 0
    var styleId: Int = 0
    var reservedTimingFrom = ""
    var reservedTimingTo = ""
    var reservedDate = ""
    var services = ""
    var servicesCost = ""
    var servicesDuration = ""
    var statusId: Int = 0
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(barberId: Int, userId: Int, styleId: Int, reservedTimingFrom: String, reservedTimingTo: String, reservedDate: String, services: String, servicesCost: String, servicesDuration: Double, statusId: Int) {
        self.barberId = barberId
        self.userId = userId
        self.styleId = styleId
        self.reservedTimingFrom = reservedTimingFrom
        self.reservedTimingTo = reservedTimingTo
        self.reservedDate = reservedDate
        self.services = services
        self.servicesCost = servicesCost
        self.servicesDuration = String(servicesDuration)
        self.statusId = statusId
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        barberId <- map["barberId"]
        userId <- map["userId"]
        styleId <- map["styleId"]
        reservedTimingFrom <- map["reservedTimingFrom"]
        reservedTimingTo <- map["reservedTimingTo"]
        reservedDate <- map["reservedDate"]
        services <- map["services"]
        servicesCost <- map["servicesCost"]
        servicesDuration <- map["servicesDuration"]
        statusId <- map["statusId"]
        token <- map["token"]
    }
}
