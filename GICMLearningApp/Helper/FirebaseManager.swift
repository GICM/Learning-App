//
//  FirebaseManager.swift
//  GICMLearningApp
//
//  Created by Rafi on 21/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import os.log


class FirebaseManager: NSObject {
    static let shared = FirebaseManager()
    var firebaseDP : Firestore?
    typealias onUpdateReminder = () -> Void
    typealias onCheckReminder = (Bool) -> Void
    var onCompleteShync : (()->Void)?
    
    var count = 0
    var progress : UIProgressView?
    var progressView : UIView?
    var countDelete = 0
    var countTotal = 0
    var progressCount = 0
    var toastMsgs : ToastMessages = ToastMessages()
   
    
    func firebaseConfigure() {
        
        FirebaseApp.configure()
        firebaseDP = Firestore.firestore()
        let settings = firebaseDP!.settings
        settings.areTimestampsInSnapshotsEnabled = true
        settings.isPersistenceEnabled = true
        firebaseDP!.settings = settings
        
//        Auth.auth().signInAnonymously() { (authResult, error) in
//            let user = authResult?.user
//            let isAnonymous = user?.isAnonymous  // true
//            let uid = user?.uid
//        }
        
        Auth.auth().signInAnonymously() { (user, error) in
            if let aUser = user {
                //Do something cool!
                print(aUser)
            }
        }
    }
    
    func localLocationReminder(userID:String) -> [String : Any]{
        let appDelegateRef = UIApplication.shared.delegate as! AppDelegate
        
        let dict =        ["title": "In-Transit:",
                           "reminderId":"0",
                           "isReminderOn": true,
                           "addressLocation": "4/7, Anna Salai,Chennai, Tamil Nadu 600002",
                           "user_id" : userID,
                           "user_UUID" : appDelegateRef.userUUID!,
                           "isTime":false,
                           "type":"2",
                           "isStatic":true,
                           "repeatEveryState": [true,true,true,true,true,false,false],
                           "subtitle": "In-Transit",
                           "body": "Visualize where you stand",
                           "latitute":"13.0621840487029",
                           "longtitute":"80.2653428306843",
                           "descr":""] as [String : Any]
        return dict
    }
    
    func localTimeReminder(userID:String) -> [String : Any]{
        let appDelegateRef = UIApplication.shared.delegate as! AppDelegate
        
        let dict =        ["title": "Week Preparation:",
                           "reminderId":"0",
                           "isReminderOn": true,
                           "addressLocation": "",
                           "isStatic":true,
                           "user_id" : userID,
                           "user_UUID" : appDelegateRef.userUUID!,
                           "isTime":true,
                           "type":"0",
                           "repeatEveryState": [false, false, false, false, false, false, true],
                           "subtitle": "Prepare your week",
                           "body": "Preparation is everything to maximize your impact",
                           "latitute":"",
                           "longtitute":"",
                           "descr":"20:00"] as [String : Any]
        return dict
    }
    
    func localDailyReminder(userID:String) -> [String : Any]{
        let appDelegateRef = UIApplication.shared.delegate as! AppDelegate
        
        let dict =        ["title": "Project Tracking:",
                           "reminderId":"0",
                           "isReminderOn": true,
                           "addressLocation": "",
                           "isStatic":true,
                           "user_id" : userID,
                           "user_UUID" : appDelegateRef.userUUID!,
                           "isTime":true,
                           "type":"0",
                           "repeatEveryState": [true,true,true,true,true,true,false],
                           "subtitle": "Track your project(s)",
                           "body": "Visualize where you stand",
                           "latitute":"",
                           "longtitute":"",
                           "descr":"20:00"] as [String : Any]
        return dict
    }
    
