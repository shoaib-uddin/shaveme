//
//  BarberAppoinmentModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/18/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class BarberAppoinmentModel: Mappable {
    
    var id: Int?
    var userId: Int?
    var styleId: Int?
    var userName: String?
    var userProfilePic: String?
    var stylistName: String?
    var reservedDate: String?
    var reservedTimingFrom: String?
    var reservedTimingTo: String?
    var services: String?
    var Services: [ServiceModel]?
    var servicesDuration: Double?
    var servicesCost: Double?
    var rating: Float?
    var statusId: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        styleId <- map["styleId"]
        userName <- map["userName"]
        userProfilePic <- map["userProfilePic"]
        stylistName <- map["stylistName"]
        reservedDate <- map["reservedDate"]
        reservedTimingFrom <- map["reservedTimingFrom"]
        reservedTimingTo <- map["reservedTimingTo"]
        services <- map["services"]
        Services <- map["Services"]
        servicesDuration <- map["servicesDuration"]
        servicesCost <- map["servicesCost"]
        rating <- map["rating"]
        statusId <- map["statusId"]
    }
    
    func getReservedDate() -> Date? {
        guard let reservedDate = reservedDate else {
            return nil
        }
        
        return reservedDate.date(fromFormat: "yyyy-MM-dd'T'hh:mm:ss")
    }
    
    class func filterAppointments(response: Any?, appointmentID: Int = 0) -> [BarberAppoinmentModel] {
        var filteredModels = [BarberAppoinmentModel]()
        if let models = Mapper<BarberAppoinmentModel>().mapArray(JSONObject: response), models.count > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            for model in models {
                if let date = dateFormatter.date(from: model.reservedDate!) {
                    let today = Date()
                    if (Calendar.current.compare(today, to: date, toGranularity: .month) == .orderedSame
                        || Calendar.current.compare(today, to: date, toGranularity: .month) == .orderedDescending)
                        && (Calendar.current.compare(today, to: date, toGranularity: .year) == .orderedSame
                            || Calendar.current.compare(today, to: date, toGranularity: .year) == .orderedDescending) {
                        if appointmentID > 0 {
                            if appointmentID == model.id {
                                filteredModels.append(model)
                            }
                        } else {
                            filteredModels.append(model)
                        }
                    }
                }
            }
        }
        return filteredModels
    }
    
    class func filterUpcomingAppointments(models: [BarberAppoinmentModel]) -> [BarberAppoinmentModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm aa"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        var today = Date()
        today.addTimeInterval(-50)
        
        var filteredModels = [BarberAppoinmentModel]()
        
        for model in models {
            let dateString = model.reservedDate!.components(separatedBy: "T").first! + " " + model.reservedTimingTo!
            if let date = dateFormatter.date(from: dateString), date.isAfter(to: today) {
                filteredModels.append(model)
            }
        }
        return filteredModels
    }
    
    class func sort(models: [BarberAppoinmentModel]) -> [BarberAppoinmentModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm aa"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return models.sorted(by: { (model1, model2) -> Bool in
            let date1String = model1.reservedDate!.components(separatedBy: "T").first! + " " + model1.reservedTimingFrom!
            let date1 = dateFormatter.date(from: date1String)!
            
            let date2String = model2.reservedDate!.components(separatedBy: "T").first! + " " + model2.reservedTimingFrom!
            let date2 = dateFormatter.date(from: date2String)!
            
            return date1.compare(date2) == .orderedAscending
        })
    }
}
