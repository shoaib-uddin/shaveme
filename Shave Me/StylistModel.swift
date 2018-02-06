//
//  StylistModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class StylistModel: Mappable {
    var stylistId: Int?
    var name: String?
    var imgName: String = ""
    var isAvailable: Bool?
    var thumbnailName: String?
    var description: String = ""
    var services: String?
    var StylistAvailability: [AvailabilityModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        stylistId <- map["stylistId"]
        name <- map["name"]
        imgName <- map["imgName"]
        isAvailable <- map["isAvailable"]
        thumbnailName <- map["thumbnailName"]
        description <- map["description"]
        services <- map["services"]
        StylistAvailability <- map["StylistAvailability"]
    }
    
    class func getModel(models: [StylistModel]?, id: Int?) -> StylistModel? {
        if let models = models, let id = id {
            for model in models {
                if model.stylistId == id {
                    return model
                }
            }
        }
        return nil
    }
}