    // Static Reminder
    func addStaticReminder(userID:String){
        let ref1 = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: userID).whereField("isStatic", isEqualTo: true)
        ref1.getDocuments { (snapshot, error) in
            if error == nil{
            if let snap = snapshot?.documents, snap.count == 0{
                FirebaseManager.shared.addReminderTimeFireBase(userID: userID)
                FirebaseManager.shared.addDailyReminderFireBase(userID: userID)
                FirebaseManager.shared.addReminderLocationFireBase(userID: userID)
                FirebaseManager.shared.addWalletFB()
            }
            }
        }
    }
    func addReminderLocationFireBase(userID:String){
        FirebaseManager.shared.firebaseDP?.collection("reminder").addDocument(data: localLocationReminder(userID:userID), completion: { (error) in
            if error != nil{
                print(error.debugDescription)
            }
            else{
                Constants.appDelegateRef.getTimeReminder()
                
                self.updateReminderID {
                }
            }
        })
    }
    
    func addReminderTimeFireBase(userID:String){
        FirebaseManager.shared.firebaseDP?.collection("reminder").addDocument(data: localTimeReminder(userID:userID), completion: { (error) in
            if error != nil{
                print(error.debugDescription)
            }
            else{
                Constants.appDelegateRef.getTimeReminder()
                
                self.updateReminderID {
                }
            }
        })
    }
    
    
    func addDailyReminderFireBase(userID:String){
        FirebaseManager.shared.firebaseDP?.collection("reminder").addDocument(data: localDailyReminder(userID:userID), completion: { (error) in
            if error != nil{
                print(error.debugDescription)
            }
            else{
                Constants.appDelegateRef.getTimeReminder()
                
                self.updateReminderID {
                }
            }
        })
    }
    
    func updateReminderID(onCompletion: @escaping onUpdateReminder){
        let ref = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: UserDefaults.standard.getUserUUID()).whereField("reminderId", isEqualTo: "0")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for i in 0 ..< snap.count {
                    let refExist = FirebaseManager.shared.firebaseDP!.collection("reminder").document(snap[i].documentID)
                    refExist.updateData(["reminderId" :"\(snap[i].documentID)"])
                }
            }
            onCompletion()
        }
    }
    
    func updateLastTrigger(docID:String){
        let ref = FirebaseManager.shared.firebaseDP!.collection("reminder").document(docID)
        ref.updateData(["time_last" :"\(self.getCurrentDate())"])
    }
    
    
    
    func checkLastTrigger(docID:String,limit:Int, onCompletion: @escaping onCheckReminder){
        let ref = FirebaseManager.shared.firebaseDP!.collection("reminder").document(docID)
        ref.getDocument { (snapshot, error) in
            if error == nil {
                
                 onCompletion(true)
//                let time = snapshot?.get("time_last") as? String ?? "0"
//                if time == "0"{
//                    onCompletion(true)
//                }
//                else{
//                    let date1 = Date()
//                    let date2 = self.getDateFromString(strDate: time)
//                    let diff = Int(date1.timeIntervalSince1970 - date2.timeIntervalSince1970)
//                    let hours = diff / 3600
//                    let minutes = (diff - hours * 3600) / 60
//
//                    print(minutes)
//
//                    print(self.getCurrentDate())
//                    let noOfHour = self.noOfMinutes(startDate: time)
//                    print(noOfHour)
//                    // here give limit
//                    if noOfHour >=  limit {
//                        onCompletion(true)
//                    }
//                    else{
//                        onCompletion(false)
//                    }
//                }
            }
        }
    }
    
    func noOfMinutes(startDate: String) -> Int{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateStart = dateFormatter.date(from: startDate)//df.string(from: startDate)
        let appUsedDate = Date()
        let userLastUsed = dateStart!.minutesBetweenDate(from: appUsedDate)
        var weeks:Float = Float(userLastUsed)
        weeks.round(.up)
        
        let positive = abs(Int(weeks))

        return positive
    }
    
    //Create Wallet Bar Status
    func addWalletJSON() -> [String: Any]{
        let appDelegateRef = UIApplication.shared.delegate as! AppDelegate
        
        let dict = ["user_id" : appDelegateRef.userUUID,
                    "walletAmount" : "800",
                    "capture" : "",
                    "meeting" : "",
                    "tracking" : "",
                    "course" : "",
                    "weeklyPlanner" : ""] as [String : Any]
        return dict
    }
    
    
    func addWalletFB(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("wallet").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID())
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                // if exist update
                for obj in snap{
                    let wallet = obj["walletAmount"] as? String ?? ""
                    UserDefaults.standard.set(wallet, forKey: "walletAmount")
                    UserDefaults.standard.synchronize()
                }
                print("Already Wallet Amount Added")
                
            }else{
                // add
                let refNew = FirebaseManager.shared.firebaseDP!.collection("wallet")
                refNew.addDocument(data: self.addWalletJSON(), completion: { (error) in
                    if error != nil{
                        print(error.debugDescription)
                    }
                    else{
                        print("Wallet Details Added")
                        UserDefaults.standard.set("800", forKey: "walletAmount")
                        UserDefaults.standard.synchronize()
                        
                    }
                })
            }
        }
        
