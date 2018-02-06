//
//  AddReviewModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/7/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class AddReviewModel: Mappable {
    var barberId: Int?
    var userId: Int?
    var styleId: Int?
    var subject: String?
    var message: String?
    var token: String?
    var rating: String?
    
    required init?(map: Map) {
        
    }
    
    init(barberId: Int, userId: Int, styleId: Int, subject: String, message: String, rating: String) {
        self.barberId = barberId;
        self.userId = userId;
        self.styleId = styleId;
        self.subject = subject;
        self.message = message;
        self.rating = rating;
    }
    
    func mapping(map: Map) {
        barberId <- map["barberId"]
        userId <- map["userId"]
        styleId <- map["styleId"]
        subject <- map["subject"]
        message <- map["message"]
        rating <- map["rating"]
        token <- map["token"]
    }
}
