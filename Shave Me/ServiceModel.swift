//
//  ServiceModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class SyncServiceModel: Mappable {
    var id: Int?
    var name: String?
    var description: String?
    var icon: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        description <- map["description"]
        icon <- map["icon"]
    }
}

class ServiceModel: Mappable {
    var associatedServicesId: Int?
    var serviceId: Int = 0
    var name: String = ""
    var duration: Int = 0
    var cost: Int = 0
    // Agar Is Assosciated is zero toh woh kisi b stylist ko assign nahi hui
    // agar 1 hey toh assigned hey
    var isAssociated: Int?
    
    required init?(map: Map) {
        
    }
    
    convenience init(model: BarberServiceModel) {
        self.init(associatedServicesId: model.associatedServicesId, serviceId: model.serviceId, name: model.name, duration: model.duration, cost: model.cost)
    }
    
    init(associatedServicesId: Int?, serviceId: Int, name: String, duration: Int, cost: Int) {
        self.associatedServicesId = associatedServicesId
        self.serviceId = serviceId
        self.name = name
        self.duration = duration
        self.cost = cost
    }
    
    func mapping(map: Map) {
        associatedServicesId <- map["associatedServicesId"]
        serviceId <- map["serviceId"]
        name <- map["name"]
        duration <- map["duration"]
        cost <- map["cost"]
        isAssociated <- map["isAssociated"]
    }
    
    class func getModel(services: [ServiceModel]?, id: Int?) -> ServiceModel? {
        if let services = services, let id = id {
            for service in services {
                if service.serviceId == id {
                    return service
                }
            }
        }
        return nil
    }
    
    class func getModel(services: [SyncServiceModel]?, id: Int?) -> SyncServiceModel? {
        if let services = services, let id = id {
            for service in services {
                if service.id == id {
                    return service
                }
            }
        }
        return nil
    }
}