//        FirebaseManager.shared.firebaseDP?.collection("wallet").addDocument(data: addWalletJSON(), completion: { (error) in
//            if error != nil{
//                print(error.debugDescription)
//            }
//            else{
//                print("Success")
//            }
//        })
    }
    

    
    func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func getDateFromString(strDate:String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter.date(from: strDate)!
    }
    
    func deleteStaticReminderUUID(userUUID:String){
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: userUUID)
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for i in 0 ..< snap.count {
                    let refExist = FirebaseManager.shared.firebaseDP!.collection("reminder").document(snap[i].documentID)
                    refExist.delete()
                }
            }
        }
    }
    
    func deleteUserData()
    {
        let userId = UserDefaults.standard.getUserUUID()
       // WebserviceManager.shared.showMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
        let ref1 = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: userId)
        
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("companies_user").whereField("user_id", isEqualTo: userId)
        
        let ref3 = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: userId)
        
        let ref4 = FirebaseManager.shared.firebaseDP!.collection("tracking").whereField("user_id", isEqualTo: userId)
        let ref5 = FirebaseManager.shared.firebaseDP!.collection("course_user").whereField("user_id", isEqualTo:  userId)
        let ref6 = FirebaseManager.shared.firebaseDP!.collection("myGoal").whereField("userId", isEqualTo: userId)
        let ref7 = FirebaseManager.shared.firebaseDP!.collection("add_meeting").whereField("user_id", isEqualTo: userId)
        let ref8 = FirebaseManager.shared.firebaseDP!.collection("project_career").whereField("user_id", isEqualTo: userId)
        let ref9 = FirebaseManager.shared.firebaseDP!.collection("quotes_likes").whereField("user_id", isEqualTo: userId)
        let ref10 = FirebaseManager.shared.firebaseDP!.collection("value_added").whereField("user_id", isEqualTo: userId)
        let ref11 = FirebaseManager.shared.firebaseDP!.collection("work_life_bal").whereField("user_id", isEqualTo: userId)
       
        let dailyStatus = FirebaseManager.shared.firebaseDP!.collection("dailyStatus").whereField("userId", isEqualTo: userId)
        
        countDelete = 0
        ref1.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("reminder").document(obj.documentID).delete()
                }
            }
        }
        
        dailyStatus.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("dailyStatus").document(obj.documentID).delete()
                }
            }
        }
        
        ref2.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("companies_user").document(obj.documentID).delete()
                }
            }
        }
        
        ref3.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("projects").document(obj.documentID).delete()
                }
            }
        }
        
        ref4.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("tracking").document(obj.documentID).delete()
                }
            }
        }
        
        ref5.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("course_user").document(obj.documentID).delete()
                }
            }
        }
        
        ref6.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("myGoal").document(obj.documentID).delete()
                }
            }
        }
        
        ref7.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("add_meeting").document(obj.documentID).delete()
                }
            }
        }
        ref8.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("project_career").document(obj.documentID).delete()
                }
            }
        }
        ref9.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("quotes_likes").document(obj.documentID).delete()
                }
            }
        }
        ref10.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("value_added").document(obj.documentID).delete()
                }
            }
        }
        ref11.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("work_life_bal").document(obj.documentID).delete()
                }
            }
        }
        
    }
    
    func updateDelete()
    {
        countDelete = countDelete + 1
         updateProgress()
        if countDelete >= 12
        {
            countDelete = 0
               // WebserviceManager.shared.hideMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
            let userID = Constants.appDelegateRef.userUUID
            self.addStaticReminder(userID: userID!)
                self.startSync()
        }
    }
    
    func startSync(){
        count = 0
        let userId = UserDefaults.standard.getUserUUID()
      //  WebserviceManager.shared.showMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
       
        let ref1 = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: userId)
        
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("FAQ")
        
        let refResources = FirebaseManager.shared.firebaseDP!.collection("resources")
        let refRelease = FirebaseManager.shared.firebaseDP!.collection("release")
        
        let ref3 = FirebaseManager.shared.firebaseDP!.collection("companies_user").whereField("user_id", isEqualTo: userId)
        
        let ref4 = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: userId)
        
        let ref5 = FirebaseManager.shared.firebaseDP!.collection("tracking").whereField("user_id", isEqualTo: userId)
        let ref6 = FirebaseManager.shared.firebaseDP!.collection("course_user").whereField("user_id", isEqualTo:  userId)
        let ref7 = FirebaseManager.shared.firebaseDP!.collection("courseList")
        let ref8 = FirebaseManager.shared.firebaseDP!.collection("myGoal").whereField("userId", isEqualTo: userId)
        
        let ref9 = FirebaseManager.shared.firebaseDP!.collection("companies")
        let ref10 = FirebaseManager.shared.firebaseDP!.collection("toastMessage")
        
         let wallet = FirebaseManager.shared.firebaseDP!.collection("wallet").whereField("user_id", isEqualTo: userId)
        let dailyStatus = FirebaseManager.shared.firebaseDP!.collection("dailyStatus").whereField("userId", isEqualTo: userId)
        
        let leaderBoard = FirebaseManager.shared.firebaseDP!.collection("leaderBoard").whereField("user_id", isEqualTo: userId)

        
        //Splash
        let trackinSplash = FirebaseManager.shared.firebaseDP!.collection("trackingSplash")
        let breathSplash = FirebaseManager.shared.firebaseDP!.collection("breathSplash")
        let weeklyPlanSpalsh = FirebaseManager.shared.firebaseDP!.collection("WeeklyPlanner_Video")
        
        let captureSplash = FirebaseManager.shared.firebaseDP!.collection("captureSplash")
        let meetingSPlash = FirebaseManager.shared.firebaseDP!.collection("MeetingManagerSplash")
        
        
        
        
        
        ref1.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "reminder")
        }
        dailyStatus.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "dailyStatus")
        }
        ref2.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "faq")
        }
        
        refResources.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "resources")
        }
        
        refRelease.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "release")
        }
        
        ref3.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "companies_user")
        }
        ref4.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "projects")
        }
        ref5.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "tracking")
        }
        ref6.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "course_user")
        }
        
        ref7.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "courseList")
        }
        ref8.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "myGoal")
        }
        ref9.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "companies")
        }
        ref10.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "toastMessage")
        }
        
        wallet.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "wallet")
        }
        
        leaderBoard.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "leaderBoard")
        }
        
        
        trackinSplash.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "trackingSplash")
        }
        
        breathSplash.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "breathSplash")
        }
        
        weeklyPlanSpalsh.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "WeeklyPlanner_Video")
        }
        
        captureSplash.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "captureSplash")
        }
        
        meetingSPlash.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "MeetingManagerSplash")
        }
        
        
        self.getToastMessages()
    }
    func getToastMessages()
    {
        let ref = FirebaseManager.shared.firebaseDP!.collection("toastMessage")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                self.parseIntoModel(obj: snap[0].get("data") as! [String : String])
                self.updateCount(snap: (snapshot?.documents)!, strTable: "toastMessage")
            }
        }
    }
    
    func parseIntoModel(obj:[String:String]){
        toastMsgs.addCourse = obj["addCourse"] ?? ""
        toastMsgs.already_add = obj["already_add"] ?? ""
        toastMsgs.already_invite = obj["already_invite"] ?? ""
        toastMsgs.buy_course = obj["buy_course"] ?? ""
        toastMsgs.connect = obj["connect"] ?? ""
        toastMsgs.course_add = obj["course_add"] ?? ""
        toastMsgs.detail_empty = obj["detail_empty"] ?? ""
        toastMsgs.emailid = obj["emailid"] ?? ""
        toastMsgs.failed = obj["failed"] ?? ""
        toastMsgs.other_details = obj["other_details"] ?? ""
        toastMsgs.pending_call = obj["pending_call"] ?? ""
        toastMsgs.register_failed = obj["register_failed"] ?? ""
        toastMsgs.snap_taken = obj["snap_taken"] ?? ""
        toastMsgs.suc_mail = obj["suc_mail"] ?? ""
        toastMsgs.switch_user = obj["switch_user"] ?? ""
        toastMsgs.thank_call4back = obj["thank_call4back"] ?? ""
        toastMsgs.thanks_survey = obj["thanks_survey"] ?? ""
        toastMsgs.update_invite = obj["update_invite"] ?? ""
        toastMsgs.update_mail = obj["update_mail"] ?? ""
    }
        
    func updateCount(snap:[QueryDocumentSnapshot],strTable : String)
    {
        count = count + 1
            updateProgress()
        if count >= 20 {
           // WebserviceManager.shared.hideMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
            count = 0
            UserDefaults.standard.set("1", forKey: "isSynch")
            UserDefaults.standard.synchronize()
            guard let shyncAction = onCompleteShync else {
                return
            }
            shyncAction()
            
        }
    }
