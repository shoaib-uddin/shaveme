//
//  FacilitiesModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class FacilitiesModel: Mappable {
    var associatedFacilitiesId: Int?
    var facilitiesId: Int?
    var name: String = ""
    var iconPath: String?
    var distance: String?
    var remarks: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        associatedFacilitiesId <- map["associatedFacilitiesId"]
        facilitiesId <- map["facilitiesId"]
        name <- map["name"]
        iconPath <- map["iconPath"]
        distance <- map["distance"]
        remarks <- map["remarks"]
    }
    
    init(model: SyncFacilitiesModel, associatedFacilitiesId: Int?) {
        self.facilitiesId = model.id
        self.name = model.name
        self.associatedFacilitiesId = associatedFacilitiesId
    }
    
    class func getModel(facilities: [SyncFacilitiesModel]?, id: Int?) -> SyncFacilitiesModel? {
        if let facilities = facilities, let id = id {
            for facility in facilities {
                if facility.id == id {
                    return facility
                }
            }
        }
        return nil
    }
    
    class func getModel(facilities: [FacilitiesModel]?, id: Int?) -> FacilitiesModel? {
        if let facilities = facilities, let id = id {
            for facility in facilities {
                if facility.facilitiesId == id {
                    return facility
                }
            }
        }
        return nil
    }

}
