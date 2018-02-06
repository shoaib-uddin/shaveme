//
//  GalleryModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/25/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class GalleryModel: Mappable {
    var galleryId: Int = 0
    var caption: String = ""
    var thumbnailName: String = ""
    var imgName: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        galleryId <- map["galleryId"]
        caption <- map["caption"]
        thumbnailName <- map["thumbnailName"]
        imgName <- map["imgName"]
    }
}
