//
//  FeedbackModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/8/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class FeedbackModel: Mappable {
    
    var userId: Int = 0
    var name: String = ""
    var email: String = ""
    var mobile: String = ""
    var subject: String = ""
    var message: String = ""
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init(userId: Int, name: String, email: String, mobile: String, subject: String, message: String) {
        self.userId = userId
        self.name = name
        self.email = email
        self.mobile = mobile
        self.subject = subject
        self.message = message
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        name <- map["name"]
        email <- map["email"]
        mobile <- map["mobile"]
        subject <- map["subject"]
        message <- map["message"]
        token <- map["token"]
    }
}
