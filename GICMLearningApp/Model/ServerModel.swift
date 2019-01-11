//
//  ServerModel.swift
//  MTopo
//
//  Created by CIPL137-MOBILITY on 13/02/17.
//  Copyright © 2017 Colan Infotech Pvt Ltd. All rights reserved.
//

import UIKit

class ServerModel: NSObject {
    
    static var serverModelInstance = ServerModel()

    var statusCode  : Int    = 0
    var status      : String  = ""
    var message     : String    = ""
    
    
    func parseServerResponse(response : Dictionary<String, Any>){
        status =   response["status"] as! String
        message =   response["message"] as! String
        statusCode = response["response_code"] as! Int 
    }
}
