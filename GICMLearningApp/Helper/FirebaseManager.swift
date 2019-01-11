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
    var toastMsgs : ToastMessages = ToastMessages()
    func firebaseConfigure() {
        
        FirebaseApp.configure()
        firebaseDP = Firestore.firestore()
        let settings = firebaseDP!.settings
        settings.areTimestampsInSnapshotsEnabled = true
        settings.isPersistenceEnabled = true
        firebaseDP!.settings = settings
       
    }
    
    func localLocationReminder(userID:String) -> [String : Any]{
        let appDelegateRef = UIApplication.shared.delegate as! AppDelegate
        
        let dict =        ["title": "Project Tracking:",
                           "reminderId":"0",
                           "isReminderOn": true,
                           "addressLocation": "4/7, Anna Salai,Chennai, Tamil Nadu 600002",
                           "user_id" : userID,
                           "user_UUID" : appDelegateRef.userUUID!,
                           "isTime":true,
                           "type":"0",
                           "isStatic":true,
                           "isArriving":true,
                           "repeatEveryState": [true, true, true, true, true, false, false],
                           "subtitle": "Track your project(s)",
                           "body": "Visualize where you stand",
                           "latitute":"13.0621840487029",
                           "longtitute":"80.2653428306843",
                           "descr":"20:00"] as [String : Any]
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
                let time = snapshot?.get("time_last") as? String ?? "0"
                if time == "0"{
                    onCompletion(true)
                }
                else{
                    let date1 = Date()
                    let date2 = self.getDateFromString(strDate: time)
                    let diff = Int(date1.timeIntervalSince1970 - date2.timeIntervalSince1970)
                    let hours = diff / 3600
                    let minutes = (diff - hours * 3600) / 60
                    
                    // here give limit
                    if minutes > limit {
                        onCompletion(true)
                    }
                    else{
                        onCompletion(false)
                    }
                }
                
            }
        }
    }
    
    func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        return formatter.string(from: date)
    }
    
    func getDateFromString(strDate:String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
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
        WebserviceManager.shared.showMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
        //   showProgressView()
        let ref1 = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: userId).whereField("isStatic", isEqualTo: false)
        
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
        
        
        countDelete = 0
        ref1.getDocuments { (snapshot, error) in
            self.updateDelete()
            if let snap = snapshot?.documents, snap.count > 0{
                for obj in snap{
                    FirebaseManager.shared.firebaseDP!.collection("reminder").document(obj.documentID).delete()
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
        if countDelete >= 11
        {
            countDelete = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                WebserviceManager.shared.hideMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
                self.startSync()
            }
        }
    }
    
    func startSync(){
        count = 0
        let userId = UserDefaults.standard.getUserUUID()
        print("user ID:\(userId)")
        WebserviceManager.shared.showMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
        //   showProgressView()
        let ref1 = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: userId)
        
        
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("FAQ")
        
        let ref3 = FirebaseManager.shared.firebaseDP!.collection("companies_user").whereField("user_id", isEqualTo: userId)
        
        let ref4 = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: userId)
        
        let ref5 = FirebaseManager.shared.firebaseDP!.collection("tracking").whereField("user_id", isEqualTo: userId)
        let ref6 = FirebaseManager.shared.firebaseDP!.collection("course_user").whereField("user_id", isEqualTo:  userId)
        let ref7 = FirebaseManager.shared.firebaseDP!.collection("courseList")
        let ref8 = FirebaseManager.shared.firebaseDP!.collection("myGoal").whereField("userId", isEqualTo: userId)
        
        let ref9 = FirebaseManager.shared.firebaseDP!.collection("companies")
        let ref10 = FirebaseManager.shared.firebaseDP!.collection("toastMessage")

        ref1.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "reminder")
        }
        ref2.getDocuments { (snapshot, error) in
            self.updateCount(snap: (snapshot?.documents)!, strTable: "faq")
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
        print(toastMsgs)
    }
        
    func updateCount(snap:[QueryDocumentSnapshot],strTable : String)
    {
        print("Table : \(strTable) \(snap.count)")
        
        count = count + 1
        //    setProgress()
        if count >= 11 {
            WebserviceManager.shared.hideMBProgress(view: (Constants.appDelegateRef.window?.rootViewController?.view)!)
            //  hideProgress()
            count = 0
            UserDefaults.standard.set("1", forKey: "isSynch")
            UserDefaults.standard.synchronize()
            guard let shyncAction = onCompleteShync else {
                return
            }
            shyncAction()
            
        }
    }
    func showProgressView()
    {
        progressView = UIView.init(frame: UIScreen.main.bounds)
        progressView!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        progress = UIProgressView.init(progressViewStyle: .bar)
        progressView!.addSubview(progress!)
        progress!.center = progressView!.center
        Constants.appDelegateRef.window?.rootViewController?.view.addSubview(progressView!)
        
    }
    func hideProgress()
    {
        progressView!.removeFromSuperview()
    }
    
    func setProgress()
    {
        let prog = Float(count) / Float(8)
        progress!.setProgress(prog, animated: true)
    }
}





