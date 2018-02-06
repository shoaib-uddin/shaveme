//
//  MyDatabase.swift
//  Shave Me
//
//  Created by NoorAli on 12/22/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import RealmSwift

class DBFacility: Object {
    dynamic var id = 0
    dynamic var icon = 0
    dynamic var name = ""
}

class DBService: Object {
    dynamic var id = 0
    dynamic var icon = 0
    dynamic var name = ""
    dynamic var mDescription = ""
}

class DBSyncInfo: Object {
    dynamic var id = 0
    dynamic var lastUpdatedDate = NSDate()
}

class DBFavorite: Object {
    dynamic var barberId = 0
    dynamic var isLiked = false
    dynamic var isUpdated = false
    
    override static func primaryKey() -> String? {
        return "barberId"
    }
    
    class func isFavourite(barberId: Int) -> Bool {
        let realm = AppController.sharedInstance.realm
        
        // Query Realm
        let predicate = NSPredicate(format: "barberId == %D AND isLiked == %@", barberId, NSNumber(booleanLiteral: true))
        let favourites = realm.objects(DBFavorite.self).filter(predicate)
        return favourites.count > 0
    }
    
    class func getBy(isLiked: Bool, isUpdated: Bool) -> Results<DBFavorite> {
        let predicate = NSPredicate(format: "isUpdated == %@ AND isLiked == %@", NSNumber(booleanLiteral: isUpdated), NSNumber(booleanLiteral: isLiked))
        return AppController.sharedInstance.realm.objects(DBFavorite.self).filter(predicate)
    }
    
    class func getBy(barberId: Int) -> DBFavorite? {
        let predicate = NSPredicate(format: "barberId == %D", barberId)
        return AppController.sharedInstance.realm.objects(DBFavorite.self).filter(predicate).first
    }
    
    class func getBy(commaSeparatedBarberIDs: String) -> Results<DBFavorite> {
        let predicate = NSPredicate(format: "barberId IN %@", commaSeparatedBarberIDs)
        return AppController.sharedInstance.realm.objects(DBFavorite.self).filter(predicate)
    }
    
    class func addUpdate(barberID: Int, isLiked: Bool, isUpdated: Bool = true) {
        let realm = AppController.sharedInstance.realm

        var favourite = getBy(barberId: barberID)
        if favourite == nil {
            favourite = DBFavorite()
            favourite?.barberId = barberID
        }
        
        // Add to the Realm inside a transaction
        try! realm.write {
            favourite?.isUpdated = isUpdated
            favourite?.isLiked = isLiked
            
            realm.add(favourite!, update: true)
        }
    }
    
    class func deleteAll() {
        let realm = AppController.sharedInstance.realm
        
        try! realm.write {
            let favorites = realm.objects(DBFavorite.self)
            realm.delete(favorites)
        }
    }
}

class DBAppointmentCalendarIds: Object {
    dynamic var AppoinmentId = 0
    dynamic var EventId = 0
    dynamic var ReminderId = 0
}

class DBRateUser: Object {
    dynamic var AppoinmentId = 0
    dynamic var AppoinmentModel = ""
}





