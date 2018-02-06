//
//  ShopListingSearchModel.swift
//  Shave Me
//
//  Created by NoorAli on 12/21/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit

class ShopListingSearchModel: NSObject {
    var FACILITISID = ""
    var SERVICEIDS = ""
    var COSTTO = ""
    var COSTFROM = ""
    var DISTFROM = ""
    var DISTTO = ""
    var LAT = ""
    var LON = ""
    var ADDRESS = ""
    var NAME = ""
    
    init(name: String) {
        NAME = name
    }
    
    init(lat: String, lon: String) {
        LAT = lat
        LON = lon
    }
    
    init(name: String, facilitiesID: String, servicesID: String, costTo: String, costFrom: String, distTo: String, distFrom: String) {
        NAME = name
        FACILITISID = facilitiesID
        SERVICEIDS = servicesID
        COSTTO = costTo
        COSTFROM = costFrom
        DISTFROM = distFrom
        DISTTO = distTo
    }
}
