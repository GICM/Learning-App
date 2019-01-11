//
//  PhoneContactModel.swift
//  GICM
//
//  Created by Rafi on 24/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import ContactsUI

struct PhoneContactModel {
    var name:String
    var avatarData:Data
    var phoneNumber:[PhoneNoModel]
    var emailID:[EmailIDModel]
    var familyName:String

}

struct PhoneNoModel {
    var name:String
    var phoneNo:String
}

struct EmailIDModel {
    var name:String
    var emailID:String
}

struct InviteModel {
    var inviteId:String
    var invitedBy:String
    var inviteMail:String
    var invitedName:String
    var inviteStatus:String
    var inviteUserID:String
    var inviteUserName:String
}
