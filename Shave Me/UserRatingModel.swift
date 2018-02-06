//
//  UserRatingModel.swift
//  Shave Me
//
//  Created by NoorAli on 2/1/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class UserRatingModel: Mappable {
    var barberId: Int?
    var userId: Int?
    var shopUserId: Int?
    
    var subject: String?
    var message: String?
    var rating: String?
    
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(barberId: Int, userId: Int, shopUserId: Int, subject: String, message: String, rating: String) {
        self.barberId = barberId
        self.userId = userId
        self.shopUserId = shopUserId
        self.subject = subject
        self.message = message
        self.rating = rating
    }
    
    func mapping(map: Map) {
        barberId <- map["barberId"]
        userId <- map["userId"]
        shopUserId <- map["shopUserId"]
        subject <- map["subject"]
        rating <- map["rating"]
        token <- map["token"]    }
}
