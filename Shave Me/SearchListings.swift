//
//  SearchListings.swift
//  Shave Me
//
//  Created by NoorAli on 12/20/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class SearchListings: Mappable {
    public static let SEARCH_BY_NAME = 0
    public static let SEARCH_BY_ADRESS = 1
    public static let SEARCH_BY_LOCATION = 2
    public static let SEARCH_BY_ADVANCED = 3
    
    var baseUrl: String = ""
    var Shop: [SearchModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        baseUrl <- map["baseUrl"]
        Shop <- map["Shop"]
    }
}
