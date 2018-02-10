//
//  UserModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class UserModel: Mappable {
    
    var id: Int = 0
    var firstName = ""
    var lastName = ""
    var password = ""
    var mobileNo: String?
    var email = ""
    var language = ""
    var nationality = ""
    var emirates = ""
    var profilePic: String?
    var sendAlerts: Bool?
    var displayPic: Bool?
    var calender: Bool?
    var token: String?
    
    required init?(map: Map) {
        
    }
    
    init() {
    }
    
    init(firstName: String, lastName: String, password: String, gender: String, email: String, language: String, nationality: String, emirates: String, profilePic: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.email = email
        self.language = language
        self.nationality = nationality
        self.emirates = emirates
        self.profilePic = profilePic
        
        self.displayPic = true
        self.sendAlerts = true
        self.calender = true
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        password <- map["password"]
        mobileNo <- map["mobileNo"]
        email <- map["email"]
        language <- map["language"]
        nationality <- map["nationality"]
        emirates <- map["emirates"]
        profilePic <- map["profilePic"]
        sendAlerts <- map["sendAlerts"]
        displayPic <- map["displayPic"]
        calender <- map["calender"]
        token <- map["token"]
    }
}
