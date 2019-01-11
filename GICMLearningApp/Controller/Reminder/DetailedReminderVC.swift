
//
//  DetailedReminderVC.swift
//  GICM
//
//  Created by Rafi on 09/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import CoreLocation
import FirebaseStorage
import Firebase


class DetailedReminderVC: UIViewController{
    @IBOutlet weak var segementArrivalOrDeparture: UISegmentedControl!
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imgvwLocation: UIImageView!
    @IBOutlet weak var imgvwTime: UIImageView!
    @IBOutlet weak var imgvwTransit: UIImageView!
    @IBOutlet weak var lblTransit: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTimeString: UILabel!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var viewTransit: UIView!
    @IBOutlet weak var txtViewTrnasit: UITextView!
    @IBOutlet weak var btnSelectLocation: UIButton!
    @IBOutlet weak var lblTime: UILabel!
   
    @IBOutlet weak var stackLocation: UIStackView!
    
    @IBOutlet weak var stackTransit: UIStackView!
    @IBOutlet weak var stackTime: UIStackView!
    var arrayTimeDaysState = [true,true,true,true,true,false,false]
    var arrayLocationDaysState = [true,true,true,true,true,false,false]
    var arrayTransitDaysState = [true,true,true,true,true,false,false]

    var reminderTitle = ""
    var arrayDayString = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    var isTime = true
    var isLocation = false
    var reminderModel:ReminderModel?
    var isEditable = false
    var arrayIndex = 0
    var isRemainderOn = true
    var requestIdentifier = ""
    var arrayUserDefaultKeys:[String] = []
    var arrayLocalNotifcationIdentifer:[String] = []
    var addressLocation = ""
    var strLatitude:String = ""
    var strLongitude:String = ""
    var isArriving = true
    var locaionCoordinates = CLLocationCoordinate2D()
    var circularRegion = CLCircularRegion()
    
    var fromVC = ""
    var strReminderID = "0"
    var strType = "0"
    var strTransitContent = ""

