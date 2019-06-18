//
//  ApplyViewModel.swift
//  GICMLearningApp
//
//  Created by CIPL0449 on 21/02/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import Foundation
import Instabug
import SwipeCellKit


enum appVersions : String{
    case weeklyPlan      = "1.4"
    case meetingManager  = "1.5"
    case tracking        = "1.6"
    case capture         = "1.3"
}

// Navigation based on the versions
extension ApplyVC{
    func navigationOptionMethod(strSeletedType: String, appVersion: String){
        let version = appVersions.init(rawValue: appVersion)
        switch version {
        case .weeklyPlan?:
            navigateToWeeklyPlanner(strTracking: strSeletedType)
        case .meetingManager?:
            self.navigateToMeetingmanager(strTracking: strSeletedType)
        case .tracking?:
            navigateToTracking(strTracking: strSeletedType)
        case .capture?:
            navigateToCapture(strTracking: strSeletedType)
        default:
            print("Default")
        }
    }
    
    //Tracking
    func navigateToTracking(strTracking: String){
        if strTracking == "Tracking"{
            let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
            let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else{
            Utilities.sharedInstance.showToast(message: "Development in progress")
        }
    }
    
    //Meeting manager
    func navigateToMeetingmanager(strTracking: String){
        if strTracking == "Meeting Manager"{
            let loginValue = UserDefaults.standard.string(forKey: "Login")
            
            if loginValue == "0"
            {
                let email = UserDefaults.standard.getEmail()
                if email.isEmpty{
                    self.vwEmail.isHidden = false
                    self.txtEmail.text = ""
                }else{
                    let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                    let nextVC = story.instantiateViewController(withIdentifier: "MeetingConfigVC") as! MeetingConfigVC
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
                //self.showLoginAlert()
            }else if(ReachabilityManager.isConnectedToNetwork() == false)
            {
                self.showInternetAlert()
            }
            else{
                let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                let nextVC = story.instantiateViewController(withIdentifier: "MeetingConfigVC") as! MeetingConfigVC
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
        }else{
            Utilities.sharedInstance.showToast(message: "Development in progress")
        }
    }
    
    //WeeklyPlanner
    func navigateToWeeklyPlanner(strTracking: String){
        if strTracking == "Weekly planner"{
            let story = UIStoryboard(name: "WeeklyPlanner", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "WeeklyPlannerListVC") as! WeeklyPlannerListVC
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else{
            Utilities.sharedInstance.showToast(message: "Development in progress")
        }
    }
    
    //Capture
    func navigateToCapture(strTracking: String){
        if strTracking == "Capture"{
            let loginValue = UserDefaults.standard.string(forKey: "Login")
            if loginValue == "0"
            {
                let email = UserDefaults.standard.getEmail()
                if email.isEmpty{
                    self.vwEmail.isHidden = false
                    self.txtEmail.text = ""
                }else{
                    let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                    let nextVC = story.instantiateViewController(withIdentifier: "CaptureVC") as! CaptureVC
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }else if(ReachabilityManager.isConnectedToNetwork() == false)
            {
                self.showInternetAlert()
            }
            else{
                let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                let nextVC = story.instantiateViewController(withIdentifier: "CaptureVC") as! CaptureVC
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }else{
            Utilities.sharedInstance.showToast(message: "Development in progress")
        }
    }
}


extension ApplyVC:UITableViewDelegate,UITableViewDataSource{
    //MARK:- Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyCell", for: indexPath) as! ApplyCell
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.4"
        cell.selectionStyle = .none
        let title = self.arrTitle![indexPath.row]
        cell.imgView.image = UIImage(named: title)
        cell.configUI(strTitle: title, indexPath: indexPath)
        cell.changeUIBackGround(strAppVersion: version, strTitle: title)
        
        cell.delegate = self as? SwipeTableViewCellDelegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.4"
        let selected = self.arrTitle![indexPath.row]
        
        // Meeting manager
        if selected == "Meeting Manager"{
            if self.walletModelObj?.meeting?.count == 0{
               // self.buyToolsAlert(strToolsType: selected, amount: 5)
                self.updateWalletDetails(toolsType: selected, amount: 50)
            }else{
                guard let strDate = self.walletModelObj?.meeting else{
                   // self.buyToolsAlert(strToolsType: selected, amount: 5)
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                    return
                }
                let days = self.getNoOfDaysBeforeBought(strDate: strDate)
                
                if days > 1 {
                   // self.buyToolsAlert(strToolsType: selected, amount: 5)
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                }else{
                    self.navigateToMeetingmanager(strTracking: selected)
                }
            }
            
        }else if selected == "Tracking"{
            
            
            if self.walletModelObj?.tracking?.count == 0{
                //self.buyToolsAlert(strToolsType: selected, amount: 5)
                self.updateWalletDetails(toolsType: selected, amount: 50)
            }else{
                guard let strDate = self.walletModelObj?.tracking else{
                   // self.buyToolsAlert(strToolsType: selected, amount: 5)
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                    return
                }
                let days = self.getNoOfDaysBeforeBought(strDate: strDate)
                if days > 1 {
                    //self.buyToolsAlert(strToolsType: selected, amount: 5)
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                    // Utilities.sharedInstance.showToast(message: "your subcribtion plan closed")
                }else{
                    self.navigateToTracking(strTracking: selected)
                }
            }
        }else if selected == "Weekly planner"{
            if self.walletModelObj?.weeklyPlanner?.count == 0{
                // Utilities.sharedInstance.showToast(message: "Do you want to buy weekly planner")
               // self.buyToolsAlert(strToolsType: selected, amount: 5)
                self.updateWalletDetails(toolsType: selected, amount: 50)
            }else{
                guard let strDate = self.walletModelObj?.weeklyPlanner else{
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                    return
                }
                let days = self.getNoOfDaysBeforeBought(strDate: strDate)
                
                if days > 1 {
                    // Utilities.sharedInstance.showToast(message: "your subcribtion plan closed")
                    //self.buyToolsAlert(strToolsType: selected, amount: 5)
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                }else{
                    self.navigateToWeeklyPlanner(strTracking: selected)
                }
            }
        }else if selected == "Capture"{
            if self.walletModelObj?.capture?.count == 0{
                // Utilities.sharedInstance.showToast(message: "Do you want to buy weekly planner")
                //self.buyToolsAlert(strToolsType: selected, amount: 5)
                self.updateWalletDetails(toolsType: selected, amount: 50)
            }else{
                guard let strDate = self.walletModelObj?.capture else{
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                    //self.buyToolsAlert(strToolsType: selected, amount: 5)
                    return
                }
                let days = self.getNoOfDaysBeforeBought(strDate: strDate)
                if days > 1 {
                    // Utilities.sharedInstance.showToast(message: "your subcribtion plan closed")
                   // self.buyToolsAlert(strToolsType: selected, amount: 5)
                    self.updateWalletDetails(toolsType: selected, amount: 50)
                }else{
                   self.navigateToCapture(strTracking: selected)
                }
            }
        }else{
           // Utilities.sharedInstance.showToast(message: "Development in progress")
            let story = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "BreathVC") as! BreathVC
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        // self.navigationOptionMethod(strSeletedType: selected, appVersion: appVersion)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func showLoginAlert() {
        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.update_mail)!)
    }
    func showInternetAlert() {
        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.connect)!)
    }
}

extension ApplyVC: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            print("Delete")
            let value = self.arrTitle![indexPath.row]
            self.arrTitle = self.arrTitle?.filter{$0 != value}
            UserDefaults.standard.set(self.arrTitle, forKey: "ApplyList")
            UserDefaults.standard.set(true, forKey: "ApplyAdded")
            UserDefaults.standard.synchronize()
            self.tblApply.reloadData()
            
