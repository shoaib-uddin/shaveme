//
//  RequestStatus.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class RequestStatus: Mappable {
    public static let CODE_OK = "OK"
    public static let CODE_FAIL = "FAIL"
    public static let CODE_NO_INTERNET_CONNECT = "NO_INTERNET_CONNECT"
    
    var message: String?
    var code: String?
    
    required init?(map: Map) {
        
    }
    
    init(message: String?, code: String) {
        self.message = message
        self.code = code
    }
    
    func mapping(map: Map) {
        message <- map["message"]
        code <- map["code"]
    }
}
