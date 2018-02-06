//
//  AvailabilityModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class AvailabilityModel: Mappable {
    
    var day: Int?
    var startTime = ""
    var endTime = ""
    var breakStartTime = ""
    var breakEndTime = ""
    
    required init?(map: Map) {
        
    }
    
    init(day: Int, startTime: String, endTime: String, breakStartTime: String, breakEndTime: String) {
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.breakStartTime = breakStartTime
        self.breakEndTime = breakEndTime
    }
    
    func mapping(map: Map) {
        day <- map["day"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        breakStartTime <- map["breakStartTime"]
        breakEndTime <- map["breakEndTime"]
    }
    
    class func getModel(models: [AvailabilityModel]?, day: Int?) -> AvailabilityModel? {
        if let models = models, let day = day {
            for model in models {
                if model.day == day {
                    return model
                }
            }
        }
        return nil
    }
    
    class func indexOfModel(models: [AvailabilityModel]?, day: Int?) -> Int? {
        if let models = models, let day = day {
            for (index, element) in models.enumerated() {
                if element.day == day {
                    return index
                }
            }
        }
        return nil
    }
    
    class func getInitialAvailabilityModel(models: [AvailabilityModel]?, day: Int?) -> AvailabilityModel? {
        if let models = models, let day = day, day > 0, day < 8 {
            for model in models {
                if model.day == day {
                    return model
                }
            }
            return getInitialAvailabilityModel(models: models, day: day + 1)
        }
        return nil
    }
}