//    func showProgressView()
//    {
//        progressView = UIView.init(frame: UIScreen.main.bounds)
//        progressView!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        progress = UIProgressView.init(progressViewStyle: .bar)
//        progress?.frame = CGRect(x: 20, y: 0, width: (progressView?.frame.size.width)! - 40, height: 20)
//        progressView!.addSubview(progress!)
//        progress!.center = progressView!.center
//        progress!.transform = progress!.transform.scaledBy(x: 1, y: 4)
//        progress!.layer.cornerRadius = 6
//        progress!.clipsToBounds = true
//        progress!.trackTintColor = UIColor.darkGray
//        Constants.appDelegateRef.window?.rootViewController?.view.addSubview(progressView!)
//
//    }
    func showProgressView()
    {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let yvalue = screenHeight - 110
        // progressView = UIView.init(frame: UIScreen.main.bounds)
        progressView = UIView.init(frame:CGRect(x: 0, y: Int(yvalue) , width:Int(screenWidth), height: 20))
        progressView!.backgroundColor = UIColor.clear //UIColor.black.withAlphaComponent(0.5)
        progress = UIProgressView.init(progressViewStyle: .bar)
        progress?.frame = CGRect(x: 20, y: 0, width: (progressView?.frame.size.width)! - 40, height: 20)
        progressView!.addSubview(progress!)
        //progress!.center = progressView!.center
        progress!.transform = progress!.transform.scaledBy(x: 1, y: 4)
        progress!.layer.cornerRadius = 6
        progress!.clipsToBounds = true
        progress!.trackTintColor = UIColor.lightGray
        progress!.progressTintColor = UIColor.init(red: 26/255, green: 154/255, blue: 64/255, alpha: 1)
        //UIColor.red
        Constants.appDelegateRef.window?.rootViewController?.view.addSubview(progressView!)
    }
    
    func hideProgress()
    {
        progressView!.removeFromSuperview()
    }
    
    func updateProgress()
    {
        DispatchQueue.main.async {
            self.progressCount = self.progressCount + 1
            let prog = Float(self.progressCount) / Float(self.countTotal)
            print("progress: \(self.progressCount)... current: \(self.countTotal)....prog:\(prog)")
            self.progress!.setProgress(prog, animated: true)
        }
    }
}





