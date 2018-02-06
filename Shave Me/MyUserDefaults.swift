//
//  MyUserDefaults.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit

public final class MyUserDefaults {
    public static let PREFS_LANGUAGE = "language"
    public static let PREFS_USER = "userInfo"
    public static let PREFS_BARBER = "barber"
    public static let PREFS_INTIALIMAGE = "intialimage"
    public static let PREFS_REMEMBERME = "rememberme"
    public static let PREFS_BARBERREMEMBERME = "barberrememberme"
    public static let PREFS_PASS = "pass"
    public static let PREFS_ISLOGGEDIN = "userStatus"
    public static let PREFS_ISBARBERLOGGEDIN = "barberStatus"
    public static let PREFS_GCMREGISTRATIONID = "gcmkey"
    public static let PREFS_APPVERSION = "appversion"
    public static let PREFS_PUSH_NOTIFICATIONS_COUNT = "push_notifications_count"
    public static let PREFS_SHOW_HELP = "showhelp"
    
    func set(key: String, value: Any?) {
        let defaults = MyUserDefaults.getDefaults()
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    static func getDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    public static func getSelectedLanguage() -> String? {
        return getDefaults().string(forKey: PREFS_LANGUAGE)
    }
    
    public static func getLoggedInUser() -> String? {
        return getDefaults().string(forKey: PREFS_USER)
    }
    
    public static func getGCMRegistrationId() -> String? {
        return getDefaults().string(forKey: PREFS_GCMREGISTRATIONID)
    }
    
    public static func getLoggedInBarber() -> String? {
        return getDefaults().string(forKey: PREFS_BARBER)
    }
    
    public static func getShowHelpScreen() -> Bool {
        getDefaults().register(defaults: [PREFS_SHOW_HELP : true])

        return getDefaults().bool(forKey: PREFS_SHOW_HELP)
    }
}