            //            var arrApplyList = UserDefaults.standard.array(forKey: "ApplyList") as? [String]
            //            if (arrApplyList?.contains(strNewElement))!{
            //                print("Already Added \(strNewElement)")
            //                //self.navigationController?.popViewController(animated: true)
            //                Utilities.sharedInstance.showToast(message: "Already Added")
            //            }else{
            //                arrApplyList?.append(strNewElement)
            //                let arrApplyList = arrApplyList
            //                UserDefaults.standard.set(true, forKey: "ApplyAdded")
            //                UserDefaults.standard.set(arrApplyList, forKey: "ApplyList")
            //                UserDefaults.standard.synchronize()
            //                self.navigationController?.popViewController(animated: true)
            //            }}
        }
        // customize the action appearance
        deleteAction.backgroundColor = UIColor.red
        deleteAction.textColor = UIColor.black
        return [deleteAction]
    }
}


extension ApplyVC{
    //MARK:- Get Wallet Details
    func getWalletdetails(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("wallet").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID())
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                // if exist update
                let walletObj = walletModel()
                self.walletModelObj = walletObj.parseIntoModel(snap: snap)
            }
            else{
                //Add
            }
        }
    }
}


extension ApplyVC{
    
    
    func buyToolsAlert(strToolsType: String, amount: Int){
        Utilities.showAlertOkandCancelWithDismiss(title: "Attention!", okTitile: "Ok", cancelTitle: "Cancel", message: "Do you want to buy \(strToolsType)", controller: self, alertDismissed: { success in
            if success{
                print("Buy Tool \(strToolsType)")
                self.updateWalletDetails(toolsType: strToolsType, amount: amount)
            }else{
                print("Cancel")
            }
        })
    }
    
