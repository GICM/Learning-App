//
//  LeaderModel.swift
//  GICM
//
//  Created by CIPL0449 on 4/26/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit
import Firebase

class LeaderModel: NSObject {
    var user_id : String?
    var username : String?
    var user_picture : String?
    var companyName : String?
    var engagementData : engagementModel?
    var contributionData : contributionModel?
    
    class engagementModel{
        var course : String?
        var tracking : String?
        var capture : String?
        var meeting : String?
        var weeklyPlanner : String?
        var totalScore : Double?
    }
    
    class contributionModel{
        var totalScore : Double?
    }
    
    func parseIntoLeaderModel(snap:[QueryDocumentSnapshot]) -> LeaderModel{
        let leaderModel = LeaderModel()
        for obj in snap{
            leaderModel.user_id = obj["user_id"] as? String ?? ""
            leaderModel.username = obj["username"] as? String ?? ""
            leaderModel.user_picture = obj["user_Picture"] as? String ?? ""
            leaderModel.companyName = obj["companyName"] as? String ?? ""
            
            let  engeModel = engagementModel()
            let conModel = contributionModel()
            
            // Engagement
            let engageDataObj: [String: Any] = obj["engagement"] as? [String: Any] ?? [String:Any]()
            
            engeModel.tracking = engageDataObj["tracking"] as? String ?? ""
            engeModel.capture = engageDataObj["capture"] as? String ?? ""
            engeModel.meeting = engageDataObj["meeting"] as? String ?? ""
            engeModel.weeklyPlanner = engageDataObj["weeklyPlanner"] as? String ?? ""
            engeModel.totalScore = engageDataObj["totalScore"] as? Double ?? 0.0
            
            // Contribution
            let contributionDataObj: [String: Any] = obj["Contribution"] as? [String: Any] ?? [String:Any]()
            conModel.totalScore = contributionDataObj["totalScore"] as? Double ?? 0.0
            
            leaderModel.engagementData = engeModel
            leaderModel.contributionData = conModel
        }
        return leaderModel
    }
    
    
    func parseIntoListOfLeaderModel(snap:[QueryDocumentSnapshot]) -> [LeaderModel]{
        var arrListLeaderModel = [LeaderModel]()
        for obj in snap{
            let leaderModel = LeaderModel()
            leaderModel.user_id = obj["user_id"] as? String ?? ""
            leaderModel.username = obj["username"] as? String ?? ""
            leaderModel.user_picture = obj["user_Picture"] as? String ?? ""
            leaderModel.companyName = obj["companyName"] as? String ?? ""
            
            let engeModel = engagementModel()
            let conModel = contributionModel()
            
            // Engagement
            let engageDataObj: [String: Any] = obj["engagement"] as? [String: Any] ?? [String:Any]()
            
            engeModel.tracking = engageDataObj["tracking"] as? String ?? ""
            engeModel.capture = engageDataObj["capture"] as? String ?? ""
            engeModel.meeting = engageDataObj["meeting"] as? String ?? ""
            engeModel.weeklyPlanner = engageDataObj["weeklyPlanner"] as? String ?? ""
            engeModel.totalScore = engageDataObj["totalScore"] as? Double ?? 0.0
            
            // Contribution
            let contributionDataObj: [String: Any] = obj["Contribution"] as? [String: Any] ?? [String:Any]()
            conModel.totalScore = contributionDataObj["totalScore"] as? Double ?? 0.0
            
            leaderModel.engagementData = engeModel
            leaderModel.contributionData = conModel
            arrListLeaderModel.append(leaderModel)
        }
        return arrListLeaderModel
        
    }
    /*
    let emptyDict = [String: Any]()
    let dictEngagement = ["tracking": "\(score)",
        "capture": "",
        "meeting": "",
        "weeklyPlanner": "",
        "totalScore": "\(score)"] as [String: String]
    let dict = ["user_id" : userId,
                "username" : userName ?? "Anonymous",
                "user_Picture" : profile ?? "",
                "companyName" : currentCompany ?? "Other",
                "Contribution" : emptyDict,
                "engagement" : dictEngagement] as [String : Any]
     
     func parseIntoModel(snap:[QueryDocumentSnapshot]) -> walletModel{
     let walletModelObj = walletModel()
     for obj in snap{
     walletModelObj.userID = obj["user_id"] as? String ?? ""
     walletModelObj.walletAmount = obj["walletAmount"] as? String ?? ""
     walletModelObj.capture = obj["capture"] as? String ?? ""
     walletModelObj.meeting = obj["meeting"] as? String ?? ""
     walletModelObj.tracking = obj["tracking"] as? String ?? ""
     walletModelObj.course = obj["course"] as? String ?? ""
     walletModelObj.weeklyPlanner = obj["weeklyPlanner"] as? String ?? ""
     
     
     //Store Wallet Details
     let wallet = obj["walletAmount"] as? String ?? ""
     UserDefaults.standard.set(wallet, forKey: "walletAmount")
     UserDefaults.standard.synchronize()
     
     }
     return walletModelObj
     }
     */
}


