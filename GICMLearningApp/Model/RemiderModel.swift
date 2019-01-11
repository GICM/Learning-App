//
//  RemiderModel.swift
//  GICM
//
//  Created by Rafi on 10/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import CoreLocation

class ReminderModel:NSObject {
    var isTime :Bool = false
    var reminderId = ""
    var descr:String = ""
    var repeatEveryState:[Bool] = []
    var repeatEveryLbl:String = ""
    var isReminderOn :Bool = false
    var arrayLocalNotificIdentifers:[String] = []
    var addressLocation:String = ""
    var latitude:String = ""
    var longitude:String = ""
    var title:String = ""
    var body:String = ""
    var subtitle:String = ""
    var isStatic:Bool = false
    var isArriving:Bool = true
    var type:String = "0"

}