    var indexValue = 0
    var isStatic : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // status is not determined
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentLocTypeChanged(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            isArriving = true
        }
        else{
            isArriving = false
        }
    }
    //MARK:- Local Methods
    func configUI(){
        // Do any additional setup after loading the view.
        btnSelectLocation.titleLabel?.numberOfLines = 0
         let button = UIButton()
        circularIdentifier = self.reminderTitle + "location"
        if  fromVC == "edit" {
            isTime = reminderModel!.isTime
            isLocation = reminderModel!.isTime
            isRemainderOn = reminderModel!.isReminderOn
            txtTitle.text = reminderModel!.title
            isStatic = reminderModel!.isStatic
            isArriving = reminderModel!.isArriving
            strType = reminderModel!.type
            if isStatic{
                txtTitle.isEnabled = false
            }
            if strType == "2"{
                enableTransitView()
                strTransitContent = reminderModel!.descr
                txtViewTrnasit.text = reminderModel!.descr
                arrayTransitDaysState = reminderModel!.repeatEveryState
                self.transitActionButton(button)

            }
            else{
                if(isTime){
                    enableTimeView()
                    lblTimeString.text = reminderModel!.descr
                    arrayTimeDaysState = reminderModel!.repeatEveryState
                    self.timeAction(button)
                }
                else{
                    strLatitude = reminderModel!.latitude
                    strLongitude = reminderModel!.longitude
                    segementArrivalOrDeparture.selectedSegmentIndex = (isArriving) ? 0 : 1
                    enableLocationView()
                    btnSelectLocation.setTitle(reminderModel!.descr, for: .normal)
                    arrayLocationDaysState = reminderModel!.repeatEveryState
                    self.locationActionButtonForFirstTime(button)
                
                }
            }
           // Dummy purpose
        } else {
            enableTimeView() //Initially
        }
        
        self.setWeekButtons(view: stackTime, states: arrayTimeDaysState)
        self.setWeekButtons(view: stackTransit, states: arrayTransitDaysState)
        self.setWeekButtons(view: stackLocation, states: arrayLocationDaysState)
    }
    
    func setWeekButtons(view:UIView,states:[Bool]){
        for case let btn as UIButton in view.subviews {
                btn.backgroundColor = states[btn.tag-1] ? Constants.getCustomBlueColor() : UIColor.lightGray
                btn.layer.cornerRadius = 10
        }
    }
    
    // MARK: - Button Actions
    @IBAction func locationActionButton(_ sender: Any) {
        self.isTime = false
        self.isLocation = true
        strType = "0"
        enableLocationView()
    }
    @IBAction func locationActionMap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SubMenuStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LocationMapVC") as! LocationMapVC
        if self.strLatitude.count > 0{
        controller.strLat = self.strLatitude
        controller.strLong = self.strLongitude
        controller.isEdit = true
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func transitActionButton(_ sender: Any) {
        
        self.isTime = false
        self.isLocation = false
        strType = "2"
        enableTransitView()
    }
    
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        lblTimeString.text = timeFormatter.string(from: datePicker.date)
    }
    
    
    @IBAction func timeAction(_ sender: Any) {
        self.isLocation = false
        self.isTime = true
        strType = "0"
        enableTimeView()
    }
    
    @IBAction func daysLocationActions(_ sender: UIButton) {
        
        arrayLocationDaysState[sender.tag-1] = !arrayLocationDaysState[sender.tag-1]
        sender.backgroundColor = arrayLocationDaysState[sender.tag-1] ? Constants.getCustomBlueColor() : UIColor.lightGray
    }
    @IBAction func daysTimeActions(_ sender: UIButton) {
        arrayTimeDaysState[sender.tag-1] = !arrayTimeDaysState[sender.tag-1]
        sender.backgroundColor = arrayTimeDaysState[sender.tag-1] ? Constants.getCustomBlueColor() : UIColor.lightGray
    }
    
    @IBAction func daysIntransitActions(_ sender: UIButton) {
        
        arrayTransitDaysState[sender.tag-1] = !arrayTransitDaysState[sender.tag-1]
        sender.backgroundColor = arrayTransitDaysState[sender.tag-1] ? Constants.getCustomBlueColor() : UIColor.lightGray
    }
    
    func addandEditReminder(){
        if fromVC == "edit"{
            editReminderAPIFirebase()
        }else{
            self.addReminderFireBase()
        }
    }
    
    func getAddReminderNotification() -> [String:Any]{
        
        var remindMe = true
        if fromVC == "edit"{
            remindMe = reminderModel!.isReminderOn
        }else{
            remindMe = true
        }
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var subtitle = ""
        var body = ""
        
        if isStatic == true{
            if txtTitle.text == "Project Tracking:" {
                subtitle = "Track your project(s)"
                body = "Visualize where you stand"
            }
            else{
                subtitle = "Prepare your week"
                body = "Preparation is everything to maximize your impact"
            }
        }
        else{
            if strType == "0"{
                subtitle = "Prepare your week"
                body = "Preparation is everything to maximize your impact"
            }
            else if strType == "1"{
                subtitle = "Track your project(s)"
                // body = "Visualize where you stand"
                body = "Use the time mindfully"
                
            }
            else if strType == "2"{
                subtitle = "In-Transit"
                body = txtViewTrnasit.text
            }
        }
        
        let dict = ["title": txtTitle.text!,
                    "reminderId":strReminderID,
                    "isReminderOn": remindMe,
                    "addressLocation": !isTime ? addressLocation : "",
                    "user_id" : UserDefaults.standard.getUserID(),
                    "user_UUID" : appDel.userUUID!,
                    "isTime":isTime,
                    "isStatic":isStatic,
                    "type":strType,
                    "isArriving":isArriving,
                    "repeatEveryState":strType == "2" ? arrayTransitDaysState : isTime ? arrayTimeDaysState : arrayLocationDaysState,
                    "subtitle":subtitle,
                    "body":body,
                    "latitute":strLatitude,
                    "longtitute":strLongitude,
                    "descr":strType == "2" ? txtViewTrnasit.text : isTime ? lblTimeString.text ?? "" : btnSelectLocation.currentTitle ?? ""] as [String : Any]
        return dict
    }
    
    func addReminderFireBase(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("reminder")
        ref?.addDocument(data: self.getAddReminderNotification(), completion: { (error) in
            FirebaseManager.shared.updateReminderID {
                self.navigationController?.popViewController(animated: true)
                self.triggerReminder()
            }
        })
    }
    
    func editReminderAPIFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("reminder").document(strReminderID)
        ref.updateData(getAddReminderNotification(), completion: { (error) in
            print("Edit reminder Detail Error: \(String(describing: error))")
            if error == nil{
                self.navigationController?.popViewController(animated: true)
                self.triggerReminder()
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
               
            }
            WebserviceManager.shared.hideMBProgress(view:self.view)
        })
    }
    
    @IBAction func addReminder(_ sender: Any) {
        
        if txtTitle.text == "Title" || txtTitle.text?.isEmpty ?? false {
            // Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Please set the Title", controller: self)
            Utilities.showSuccessFailureAlertWithDismissHandler(title: "Attention!", message: "Please set the Title", controller: self) { (completed) in
                if completed {
                    self.txtTitle.becomeFirstResponder()
                }
            }
            return
        }
        WebserviceManager.shared.showMBProgress(view:self.view)
        self.addandEditReminder()
    }
    
    
    @IBAction func closeCreatingReminder(_ sender: Any) {
        Utilities.showAlertOkandCancelWithDismiss(title: "Save Reminder", okTitile: "Yes", cancelTitle: "No", message: "Would you like to save this reminder?", controller: self, alertDismissed: { (ok) in
            if ok {
                // Save the reminder
                self.addReminder("")
                
            } else {
                // Dont save the reminder
                for controller in self.navigationController!.viewControllers as Array
                {
                    if controller is RemindersListVC
                    {
                        if let vc = controller as? RemindersListVC {
                            let _ =  self.navigationController?.popToViewController( vc as UIViewController, animated: true)
                            break
                        }
                        
                    }
                }
            }
        })
    }
    
    //MARK:- Seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "location") {
            let vc = segue.destination as! LocationMapVC
            if fromVC == "edit"{
                vc.strLat = strLatitude
                vc.strLong = strLongitude
                vc.isEdit = true
            }else{ // Add New reminder
                vc.isEdit = false
            }
        }
    }
    
    // MARK: - Local Method
    fileprivate func enableTimeView() {
        //        viewLocation.isHidden = true
        //        viewTime.isHidden = false
        imgvwLocation.image =  #imageLiteral(resourceName: "Location_W")//imageLiteral(resourceName: "Location_W")
        imgvwTime.image =  #imageLiteral(resourceName: "Clock_Blue")//imageLiteral(resourceName: "Clock_Blue")
      
        lblTime.textColor = UIColor.cyan
        lblLocation.textColor = UIColor.white
        lblTransit.textColor = UIColor.white
        imgvwTransit.image = #imageLiteral(resourceName: "In_Transit_White")
        self.view.bringSubview(toFront: viewTime)
        strType = "0"


    }
    
    fileprivate func enableLocationView() {
        //        viewLocation.isHidden = false
        //        viewTime.isHidden = true
        imgvwLocation.image =  #imageLiteral(resourceName: "Location_Blue")//imageLiteral(resourceName: "Location_Blue")
        imgvwTime.image =  #imageLiteral(resourceName: "Clock_W")//imageLiteral(resourceName: "Clock_W")
        lblTime.textColor = UIColor.white
        lblLocation.textColor = UIColor.cyan
        lblTransit.textColor = UIColor.white
        imgvwTransit.image = #imageLiteral(resourceName: "In_Transit_White")
        self.view.bringSubview(toFront: viewLocation)
        strType = "1"
    }
    
    fileprivate func enableTransitView() {
        //        viewLocation.isHidden = false
        //        viewTime.isHidden = true
        imgvwLocation.image =  #imageLiteral(resourceName: "Location_W")//imageLiteral(resourceName: "Location_Blue")
        imgvwTime.image =  #imageLiteral(resourceName: "Clock_W")//imageLiteral(resourceName: "Clock_W")
        lblTime.textColor = UIColor.white
        lblLocation.textColor = UIColor.white
        lblTransit.textColor = UIColor.cyan
        imgvwTransit.image = #imageLiteral(resourceName: "In_Transit_Blue")
        self.view.bringSubview(toFront: viewTransit)
         strType = "2"
    }
    
    fileprivate func locationActionButtonForFirstTime(_ sender: Any) {
        print(self.viewTime.frame.width,self.view.frame.width)
        self.viewLocation.transform  = CGAffineTransform.identity
        self.viewTime.transform  = CGAffineTransform(translationX: self.view.frame.width, y: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.enableLocationView()
            self.isTime = false
            self.isLocation = true
        }) { (completed) in
            
        }
        
    }
    
    
    func triggerReminder() {
        let app = UIApplication.shared.delegate as! AppDelegate
        if strType == "0"{
            app.getTimeReminder()
        }
        if strType == "1"{
        app.startGeoFencingFirebase()
        }
        else if strType == "2"{
         app.startTransitReminder()
        }
    }
}

extension DetailedReminderVC: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        // completionHandler( [.alert,.sound,.badge])
        
        // You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //  to distinguish between notifications
        if notification.request.identifier == requestIdentifier{
            
            completionHandler( [.alert,.sound,.badge])
        }
    }
}

extension DetailedReminderVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
