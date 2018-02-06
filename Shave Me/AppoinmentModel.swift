//
//  AppoinmentModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/12/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class AppoinmentModel: Mappable {
    
    var id: Int?
    var barberId: Int?
    var userId: Int?
    var styleId: Int?
    var shopName: String?
    var reservedDate: String?
    var reservedTimingFrom: String?
    var reservedTimingTo: String?
    var services: String?
    var Services: [ServiceModel]?
    var servicesDuration: Double?
    var servicesCost: Double?
    var stylistName: String?
    var statusId: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        barberId <- map["barberId"]
        userId <- map["userId"]
        styleId <- map["styleId"]
        shopName <- map["shopName"]
        reservedDate <- map["reservedDate"]
        reservedTimingFrom <- map["reservedTimingFrom"]
        reservedTimingTo <- map["reservedTimingTo"]
        services <- map["services"]
        Services <- map["Services"]
        servicesDuration <- map["servicesDuration"]
        servicesCost <- map["servicesCost"]
        stylistName <- map["stylistName"]
        statusId <- map["statusId"]
    }
    
    func getReservedDate() -> Date? {
        guard let reservedDate = reservedDate else {
            return nil
        }
        
        return reservedDate.date(fromFormat: "yyyy-MM-dd'T'hh:mm:ss")
    }
    
    class func filterAppointments(response: Any?, appointmentID: Int = 0) -> [AppoinmentModel] {
        var filteredModels = [AppoinmentModel]()
        if let models = Mapper<AppoinmentModel>().mapArray(JSONObject: response), models.count > 0 {
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
    
    class func filterUpcomingAppointments(models: [AppoinmentModel]) -> [AppoinmentModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm aa"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let today = Date()
        
        var filteredModels = [AppoinmentModel]()
        
        for model in models {
            let dateString = model.reservedDate!.components(separatedBy: "T").first! + " " + model.reservedTimingFrom!
            if let date = dateFormatter.date(from: dateString), (Calendar.current.compare(date, to: today, toGranularity: .day) == .orderedSame
                || Calendar.current.compare(date, to: today, toGranularity: .day) == .orderedDescending) && !model.isAppointmentCancelled() {
                filteredModels.append(model)
            }
        }
        return filteredModels
    }
    
    class func sort(models: [AppoinmentModel]) -> [AppoinmentModel] {
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
    
    func isAppointmentCancelled() -> Bool {
        if let status = self.statusId {
            return status == AppoinmentModel.APPOINMENT_CANCELLED_BY_USER || status == AppoinmentModel.APPOINMENT_CANCELLED_BY_SHOP || status == AppoinmentModel.APPOINMENT_CANCELLATION_APPROVED || status == AppoinmentModel.APPOINMENT_CONFIRMED_NOT_ATTEND || status == AppoinmentModel.APPOINMENT_AUTO_CANCELLED
        }
        
        return false
    }
    
    public static let APPOINMENT_PENDING = 3
    public static let APPOINMENT_CANCELLED_BY_USER = 4
    public static let APPOINMENT_CONFIRMED = 1
    public static let APPOINMENT_CANCELLED_BY_SHOP = 5
    public static let APPOINMENT_CONFIRMED_NOT_ATTEND = 7
    public static let APPOINMENT_COMPLETED = 6
    public static let APPOINMENT_CANCELLATION_APPROVED = 2
    public static let APPOINMENT_AUTO_CANCELLED = 9
    public static let APPOINMENT_DELETED = 8
    public static let STANDALONE_PUSH_MESSAGE = 10
}
