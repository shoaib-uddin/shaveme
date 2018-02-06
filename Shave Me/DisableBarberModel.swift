//
//  DisableBarberModel.swift
//  Shave Me
//
//  Created by NoorAli on 1/18/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import ObjectMapper

class DisableBarberModel: Mappable {
    var stylistId: Int?
    var startDate: String?
    var endDate: String?
    var startTime: String?
    var endTime: String?
    var ln: String?
    var customerName: String?
    var type: String?
    var token: String?
    
    init(stylistId: Int?) {
        self.stylistId = stylistId
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        stylistId <- map["stylistId"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        ln <- map["ln"]
        customerName <- map["customerName"]
        type <- map["type"]
        token <- map["token"]
    }
    
    func getStartDateTime() -> Date? {
        guard let startDate = startDate, let startTime = startTime else {
            return nil
        }
        
        let index = startDate.index(startDate.startIndex, offsetBy: 10)
        let dateStrOnly = startDate.substring(to: index)
        let dateAndTimeStr = dateStrOnly + " " + startTime
        
        return dateAndTimeStr.date(fromFormat: "yyyy-MM-dd HH:mm")
    }
    
    func getStartDateOnly() -> Date? {
        guard let startDate = startDate else {
            return nil
        }
        
        let index = startDate.index(startDate.startIndex, offsetBy: 10)
        let dateStrOnly = startDate.substring(to: index)
        
        return dateStrOnly.date(fromFormat: "yyyy-MM-dd")
    }
    
    func getEndDateTime() -> Date? {
        guard let endDate = endDate, let endTime = endTime else {
            return nil
        }
        
        let index = endDate.index(endDate.startIndex, offsetBy: 10)
        let dateStrOnly = endDate.substring(to: index)
        let dateAndTimeStr = dateStrOnly + " " + endTime
        
        return dateAndTimeStr.date(fromFormat: "yyyy-MM-dd HH:mm")
    }
    
    func getEndDateOnly() -> Date? {
        guard let endDate = endDate else {
            return nil
        }
        
        let index = endDate.index(endDate.startIndex, offsetBy: 10)
        let dateStrOnly = endDate.substring(to: index)
        
        return dateStrOnly.date(fromFormat: "yyyy-MM-dd")
    }
    
    func isSame(model: DisableBarberModel) -> Bool {
        return self.startDate == model.startDate && self.endDate == model.endDate && self.startTime == model.startTime && self.endTime == model.endTime && self.stylistId == model.stylistId
    }
    
    func isIn(models: [DisableBarberModel]?) -> Bool {
        if let models = models {
            for item in models {
                if self.isSame(model: item) {
                    return true
                }
            }
        }
        return false
    }
}

