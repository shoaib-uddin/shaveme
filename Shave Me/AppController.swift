//
//  AppController.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import ObjectMapper
import GoogleMaps
import RealmSwift
import ReachabilitySwift

public final class AppController: NSObject, CLLocationManagerDelegate {
    public static let sharedInstance: AppController = AppController()
    //declare this property where it won't go out of scope relative to your listener
    let reachability = Reachability()!
    
    let placeHolderImage = #imageLiteral(resourceName: "imagefetcher")
    
    // Get the default Realm
    internal let realm = try! Realm()
    internal var cachedHomeBannerModel: HomeBannerModel?
    internal var cachedServices: [SyncServiceModel]?
    internal var cachedFacilities: [SyncFacilitiesModel]?
    internal var currenLocation: CLLocation?
    
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private var _pushNotificationsDeviceToken: String?
    internal var pushNotificationsDeviceToken : String? {
        set {
            MyUserDefaults.getDefaults().set(newValue, forKey: MyUserDefaults.PREFS_GCMREGISTRATIONID)
            _pushNotificationsDeviceToken = newValue
        }
        get {
            if let token = _pushNotificationsDeviceToken {
                return token
            } else if let token = MyUserDefaults.getGCMRegistrationId() {
                _pushNotificationsDeviceToken = token
                return token
            }
            return nil
        }
    }
    
    private var _language: String?
    internal var language : String {
        set {
            MyUserDefaults.getDefaults().set(newValue, forKey: MyUserDefaults.PREFS_LANGUAGE)
            _language = newValue
        }
        get {
            if let lang = _language {
                return lang
            } else if let lang = MyUserDefaults.getSelectedLanguage() {
                _language = lang
                return lang
            }
            return "en"
        }
    }
    
    private var _loggedInUser: UserModel?
    internal var loggedInUser : UserModel? {
        set {
            let userString = newValue == nil ? nil : newValue?.toJSONString()
            MyUserDefaults.getDefaults().set(userString, forKey: MyUserDefaults.PREFS_USER)
            _loggedInUser = newValue
        }
        get {
            if let user = _loggedInUser {
                return user
            } else if let userString = MyUserDefaults.getLoggedInUser() {
                _loggedInUser = Mapper<UserModel>().map(JSONString: userString)
                return _loggedInUser
            }
            return nil
        }
    }

    private var _loggedInBarber: BarberLoginModel?
    internal var loggedInBarber : BarberLoginModel? {
        set {
            let string = newValue == nil ? nil : newValue?.toJSONString()
            MyUserDefaults.getDefaults().set(string, forKey: MyUserDefaults.PREFS_BARBER)
            _loggedInBarber = newValue
        }
        get {
            if let barber = _loggedInBarber {
                return barber
            } else if let string = MyUserDefaults.getLoggedInBarber() {
                _loggedInBarber = Mapper<BarberLoginModel>().map(JSONString: string)
                return _loggedInBarber
            }
            return nil
        }
    }
    
    func isLanguageInitialized() -> Bool {
        return _language != nil || MyUserDefaults.getSelectedLanguage() != nil
    }
    
    // Handle incoming location events.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currenLocation = locations.last
    }
    
    // Handle authorization for the location manager.
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
