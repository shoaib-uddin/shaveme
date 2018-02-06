//
//  GalleryArrayModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/25/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class GalleryArrayModel: Mappable {
    var baseUrl: String?
    var Gallery: [GalleryModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        baseUrl <- map["baseUrl"]
        Gallery <- map["Gallery"]
    }
}
