//
//  ApiConstants.swift
//  GICMLearningApp
//
//  Created by Rafi on 25/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

let BASE_URL      = "http://cipldev.com/gicm/api/"  // http://cipldev.com/gicm/api/listCourse/


let LOGIN_API         = "login/"
let REGISTER_API      = "users/"
let LISTOFCOURSE_API  = "listCourse/"
let LISTOFQUOTES_API  = "getQuotes/"  //  registerfbtw
let LISTOFCOMMENT_API = "listComments/"
let ADDCOMMENT_API    = "AddComments/"
let DOWNLOADFILE_API  = "fileDownload"
let FBTWLOGIN_API     = "registerfbtw"
let LIKEQQUOTES       = "queteslikes"

//Project
let ADDPROJECT          = "add_project"
let EDITPROJECT         = "edit_project"
let DELETEPROJECT       = "delete_project/"
let LISTOFPROJECT       = "projects_list/"

//Tracking
let VALUEADDED              = "project_value_added"
let CHARTVALUEADDED         = "project_value_added_list"
let ADDWORKLIFE             = "work_life_balance"
let CHARTWORKLIFE           = "work_life_balance_list"
let ADDMEETINGPROJECT       = "add_metting"
let ADDCAREER               = "project_career"
let ADDMEETINGPROJECTLIST   = "add_metting_list"
let CAREERLIST              = "project_career_list"


//Profile
let EDITPROFILE             = "Editusers/"
let GETPROFILE              = "Getusers/"

let GETCOMPANYLIST          = "list_company"  
let POSTCAREERLEVEL         = "user_career_edit"

//File UPload
let FileReUpload            = "UserReupload/"



//Comment
let commentListProject          = "Project_listComments/"
let commentAddProject           = "Project_AddComments/"

let commentListTracking         = "Tracking_listComments/"
let commentAddTracking          = "Tracking_AddComments/"

let commentListProfile          = "Profile_listComments/"
let commentAddProfile           = "Profile_AddComments/"

let commentListReminder         = "Remainder_ListComment/"
let commentAddReminder          = "Remainder_AddComment/"

let commentListInviteFriends    = "InviteFriends_ListComment/"
let commentAddInviteFriends     = "InviteFriends_AddComment/"

let commentListResource         = "Resource_ListComment/"
let commentAddResource          = "Resource_AddComment/"

let logOut                      = "logout"
//Call4Back
let reqCall4Backup           = ""
let listOfCall4Backup        = ""
let deleteCall4Backup        = ""


enum URLApi : CustomStringConvertible{
    
    case register
    case login
    case listCourse
    case listQuotes
    case listCommnet
    case addComment
    case fileDownload
    case loginFBTW
    case likeQuotes
    case LOGOUT
    //Project
    case addProject
    case editProject
    case deleteProject
    case listProject
    
    //Value Added
    case addValueAdded
    case chartOfValueAdded
    
    //Work Life Balance
    case addWorkLifeBalance
    case chartOfWorkLifeBalance
    
    //Add Meeting and Career
    case addMeeting
    case addCareer
    case addMeetingList
    case careerList
  
    //Profile
    case editProfile
    case getProfile
    
    //Company
    case getCompanyList
    case postCareerLevel
    case fileUpload
    
    
    //
    case getProjectCommentList
    case postProjectComment
    case getTrackingCommentList
    case postTrackingComment
    case getProfileCommentList
    case postProfileComment
    case getReminderCommentList
    case postReminderComment
    case getResourceCommentList
    case postResourceComment
    case getInviteFriendsCommentList
    case postInviteFriendsComment
    
    var description: String{
        switch self {
        case .register:
            return "\(BASE_URL)\(REGISTER_API)"
        case .login:
            return "\(BASE_URL)\(LOGIN_API)"
        case .listCourse:
            return "\(BASE_URL)\(LISTOFCOURSE_API)"
        case .listQuotes:
            return "\(BASE_URL)\(LISTOFQUOTES_API)"
        case .listCommnet:
            return "\(BASE_URL)\(LISTOFCOMMENT_API)"
        case .addComment:
            return "\(BASE_URL)\(ADDCOMMENT_API)"
        case .fileDownload:
            return "\(BASE_URL)\(DOWNLOADFILE_API)"
        case .loginFBTW:
        return "\(BASE_URL)\(FBTWLOGIN_API)"
        case .likeQuotes:
            return "\(BASE_URL)\(LIKEQQUOTES)"
        //Project
        case .addProject:
            return "\(BASE_URL)\(ADDPROJECT)"
        case .deleteProject:
            return "\(BASE_URL)\(DELETEPROJECT)"
        case .editProject:
            return "\(BASE_URL)\(EDITPROJECT)"
        case .listProject:
            return "\(BASE_URL)\(LISTOFPROJECT)"
            
        //Value Added
        case .addValueAdded:
            return "\(BASE_URL)\(VALUEADDED)"
        case .chartOfValueAdded:
            return "\(BASE_URL)\(CHARTVALUEADDED)"
          
        //Work Life Balance
        case .addWorkLifeBalance:
            return "\(BASE_URL)\(ADDWORKLIFE)"
        case .chartOfWorkLifeBalance:
            return "\(BASE_URL)\(CHARTWORKLIFE)"
            
        case .addMeeting:
            return "\(BASE_URL)\(ADDMEETINGPROJECT)"
        case .addMeetingList:
            return "\(BASE_URL)\(ADDMEETINGPROJECTLIST)"
            
        case .addCareer:
            return "\(BASE_URL)\(ADDCAREER)"
        case .careerList:
            return "\(BASE_URL)\(CAREERLIST)"
          
        case .editProfile:
          return "\(BASE_URL)\(EDITPROFILE)"
        case .getProfile:
          return "\(BASE_URL)\(GETPROFILE)"
            
        case.getCompanyList:
            return "\(BASE_URL)\(GETCOMPANYLIST)"
        case.postCareerLevel:
            return "\(BASE_URL)\(POSTCAREERLEVEL)"
            
        case .fileUpload:
            return "\(BASE_URL)\(FileReUpload)"
        case .getProjectCommentList:
            return "\(BASE_URL)\(commentListProject)"
        case .postProjectComment:
            return "\(BASE_URL)\(commentAddProject)"
            
        case .getTrackingCommentList:
            return "\(BASE_URL)\(commentListTracking)"
        case .postTrackingComment:
            return "\(BASE_URL)\(commentAddTracking)"
        case .getProfileCommentList:
            return "\(BASE_URL)\(commentListProfile)"
        case .postProfileComment:
            return "\(BASE_URL)\(commentAddProfile)"
        case .getReminderCommentList:
            return "\(BASE_URL)\(commentListReminder)"
        case .postReminderComment:
            return "\(BASE_URL)\(commentAddReminder)"
        case .getResourceCommentList:
            return "\(BASE_URL)\(commentListResource)"
        case .postResourceComment:
            return "\(BASE_URL)\(commentAddResource)"
        case .getInviteFriendsCommentList:
            return "\(BASE_URL)\(commentListInviteFriends)"
        case .postInviteFriendsComment:
            return "\(BASE_URL)\(commentAddInviteFriends)"
        case .LOGOUT:
            return "\(BASE_URL)\(logOut)"
        }
    }
        
}

