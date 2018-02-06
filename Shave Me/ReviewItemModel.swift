//
//  ReviewItemModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/7/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class ReviewItemModel: Mappable {
    var barberId: Int?
    var userId: Int?
    var styleId: Int?
    var reviewId: Int?
    var subject: String = ""
    var message: String = ""
    var rating: Double = 0
    
    required init?(map: Map) {
        
    }
    
    init(barberId: Int, userId: Int, styleId: Int, reviewId: Int, subject: String, message: String, rating: Double) {
        self.barberId = barberId;
        self.userId = userId;
        self.styleId = styleId;
        self.reviewId = reviewId;
        self.subject = subject;
        self.message = message;
        self.rating = rating;
    }
    
    func mapping(map: Map) {
        barberId <- map["barberId"]
        userId <- map["userId"]
        styleId <- map["styleId"]
        reviewId <- map["reviewId"]
        subject <- map["subject"]
        message <- map["message"]
        rating <- map["rating"]
    }
}
