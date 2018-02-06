//
//  AddGalleryModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/22/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class AddGalleryModel: Mappable {
    var barberId: Int?
    var caption: String?
    var image: String?
    var userId: Int?
    var token: String?
    var ln: String?
    
    required init?(map: Map) {
        
    }
    
    init(barberID: Int, caption: String?, image: String?, userId: Int) {
        self.barberId = barberID
        self.caption = caption
        self.image = image
        self.userId = userId
    }
    
    func mapping(map: Map) {
        barberId <- map["barberId"]
        caption <- map["caption"]
        image <- map["image"]
        userId <- map["userId"]
        token <- map["token"]
        ln <- map["ln"]
    }
}
