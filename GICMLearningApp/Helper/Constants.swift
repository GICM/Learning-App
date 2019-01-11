//
//  Shared.swift
//  IMS
//
//  Created by Rafi on 12/04/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class Constants: NSObject {
  
  static let appDelegateRef : AppDelegate = AppDelegate.getAppdelegateInstance()!
  static var LAST_SELECTED_INDEX_N_PICKER = 0
  static let PICKER_TOP_COLOR     = UIColor(red: 89.0/255.0, green: 90.0/255.0, blue: 184.0/255.0, alpha: 1.0)
  
    static func getCustomBlueColor() -> UIColor{
        return UIColor(red:73/255, green:139/255 ,blue:206/255 , alpha:1.00)
    }
    
  struct StoryboardIdentifier {
    
    static let loginVC   = "Login"
    static let createVC  = "Create"
    static let tabbar    = "Tabbar"
    static let profile   = "Profile"
    static let interview = "InterviewPreparation"
    static let addLearning = "AddLearning"
    static let showContent = "ShowContent"
  }
  
  struct ErrorMessage {
    
    static let email         = "Please enter E-mail address"
    static let vaildemail    = "Please enter vaild E-mail address"
    static let password      = "Please enter password"
    static let usermame      = "Please enter Username"
    static let cnfPassword   = "Please enter confirm password"
    static let samePassword  = "Please enter  confirm password should be same as password"
    static let meetingName   = "Please enter  Meeting Name"

    //Project
    static let project         = "Please enter project Name"
    static let clientName    = "Please enter client name"
    static let startdate      = "Please select start date"
    static let enddate      = "Please select end date"
  }
  
    
    struct AWS {
        static let POOL_ID = "ap-south-1:eac421d4-d153-4f90-89e0-c9339a3e54d0"
        static let Bucket_Name = "findtyreferenceimages"
        static let Region = "AP-SOUTH-1"
    }
    
    
    struct API_KEY {
        static let OCRKey = "AIzaSyDf2fdX0jo07EXk8BS6A-h_dXEJqCaOkQ4"// "AIzaSyC-m-wEe25UYoQdq9Arj5wim3Ubvc8_Atw" //"AIzaSyB9a9D3YJHxJqUCxepNT_tflt9TjdraLbo"// // TyerPier
    }
    
    struct API {
        
        static let google_vision_baseURL = "https://vision.googleapis.com/v1/images:annotate?key="
        static let baseUrl = "http://cipldev.com/tirebuyer/"
           }
    
    struct GOOGLE_CSE {
        static let google_CSE_baseURL = "https://www.googleapis.com/customsearch/v1?q="
        static let google_CSE_key = "&key=AIzaSyC-m-wEe25UYoQdq9Arj5wim3Ubvc8_Atw"
        static let google_CSE_ID = "&cx=002363841751425371398:e8bmdmg3v6g"
        static let google_CSE_PageNO = "&start="
    }
    
    struct RESPONSE_KEY {
        static let status = "status"
        static let message = "message"
        static let userNmae = "username"
        static let email = "email"
    }
    
    struct RESPONSE {
        static let success = "success"
    }
    
    
    struct GOOGLE_CSE_KEY {
        static let items = "items"
        static let pagemap = "pagemap"
        static let title = "title"
        static let link = "link"
        static let snippet = "snippet"
        static let cse_image = "cse_image"
        static let src = "src"
        static let error = "error"
        static let errors = "errors"
        static let message = "message"
        static let errorMessage = "No information is available for this tyre"
    }


}
