//
//  RequestResult.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class RequestResult : Mappable {
    var status: RequestStatus?
    var value: Any?
    
    required init?(map: Map) {
        
    }
    
    init(message: String?, code: String) {
        status = RequestStatus(message: message, code: code)
    }
    
    init(message: String?) {
        status = RequestStatus(message: message, code: RequestStatus.CODE_FAIL)
    }
    
    init(value: Any?) {
        status = RequestStatus(message: "success", code: RequestStatus.CODE_OK)
        self.value = value
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        value <- map["value"]
    }
}
