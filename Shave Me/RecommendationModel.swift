//
//  RecommendationModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/8/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class RecommendationModel: Mappable {
    
    var userId: Int = 0
    var name: String = ""
    var email: String = ""
    var shopeName: String = ""
    var address: String = ""
    var mobile: String = ""
    var contactPerson: String = ""
    var contactNo: String = ""
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(userId: Int, name: String, email: String, shopName: String, address: String, mobile: String, contactPerson: String, contactNo: String) {
        self.userId = userId
        self.name = name
        self.email = email
        self.shopeName = shopName
        self.address = address
        self.mobile = mobile
        self.contactPerson = contactPerson
        self.contactNo = contactNo
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        name <- map["name"]
        email <- map["email"]
        shopeName <- map["shopeName"]
        address <- map["address"]
        mobile <- map["mobile"]
        contactPerson <- map["contactPerson"]
        contactNo <- map["contactNo"]
        token <- map["token"]
    }
}