    // Update Wallet details
    func updateWalletDetails(toolsType: String, amount: Int){
        let ref = FirebaseManager.shared.firebaseDP!.collection("wallet").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID())
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for i in 0 ..< snap.count {
                    let refExist = FirebaseManager.shared.firebaseDP!.collection("wallet").document(snap[i].documentID)
                    let appDelegateRef = UIApplication.shared.delegate as! AppDelegate
                    let currentWalletValue = Int(self.walletModelObj!.walletAmount!)!-amount
                    
                    if currentWalletValue <= 0{
                        Utilities.sharedInstance.showToast(message: "your wallet amount is less than zero please add amount in wallet")
                    }
                    
                    var appUsedDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let strDate = dateFormatter.string(from: appUsedDate)
                    print(strDate)
                    
                    if toolsType == "Capture"{
                        refExist.updateData(["capture" : strDate,"walletAmount": "\(currentWalletValue)"])
                        self.navigateToCapture(strTracking: toolsType)
                    }else if toolsType == "Meeting Manager"{
                        refExist.updateData(["meeting" : strDate,"walletAmount": "\(currentWalletValue)"])
                        self.navigateToMeetingmanager(strTracking: toolsType)
                    }else if toolsType == "Tracking"{
                        refExist.updateData(["tracking" : strDate,"walletAmount": "\(currentWalletValue)"])
                        self.navigateToTracking(strTracking: toolsType)
                    }else if toolsType == "Weekly planner"{
                        refExist.updateData(["weeklyPlanner" : strDate,"walletAmount": "\(currentWalletValue)"])
                        self.navigateToWeeklyPlanner(strTracking: toolsType)
                    }
                }
            }
            self.getWalletdetails()
        }
    }
    
    //MARK:- Get No of date
    func getNoOfDaysBeforeBought(strDate: String) -> Int{
        var appUsedDate = Date()
        let strDate = strDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        appUsedDate = dateFormatter.date(from: strDate)!
        
        let noOfDays = appUsedDate.daysBetweenDate(toDate: Date())
        return noOfDays
    }
   
}

