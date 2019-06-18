//
//  RemindersListVC.swift
//  GICM
//
//  Created by Rafi on 09/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SwipeCellKit
import Firebase
import FirebaseFirestore
import Instabug

class RemindersListVC: UIViewController{
    // MARK: - Initialization
    @IBOutlet weak var tblReminderList: UITableView!
    var arrayReminder:[ReminderModel] = []
    var arrayDayString = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    
    //Comment
    var customCommentObj     : CustomCommentVC!
    var isFirstTimeLoaded = true
    var strReminderId = ""
    
    var isReminderOn = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("***********************************************")
        NSLog(" Reminder List  Controller View did load  ")
        
        createCustomCommentInstance()
        tblReminderList.register(UINib(nibName: "RemindersListCell", bundle: nil), forCellReuseIdentifier: "RemindersListCell")
        //  tblReminderList.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Firestore.firestore().disableNetwork { (error) in
            self.reminderListISLFirebase()
        }
        print(arrayReminder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
    @IBAction func addNewReminderAction(_ sender: Any) {
        self.performSegue(withIdentifier: "DetailedReminderVC", sender: "new")
    }
    
    //MARK:- Comment
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    // MARK: - Lcoal Methods
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        arrayReminder[sender.tag].isReminderOn = sender.isOn
        let modelObj = arrayReminder[sender.tag]
        
        if sender.isOn  {
            isReminderOn = true
            if arrayReminder[sender.tag].isTime {
                self.triggerLocalNotification(index:sender.tag)
            }
        } else {
            isReminderOn = false
            stopButton(array: arrayReminder[sender.tag].arrayLocalNotificIdentifers)
        }
        editReminderAPIFirebase(reminderID: modelObj.reminderId, type:  modelObj.type)
    }
    
    func stopButton(array:[String]) {
        print("Remove pending request.")
        if #available(iOS 10.0, *) {
            let centre = UNUserNotificationCenter.current()
            centre.removePendingNotificationRequests(withIdentifiers: array)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func triggerLocalNotification(index:Int) {
        print("Notification will be triggered in 2 sec. Hold on...")
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = arrayReminder[index].title //"Track your projects"
            content.subtitle = "Prepare your week"
            content.body = "Visualize where you standPreparation is everything to maximize your impact"
            //content.sound = UNNotificationSound.default()
            content.sound = UNNotificationSound(named: "GICM_Notification.wav")
            
            //Delivering the notification in two seconds.
            let timeString = arrayReminder[index].description.split(separator: ":")
            
            var dateComponents = DateComponents()
            dateComponents.hour = Int(timeString[0])
            dateComponents.minute = Int(timeString[1])
            arrayReminder[index].arrayLocalNotificIdentifers.removeAll()
            for i in 0..<arrayReminder[index].repeatEveryState.count {
                if arrayReminder[index].repeatEveryState[i] {
                    switch i {
                    case 0:
                        dateComponents.weekday = 2 //Monday
                    case 1:
                        dateComponents.weekday = 3 //Tuesday
                    case 2:
                        dateComponents.weekday = 4 //Wednesday
                    case 3:
                        dateComponents.weekday = 5 //Thursday
                    case 4:
                        dateComponents.weekday = 6 //Friday
                    case 5:
                        dateComponents.weekday = 7 //Saturday
                    case 6:
                        dateComponents.weekday = 1 //Sunday
                    default:
                        return
                    }
                    let isTimeORLocationStr = arrayReminder[index].isTime ? "time" : "location"
                    let requestIdentifier =   "\(index)" + isTimeORLocationStr +  arrayDayString[i] //Reminder Title + Days name
                    print(requestIdentifier)
                    arrayReminder[index].arrayLocalNotificIdentifers.append(requestIdentifier)
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,repeats: true)
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: notificationTrigger)
                    
                    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
                    UNUserNotificationCenter.current().add(request){(error) in
                        
                        if (error != nil){
                            print(error?.localizedDescription as Any )
                        }
                    }
                    
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "DetailedReminderVC") {
            let vc = segue.destination as! DetailedReminderVC
            if let index = sender as? IndexPath {
                vc.isEditable = true
                vc.arrayIndex = index.row
                let model = self.arrayReminder[index.row]
                vc.reminderModel = model
                self.strReminderId = model.reminderId
                vc.fromVC = "edit"
                vc.strReminderID = self.strReminderId
                vc.indexValue = index.row
            }
            
            if let new = sender as? String {
                if new == "new" {
                    vc.isEditable = false
                    vc.reminderTitle = "\(arrayReminder.count)"
                }
            }
        }
    }
    
}
extension RemindersListVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(arrayReminder.count)
        return arrayReminder.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RemindersListCell", for: indexPath) as! RemindersListCell
        
        cell.setupUI(reminder: arrayReminder[indexPath.row])
        cell.switchReminder.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        cell.switchReminder.tag = indexPath.row
        cell.delegate = self as? SwipeTableViewCellDelegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  self.performSegue(withIdentifier: "DetailedReminderVC", sender: indexPath);
    }
    
    //MARK:- Reminder List API
    func reminderListISLFirebase()
    {
        _ = FirebaseManager.shared.firebaseDP!.collection("reminder").whereField("user_UUID", isEqualTo: UserDefaults.standard.getUserUUID()).addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
            if let snap = snapshot?.documents {
                if snap.count > 0 {
                    self.parseIntoModel(snap: snap)
                    self.tblReminderList.reloadData()
                }
                else{
                    self.arrayReminder.removeAll()
                    self.tblReminderList.reloadData()
                }
                Firestore.firestore().enableNetwork(completion: nil)
            }
        })
    }
    
    //MARK:- Reminder List API
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        arrayReminder.removeAll()
        for obj in snap{
            let model = ReminderModel()
            model.isTime = obj["isTime"] as? Bool ?? false
            model.isStatic = obj["isStatic"] as? Bool ?? false
            model.isArriving = obj["isArriving"] as? Bool ?? false
            model.type = obj["type"] as? String ?? "0"
            model.descr = obj["descr"] as? String ?? ""
            model.reminderId = obj["reminderId"] as? String ?? "0"
            model.repeatEveryState = obj["repeatEveryState"] as? [Bool] ?? []
            model.isReminderOn = obj["isReminderOn"] as? Bool ?? false
            model.addressLocation = obj["addressLocation"] as? String ?? ""
            model.latitude = obj["latitute"] as? String ?? ""
            model.longitude = obj["longtitute"] as? String ?? ""
            model.title = obj["title"] as? String ?? ""
            model.body = obj["body"] as? String ?? ""
            model.subtitle = obj["subtitle"] as? String ?? ""
            arrayReminder.append(model)
        }
    }
    
    //MARK:- Show Alert
    func showDeleteAlert(type:String) {
        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString("Do you want to delete the reminder?", comment:""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            
            //Call Delete API
            self.deleteReminderApiFirebase(type: type)
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    //MARK:- reminder Delete API
    func deleteReminderApiFirebase(type:String){
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("reminder").document(strReminderId)
        ref.delete { (error) in
            if error == nil{
                self.arrayReminder.removeAll()
                self.reminderListISLFirebase()
               self.triggerReminders(type: type)
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Delete project failed,try again later", controller: self)
            }
        }
        
        
        // Offline
        self.arrayReminder.removeAll()
        self.reminderListISLFirebase()
        self.triggerReminders(type: type)
        
    }
    
    func triggerReminders(type:String){
        if type == "0" {
            Constants.appDelegateRef.getTimeReminder()
        }
        if type == "1" {
            Constants.appDelegateRef.startGeoFencingFirebase()
        }
        else if type == "2"{
            Constants.appDelegateRef.startTransitReminder()
        }
    }
    
    func getAddReminderNotification(type:String) -> [String:Any]{
        if type == "0"
        {
            return [
                "isReminderOn": isReminderOn ? true : false
            ]
        }
        else
        {
            return [
                "isReminderOn": isReminderOn ? true : false,
                "time_last": "0"
            ]
        }
    }
    
    //MARK:- Edit Reminder
    func editReminderAPIFirebase(reminderID: String,type:String){
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("reminder").document(reminderID)
        ref.updateData(getAddReminderNotification(type: type), completion: { (error) in
            print("Edit project Detail Error: \(String(describing: error))")
            if error == nil{
                print("Updated Successfully")
                self.triggerReminders(type: type)
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
            }
        })
    }
}

extension RemindersListVC: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        //  if notification.request.identifier == requestIdentifier{
        
        completionHandler( [.alert,.sound,.badge])
        
        //  }
    }
    
}

extension RemindersListVC: CommentDelegates{
    func createCustomCommentInstance()
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        customCommentObj = mainStoryboard.instantiateViewController(withIdentifier: "CustomCommentVC") as! CustomCommentVC
        customCommentObj.delegate = self
    }
    
    //Add
    func addCustomComment() {
        self.view.addSubview(customCommentObj.view)
    }
    
    func removeCustomComment()
    {
        if customCommentObj != nil
        {
            customCommentObj.view.removeFromSuperview()
        }
    }
    
    func commentMe() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "Reminder"
        nextVC.strUserType = "Me"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func commentAnonymous() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = "0"
        nextVC.strFromVC = "Reminder"
        nextVC.strUserType = "Ananymous"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func canceled() {
        removeCustomComment()
    }
}


extension RemindersListVC: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let modelObj = self.arrayReminder[indexPath.row]
        if orientation == .right {//&& !modelObj.isStatic {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                print("Delete")
                self.strReminderId = modelObj.reminderId
//                if modelObj.isStatic {
//                    Utility.sharedInstance.displayFailureAlertWithMessage(message: "You can't delete the default reminder.", title: "Attention!", onCompletion: { (true) in
//                    })
//                }
//                else{
                    self.showDeleteAlert(type:  modelObj.type)
               // }
            }
            
            // customize the action appearance
            deleteAction.backgroundColor = UIColor.red
            deleteAction.textColor = UIColor.black
            return [deleteAction]
        }else if orientation == .left{
            let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
                print("Edit")
                
                self.performSegue(withIdentifier: "DetailedReminderVC", sender: indexPath);
                //   self.navigationController?.pushViewController(nextVC, animated: true)
                
            }
            editAction.backgroundColor = UIColor.yellow
            editAction.textColor = UIColor.black
            return [editAction]
        }else{
            return nil
        }
    }
}



