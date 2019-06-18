//
//  ProfileViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 24/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import SwipeCellKit
import Instabug
import MessageUI
import LUExpandableTableView
import ExpyTableView
import IQKeyboardManagerSwift

class ProfileViewController: UIViewController,SMFeedbackDelegate,MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate,UIDocumentInteractionControllerDelegate{
    
    var docController: UIDocumentInteractionController?
    //   @IBOutlet weak var tblProfile: LUExpandableTableView!
    @IBOutlet weak var tblProfile: ExpyTableView!
    var arrayCareerLevel :[String] = []
    var arrProjectList : [ProjectModelFB] = []
    var strProjectID = ""
    var arrComapnyList = [CompanyListFB]()
    var arrPostingList = [PostingListFB]()
    var arrayCompanies : [[String:AnyObject]] = []
    var feedbackVC : SMFeedbackViewController?
    var arrCompanyName = [String]()
    var strCompanyName = "Capgimini"
    var strPreCompanyName = ""
    var companyID = ""
    var strPostingName = ""
    var PostingID = ""
    
    var strUserName = ""
    var strEmail    = ""
    var strDOB      = ""
    var strBase64   = ""
    let ImagePicker = UIImagePickerController()
    
    
    var arrHeader = ["My Goals","Employer","Compare myself","Projects"]
   // var arrHeader = ["Personal details","My Goal","Compatible goals for consutants","Employer","Projects Category","Projects"]
  
    //Custom Picker Instance variable
    var customPickerObj : CustomPicker!
    var selectedPicker  = ""
    var strMyGoal = ""
    var goalTimingValue = 1
    var goalType    = -1
    var goalId = ""
    var isEdited = false
    var arrMygoal: [String] = [String]()
    var goalRowHeight:CGFloat = 0
    var isExpand = false
    var a = 0
    
    @IBOutlet weak var vwCategory: UIView!
    @IBOutlet weak var twCategory: UITextView!
    //Comment
    
    var customCommentObj     : CustomCommentVC!
    @IBOutlet var viewOtherCompany: UIView!
    @IBOutlet var txtOtherComp: UITextField!
    @IBOutlet var txtOtherPost: UITextField!
    
    @IBOutlet weak var btnAddProject: UIButton!
    
    @IBOutlet var viewEmail: UIView!
    @IBOutlet var txtEmail: UITextField!
    var strEmailSwitch = ""
    // id:2;
    
    let userId = UserDefaults.standard.getUserUUID()
    typealias isCompleted = (URL) -> ()
    
    
    //WorkStream
    @IBOutlet weak var txtWorkStreamName: UITextField!
    @IBOutlet weak var txtAssigned: UITextField!
    @IBOutlet var vwWorkStream: UIView!
    var arrWorkStream = [String]()
    var workStreamName = ""
    var currentWorkStramData = [[String:Any]()]
    
    var strGoalName = ""
    var meTime = "8"
    var sleep = "4"
    var excercise = ""
    var profileCompletenessValue = 0
    var isProfileCellExpand = ""
    var isStatisStream = true
    var workStreamStatic = WeeklyPlannerData()
    
    
    
    var myGoalHeight = 0
    var isMyGoalSelected = false
    var currentGoalSelected = ""
    var strProjectCategory = ""
    
    // Profile Section
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtUserEmail: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    
    
    
    // MyGoal Details
       var arrGoalsList = ["Personal development","Accelerate my career","Less stress more me-time","Become a better consultant","Evolve the consulting profession","drive to optimize","male people happy","earn money the tough way","learn fast deep and/or broad","dream of something better","to create a legacy","to lead","Other"]
     var arrSelectedGoalsList = [String]()
     var GoalDuration = ""
    
    
    //MARK:- VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("***********************************************")
        NSLog(" Profile Vewi Controller View did load  ")
        
        // Do any additional setup after loading the view.
        self.viewOtherCompany.frame = self.view.frame
        self.viewOtherCompany.isHidden = true
        self.viewEmail.frame = self.view.frame
        self.viewEmail.isHidden = true
        
        self.vwWorkStream.frame = self.view.frame
        self.vwWorkStream.isHidden = true
        //  self.wind.addSubview(self.viewOtherCompany)
        self.tabBarController?.view.addSubview(self.viewOtherCompany)
        self.tabBarController?.view.addSubview(self.viewEmail)
        self.tabBarController?.view.addSubview(self.vwWorkStream)
        
        createCustomCommentInstance()
        createCustomPickerInstance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginFirebase), name: Notification.Name("NotifyLoginVerify"), object: nil)
        
        
        
        tblProfile.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        tblProfile.register(UINib(nibName: "GoalDefinitionCell", bundle: nil), forCellReuseIdentifier: "GoalDefinitionCell")
        
        
        // tblProfile.register(UINib(nibName: "ReminderHeaderCell", bundle: nil), forCellReuseIdentifier: "ReminderHeaderCell")
        
        tblProfile.register(UINib(nibName: "ProjectListCell", bundle: nil), forCellReuseIdentifier: "ProjectListCell")
        
        tblProfile.register(UINib(nibName: "CareerLevelCell", bundle: nil), forCellReuseIdentifier: "CareerLevelCell")
        tblProfile.register(UINib(nibName: "MyGoalCell", bundle: nil), forCellReuseIdentifier: "MyGoalCell")
        
      //  self.viewChangeUIFlow()
        
        tblProfile.delegate = self
        tblProfile.dataSource = self
       // tblProfile.expand(0)
    }
    
    //Enable Add Project
    func enableAddProject(){
        print(isProfileCellExpand)
        if isProfileCellExpand == "Closed"{
            self.btnAddProject.isHidden = true
            UserDefaults.standard.set(self.isProfileCellExpand, forKey: "isProfileCellExpand")
            UserDefaults.standard.synchronize()
            self.isProfileCellExpand = "open"
        }else{
            self.btnAddProject.isHidden = false
            UserDefaults.standard.set(self.isProfileCellExpand, forKey: "isProfileCellExpand")
            UserDefaults.standard.synchronize()
            self.isProfileCellExpand = "Closed"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appde = Constants.appDelegateRef
        appde.redirectConsoleLogToDocumentFolder()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        self.navigationController?.navigationBar.isHidden = true
        self.isProfileCellExpand = UserDefaults.standard.string(forKey: "isProfileCellExpand") ?? "Closed"
        Firestore.firestore().disableNetwork { (error) in
            self.getGoalDetails()
            self.getCompanyList()
            self.getPostingDetailsFB()
            self.projectListISLFirebase()
        }

        self.enableAddProject()
        strUserName = UserDefaults.standard.getUserName()
        strEmail    = UserDefaults.standard.getEmail()
        strDOB      = UserDefaults.standard.getDOB()
        strBase64   = UserDefaults.standard.getProfileImage()
        
        self.setProfile()
        
        self.resetLeaderBoardTimer()
        
        self.calculateProfileCompleteNess()
        self.tblProfile.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.isProfileCellExpand = ""
        self.profileCompletenessValue = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetLeaderBoardTimer(){
        let appde = Constants.appDelegateRef
        print("Total Timer Value  \(appde.totalLeaderBoardTimerCount)")
        appde.totalLeaderBoardTimerCount = 0
        appde.timerLeader.invalidate()
    }
    
    @IBAction func sendLogFile(_ sender: Any) {
        
        
        NSLog("=======================================")
        NSLog("            App Launched               ")
        NSLog("Device Model : \(UIDevice.current.model)")
        NSLog("Device Name  : \(UIDevice.current.name)")
        NSLog("iOS Version  : \(UIDevice.current.systemVersion)")
        
        let appde = Constants.appDelegateRef
        appde.redirectConsoleLogToDocumentFolder()

        
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let pathDocs = paths!.appendingPathComponent("console_log.txt")
        self.showFileWithPath(urlShare: pathDocs)
    }
    
    func showFileWithPath(urlShare: URL){
        docController = UIDocumentInteractionController(url: urlShare)
        docController?.delegate = self
        docController?.presentOptionsMenu(from: view.frame, in: UIApplication.shared.windows[0].rootViewController!.view, animated: true)
    }
    
    func setProfile(){
         self.setProfileDeatails(email: strEmail, userName: strUserName, dob: strDOB, strImage: self.strBase64)
    }
    
    //
    func setProfileDeatails(email: String, userName: String, dob: String , strImage:String){
    self.txtUserName.text = userName
    self.txtUserEmail.text = email
    self.txtDOB.text = dob
    
    if let dataDecoded : Data = Data(base64Encoded: strImage){
        if let image = UIImage(data: dataDecoded)
        {
            self.imgProfile.image = image
        }
        else
        {
            imgProfile.image = UIImage(named: "Userprofile")
        }
    }
}
    func calculateProfileCompleteNess(){
        self.profileCompletenessValue = 0
        strUserName = UserDefaults.standard.getUserName()
        strEmail    = UserDefaults.standard.getEmail()
        strDOB      = UserDefaults.standard.getDOB()
        strBase64   = UserDefaults.standard.getProfileImage()
        
        if !strUserName.isEmpty{
            self.profileCompletenessValue += 10
        }
        if !strEmail.isEmpty{
            self.profileCompletenessValue += 10
        }
        if !strDOB.isEmpty{
            self.profileCompletenessValue += 10
        }
        if !strBase64.isEmpty{
            self.profileCompletenessValue += 20
        }
        
        print("ProfileValue: \(profileCompletenessValue)")
        self.chnageProfileMenuBarIcon(strength: self.profileCompletenessValue)
    }
    
    //MARK:- Local Methods
    func editMenu(cell: ProfileCell){
        cell.txtDOB.delegate = self
        cell.txtDOB.tag = 2
        
        cell.txtName.delegate = self
        cell.txtName.tag = 0
        
        cell.txtMail.delegate = self
        cell.txtMail.tag = 1
        cell.selectionStyle = .none
    }
    
    func checkLogedIn(cell: ProfileCell){
        cell.txtDOB.isUserInteractionEnabled = false
        cell.txtName.isUserInteractionEnabled = false
        cell.txtMail.isUserInteractionEnabled = false
        
        let loginValue = UserDefaults.standard.string(forKey: "Login")
        if loginValue == "0"{
            
            if self.isEdited{
                cell.btnEdit.isHidden = false
            }else{
                cell.btnEdit.isHidden = true
            }
            
            cell.btnEdit.setTitle("SAVE", for: .normal)
            cell.btnEdit.isHidden = true
            cell.btnEdit.backgroundColor = UIColor.init(red: 26/255, green: 103/255, blue: 171/255, alpha: 0.4)
            cell.btnEdit.setTitleColor(UIColor.white, for: .normal)
            
            cell.txtDOB.isUserInteractionEnabled = true
            cell.txtName.isUserInteractionEnabled = true
            cell.txtMail.isUserInteractionEnabled = true
            
        }
            //        else if loginValue == "1"{
            //            cell.btnEdit.setTitle("EDIT", for: .normal)
            //            cell.btnEdit.backgroundColor = UIColor.init(red: 26/255, green: 103/255, blue: 171/255, alpha: 1.0)//UIColor.lightText
            //            cell.btnEdit.setTitleColor(UIColor.white, for: .normal)
            //
            //        }
        else{
            if self.isEdited{
                cell.btnEdit.isHidden = false
            }else{
                cell.btnEdit.isHidden = true
            }
            cell.btnEdit.setTitle("SAVE", for: .normal)
            cell.btnEdit.backgroundColor = UIColor.init(red: 26/255, green: 103/255, blue: 171/255, alpha: 1.0)//UIColor.lightText
            cell.btnEdit.setTitleColor(UIColor.white, for: .normal)
            cell.txtDOB.isUserInteractionEnabled = true
            cell.txtName.isUserInteractionEnabled = true
            cell.txtMail.isUserInteractionEnabled = false
        }
    }
    

    
    func showLogoutAlert() {
        let alertController = UIAlertController(title: "Alert!", message: NSLocalizedString("Are you sure you want change user?", comment:""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            //            Utility.sharedInstance.clearAllUserdata()
            //            Constants.appDelegateRef.requesetAutoLogoutProcess()
            UserDefaults.standard.set("", forKey: "MAIL")
            //            UserDefaults.standard.set("", forKey: "PSWD")
            UserDefaults.standard.synchronize()
            //            //  Constants.appDelegateRef.requesetAutoLogoutProcess()
            //            let story = UIStoryboard(name: "Main", bundle: nil)
            //            let vc = story.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            //            self.navigationController?.pushViewController(vc, animated: true)
            self.viewEmail.isHidden = false
            // self.createAccountFB()
            //  self.sendEmail(email: "colantest@gmail.com")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    @IBAction func buttonLogoutPressed(_ sender: UIButton) {
        showLogoutAlert()
    }
    
    @IBAction func userChangeAction(_ sender: Any) {
        print("Change user")
        changeUser()
    }
    
    @IBAction func realseNotesAction(_ sender: Any) {
        self.RealaseNotes()
    }
    @IBAction func AddProject(_ sender: Any) {
        //self.naviagteToAddProject()
        self.projectAdd()
    }
    
    @IBAction func changeProfileImage(_ sender: Any) {
         self.chooseuploadImage()
        
        
    }
    //MARK:- LogOut
    @objc func changeUser(){
        showLogoutAlert()
    }
    
    //MARK:- GOAL Firebase handler
    func getGoalDetails(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("myGoal").whereField("userId", isEqualTo: userId)
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.profileCompletenessValue += 10
                print("ProfileValue: \(self.profileCompletenessValue)")
                self.chnageProfileMenuBarIcon(strength: self.profileCompletenessValue)
                let myGoal = snap[0]
                self.strMyGoal = myGoal["goalText"] as? String ?? ""
                self.goalTimingValue = myGoal["GoalTime"] as? Int ?? 1
                self.goalType = myGoal["goalType"] as? Int ?? 0
                self.goalId = myGoal["goalId"] as? String ?? ""
                self.strProjectCategory = myGoal["projectCategory"] as? String ?? ""
                self.tblProfile.reloadData()
                
            }else{
               print("No Goal")
            }
            self.a = self.a + 1
            self.enableFirestoreNW()
        })
    }
    
    func enableFirestoreNW(){
        print(a)
        if a >= 4 {
            a = 0
            Firestore.firestore().enableNetwork(completion: nil)
        }
    }
   
    //MARK:- Add Goal API
    func getGOALJson() -> [String:Any]{
        return ["goalText" : self.strMyGoal,
                "GoalTime"  : self.goalTimingValue,
                "goalType" : self.goalType,
                "projectCategory" : self.strProjectCategory,
                "userId" : userId]
    }
    
    func updateGoal(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("myGoal").whereField("userId", isEqualTo: userId)
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                // if exist update
                let refExist = FirebaseManager.shared.firebaseDP!.collection("myGoal").document(snap[0].documentID)
                refExist.updateData(self.getGOALJson(), completion: { (error) in
                })
            }
            else{
                // add
                let refNew = FirebaseManager.shared.firebaseDP!.collection("myGoal")
                refNew.addDocument(data: self.self.getGOALJson(), completion: { (error) in
                })
            }
        }
    }
    
    func getCompanyList(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("companies")
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                self.arrayCompanies.removeAll()
                self.arrayCompanies += snap[0].get("companies") as? [[String:AnyObject]] ?? []
                self.reloadProfileData()
            }
            self.a = self.a + 1
            self.enableFirestoreNW()
        })
    }
    
    func getPostJSONFB() -> [String:Any]{
        return ["company_id" : companyID,
                "position_id" : PostingID,
                "posting_name" : strPostingName,
                "company_name" : strCompanyName,
                "user_id" : userId]
    }
    
    func addPostFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("companies_user").whereField("user_id", isEqualTo: userId)
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                
                // update value
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("companies_user").document(documentID)
                refExist.updateData(self.getPostJSONFB(), completion: { (error) in
                    
                   
                    UserDefaults.standard.set(self.strCompanyName, forKey: "CurrentCompany")
                    UserDefaults.standard.synchronize()
                    print("add post user update error: \(String(describing: error?.localizedDescription))")
                })
            }
            else
            {
                //insert value if new
                _ = FirebaseManager.shared.firebaseDP!.collection("companies_user").addDocument(data: self.getPostJSONFB(), completion: { (err) in
                    UserDefaults.standard.set(self.strCompanyName, forKey: "CurrentCompany")
                    UserDefaults.standard.synchronize()
                    print("add post user  insert error: \(String(describing: err?.localizedDescription))")
                })
            }
        }
    }
    
    func reloadProfileData(){
        arrComapnyList.removeAll()
        for obj in arrayCompanies{
            let model = CompanyListFB()
            model.comp_id = obj["comp_id"] as? String ?? "0"
            model.company_name = obj["company_name"] as? String ?? ""
            if model.company_name != "Other" {
                var postArray : [PostingListFB] = []
                for objPost in obj["posting"] as! [[String:String]]{
                    let postmodel = PostingListFB()
                    postmodel.post_id = objPost["post_id"] ?? "0"
                    postmodel.post_name = objPost["post_name"] ?? ""
                    postArray.append(postmodel)
                }
                model.posting = postArray
            }
            arrComapnyList.append(model)
        }
        self.arrCompanyName = self.arrComapnyList.map({$0.company_name ?? ""})
        self.checkCompanyName()
        self.tblProfile.reloadData()
    }
    
    func getPostingDetailsFB(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("companies_user").whereField("user_id", isEqualTo: userId)
        
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                
                self.profileCompletenessValue += 20
                print("ProfileValue: \(self.profileCompletenessValue)")
                self.chnageProfileMenuBarIcon(strength: self.profileCompletenessValue)
                
                self.PostingID = snap[0].get("position_id") as? String ?? "0"
                self.strPostingName = snap[0].get("posting_name") as? String ?? ""
                self.strCompanyName = snap[0].get("company_name") as? String ?? "Select your company"
                self.companyID = snap[0].get("company_id") as? String ?? ""
                UserDefaults.standard.set(self.strCompanyName, forKey: "CurrentCompany")
                UserDefaults.standard.synchronize()
            }
            else{
                self.PostingID = "0"
                self.companyID = ""
                self.strPostingName = ""
                self.strCompanyName = "Select your company"
            }
            self.a = self.a + 1
            self.enableFirestoreNW()
            self.arrCompanyName = self.arrComapnyList.map({$0.company_name ?? ""})
            self.checkCompanyName()
            self.tblProfile.reloadData()
        })
    }
    
    // Get Co
    func checkCompanyName(){
        getCompanyPostingList(companyName: strCompanyName)
        for company in arrComapnyList{
            if strCompanyName == company.company_name{
                arrPostingList = company.posting
                arrayCareerLevel = arrPostingList.map({$0.post_name ?? ""})
                print(arrayCareerLevel)
                
                UserDefaults.standard.set(self.arrayCareerLevel, forKey: "CurrentPosting")
                UserDefaults.standard.synchronize()
                
                break
            }else{
                continue
            }
        }
    }
    
    @objc func chooseCompanyName(sender: UIButton!) {
        selectedPicker = "company"
        listOfCompany(listData: arrCompanyName)
    }
    
    @objc func addWorkStream(sender: UIButton!) {
       self.vwWorkStream.isHidden = false
        
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblProfile)
        let cellIndexPath = self.tblProfile.indexPathForRow(at: pointInTable)
        
        let modelObj = arrProjectList[(cellIndexPath?.row)! - 1]
        self.strProjectID = modelObj.project_id ?? ""
        self.currentWorkStramData = modelObj.workStreamData ?? []
        
        
       let allData = modelObj.data
        
        for index in allData ?? []{
            print(index.isStatic ?? false)
            if index.isStatic == false{
                self.workStreamStatic = index
                self.isStatisStream = false
                break
            }else{
                print(" Not Static")
            }
        }
         self.strGoalName = modelObj.goal ?? ""
         self.meTime = (modelObj.meTime?.isEmpty)! ? "8" : modelObj.meTime ?? "8"
         self.sleep = (modelObj.sleep?.isEmpty)! ? "17" : modelObj.sleep ?? "17"
        //modelObj.meTime ?? ""
         self.excercise = modelObj.excercise ?? ""
        
        print("ProJectName : \(modelObj.project_name ?? "")")
        print("ProJect_ID : \(modelObj.project_id ?? "")")
    }
    
    @IBAction func cencelWorkStream(_ sender: UIButton) {
        self.vwWorkStream.isHidden = true
        txtAssigned.text = ""
        txtWorkStreamName.text = ""
    }
    
    @IBAction func addWorkStreamAction(_ sender: UIButton) {
        self.vwWorkStream.isHidden = true
        if (txtWorkStreamName.text?.isEmpty)!{
            Utilities.sharedInstance.showToast(message: "Please enter Work stream name")
        }else{
            self.view.endEditing(true)
            if self.isStatisStream == false{
                self.staticworkStream()
            }else{
                self.workStreamNotStatic()
            }
        }
    }
    
    func workStreamNotStatic(){
        self.workStreamName = txtWorkStreamName.text ?? ""
        let len = 16
        let randomNumber = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
        let weeklyPlannerID = String((0..<len).map{ _ in randomNumber[Int(arc4random_uniform(UInt32(randomNumber.count)))]})
        print(weeklyPlannerID)   // "oLS1w3bK\n"
        let assignedName = (self.txtAssigned.text?.count)! > 0 ? self.txtAssigned.text : "ME"
        let emptyArray = ["","","","",""]
        
        let dict = ["id" : weeklyPlannerID,
                    "WorkStream" : self.workStreamName,
                    "Meetings":emptyArray,
                    "Research" : emptyArray,
                    "userName" : assignedName ?? "ME",
                    "Deliverable" : emptyArray,
                    "relation":"",
                    "Travel" : "",
                    "isNotStatic" : true,
                    "packed": "0"] as [String : Any]
        self.currentWorkStramData.append(dict)
        txtWorkStreamName.text = ""
        txtAssigned.text = ""
        self.isStatisStream = true
        self.addWorkStreamAPI()
    }
    
    func staticworkStream(){
        self.workStreamName = txtWorkStreamName.text ?? ""
        let emptyArray = ["","","","",""]
        
        let assignedName = (self.txtAssigned.text?.count)! > 0 ? self.txtAssigned.text : "ME"
        
        let dict = ["id" : self.workStreamStatic.id ?? "",
                    "WorkStream" : self.workStreamName,
                    "Meetings":self.workStreamStatic.Meetings ?? emptyArray,
                    "Research" : self.workStreamStatic.Research ?? emptyArray,
                    "userName" : assignedName  ?? "ME",
                    "Deliverable" : self.workStreamStatic.Deliverable ?? emptyArray,
                    "relation": self.workStreamStatic.relation ?? "",
                    "Travel" : self.workStreamStatic.Travel ?? "",
                    "isNotStatic" : true,
                    "packed": self.workStreamStatic.packed ?? "0"] as [String : Any]
        self.currentWorkStramData = [dict]
        txtWorkStreamName.text = ""
        txtAssigned.text = ""
        self.isStatisStream = true
        self.addWorkStreamAPI()
    }
    
    @IBAction func cacelOtherCompany(sender: UIButton){
        if selectedPicker == "category"{
            viewOtherCompany.isHidden = true
            vwCategory.isHidden = true
            strProjectCategory = ""
            self.twCategory.text = ""
           self.tblProfile.reloadData()
        }else{
        viewOtherCompany.isHidden = true
        strCompanyName = strPreCompanyName
        self.tblProfile.reloadData()
        }
    }
    
    @IBAction func saveOtherCompany(sender: UIButton){
        
        if selectedPicker == "category"{
            viewOtherCompany.isHidden = true
            vwCategory.isHidden = true
            strProjectCategory = self.twCategory.text
            self.twCategory.text = ""
            self.tblProfile.reloadData()
            self.updateGoal()
        }else{
        if (txtOtherComp.text?.count)! > 0 && (txtOtherPost.text?.count)! > 0 {
            companyID = "14"
            strCompanyName = txtOtherComp.text!
            strPostingName = txtOtherPost.text!
            self.addPostFirebase();
            self.tblProfile.reloadData()
            viewOtherCompany.isHidden = true
            
        }else{
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.other_details)!)
        }
        }
    }
    
    @IBAction func cacelViewEmail(sender: UIButton){
        viewEmail.isHidden = true
        self.tblProfile.reloadData()
    }
    
    @IBAction func saveEamilHandler(sender: UIButton){
        
        if (txtEmail.text?.count)! > 0 {
            strEmailSwitch = txtEmail.text!
           // self.switchUserFB();
           self.checkExistUser()
            
        }else{
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.emailid)!)
        }
    }
    
    func switchUserFB()
    {
        self.sendSignInLink()
       // self.loginFirebase()
    }
    
    func checkExistUser()
    {
        self.viewEmail.isHidden = true
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("users").whereField("e_mail", isEqualTo: strEmailSwitch)
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                // self.loginFirebase()
                self.configureMail()
            }
            else{
                self.createNewUser()
            }
        })
    }
    
  
    
    //MARK: - RegisterISL
    @objc func loginFirebase(){
        //let firebaseAuth = Auth.auth()
        let ref = FirebaseManager.shared.firebaseDP!.collection("users").whereField("e_mail", isEqualTo: strEmailSwitch)
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                UserDefaults.standard.setLoggedIn(value: true)
                UserDefaults.standard.setUserName(value: snap[0].get("user_name") as? String ?? "")
                UserDefaults.standard.setProfileImage(value: snap[0].get("prof_pic") as? String ?? "")
                UserDefaults.standard.setEmail(value: snap[0].get("e_mail") as? String ?? "")
                UserDefaults.standard.setDOB(value: snap[0].get("dob") as? String ?? "")
                UserDefaults.standard.setUserID(value: snap[0].documentID)
                UserDefaults.standard.set("1", forKey: "Login")
                UserDefaults.standard.synchronize()
                
                self.strUserName = UserDefaults.standard.getUserName()
                self.strEmail    = UserDefaults.standard.getEmail()
                self.strDOB      = UserDefaults.standard.getDOB()
                self.strBase64   = UserDefaults.standard.getProfileImage()
                
                self.viewEmail.isHidden = true
                self.setProfile()
                self.tblProfile.reloadData()
            }
        })
    }
    
    func createNewUser()
    {
        var bIsSuccess     = false
        var errorMessage   = ""
        
        if self.strEmailSwitch == "" {
            errorMessage = Constants.ErrorMessage.email
            
        }else if !Utilities.sharedInstance.validateEmail(with:self.strEmailSwitch ){
            errorMessage = Constants.ErrorMessage.vaildemail
            
        }else{
            bIsSuccess = true
        }
        
        if !bIsSuccess {
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
        }else
        {
            self.requestRegisterFirebase()
            
        }
    }
    
    
    //MARK:- Laddar Button
    func setLadderButton(cell:CareerLevelCell) {
        for case let deleteView in cell.vwContent.subviews {
            deleteView.removeFromSuperview()
        }
        
        let green = UIColor.init(red: 66.0/255.0, green: 166.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
        let yellow = UIColor.init(red: 243.0/255.0, green: 203.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        
        var x = 20
        var y = 30 + (20 * (arrayCareerLevel.count - 1 ))
        for i in 0..<arrayCareerLevel.count {
            var button1 = UIButton(frame: CGRect(x: x, y: y, width: 77, height: 40))

            print(x)
            print(y)
            
            let text = arrayCareerLevel[i]
            if text == "Job Seeker"{
                button1 = UIButton(frame: CGRect(x: x, y: y-20, width: 77, height: 40))
                button1.contentHorizontalAlignment = .center
            }else{
                button1 = UIButton(frame: CGRect(x: x, y: y, width: 77, height: 40))
                button1.contentHorizontalAlignment = .center
            }
            
            button1.setTitle(arrayCareerLevel[i].capitalized, for: .normal)
            button1.backgroundColor = UIColor.white
            button1.titleLabel?.textColor = UIColor.red
            button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button1.setTitleColor(UIColor.darkGray, for:.normal)
            //button1.setTitleColor(UIColor.black, for:.selected)
            button1.contentVerticalAlignment = .top
            button1.titleLabel?.numberOfLines = 2
            button1.titleLabel?.lineBreakMode  = .byWordWrapping
            button1.tag = i
            
            
            var pointerView = UIView()
            pointerView.backgroundColor = UIColor.red
            var  extraView = UIView(frame: CGRect(x: x-8, y: y-8, width: 80, height: 35))
            
            if text == "Job Seeker"{
                extraView = UIView(frame: CGRect(x: x-3, y: y-15, width: 0, height: 0))
             //   pointerView = UIView(frame: CGRect(x: x+50, y: y-40, width: 20, height: 20))
            }else{
                extraView = UIView(frame: CGRect(x: x-8, y: y-8, width: 80, height: 35))
            }
            
            //Current Position
            if strPostingName == arrayCareerLevel[i]{
                extraView.backgroundColor = green//Constants.getCustomBlueColor()
                button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                button1.setTitleColor(green, for:.normal)
                button1.underline()
              // pointerView = UIView(frame: CGRect(x: x+50, y: y-30, width: 20, height: 20))

            }
            else{
                pointerView = UIView(frame: CGRect(x: x+50, y: y-40, width: 20, height: 20))
                extraView.backgroundColor = yellow
            }
            
            button1.addTarget(self, action: #selector(selectedButton), for: .touchUpInside)
            // extraView.backgroundColor = UIColor.darkGray
            extraView.tag = i
            
            cell.vwContent.addSubview(extraView)
          // cell.vwContent.addSubview(pointerView)
            cell.vwContent.addSubview(button1)
            cell.vwContent.bringSubview(toFront: button1)
            
            x += 85
            y = y - 20
        }
    }
    
    @objc func selectedButton(sender:UIButton) {
        
        let green = UIColor.init(red: 66.0/255.0, green: 166.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
        let yellow = UIColor.init(red: 243.0/255.0, green: 203.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        
        if let superView = sender.superview {
            for case let selectedView as UIView in superView.subviews {
                if sender.tag == selectedView.tag {
                    selectedView.backgroundColor = green//Constants.getCustomBlueColor()
                    sender.backgroundColor = UIColor.white
                    sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                    sender.setTitleColor(green, for:.normal)
                    sender.underline()
                } else {
                    if !selectedView.isKind(of: UIButton.self) {
                        selectedView.backgroundColor = yellow//UIColor.random
                    } else {
                        for case let remainingButton as UIButton in superView.subviews  {
                            if !(remainingButton.tag == sender.tag) {
                                remainingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                                remainingButton.attributedTitle(for: .disabled)
                                remainingButton.removeUnderLine()
                                remainingButton.setTitleColor(UIColor.darkGray, for:.normal)
                            }
                        }
                    }
                }
            }
        }
        strPostingName = sender.titleLabel?.text ?? ""
        
        UserDefaults.standard.set(strPostingName, forKey: "Role")
        UserDefaults.standard.synchronize()
        getPostingDetails(postName: strPostingName)
    }
    
    func getCompanyPostingList(companyName: String){
        for company in arrComapnyList{
            let name = company.company_name
            if companyName == name{
                companyID = company.comp_id ?? ""
                let postingList = company.posting
                self.arrayCareerLevel = postingList.map({$0.post_name!})
                print("Current Postings \(self.arrayCareerLevel)")
                
                arrPostingList = company.posting
                self.tblProfile.reloadData()
                break
            }else{
                continue
            }
        }
    }
    
    // Posting Details
    @objc func getPostingDetails(postName: String){
        for posting in arrPostingList{
            let postName = posting.post_name
            if postName == strPostingName{
                PostingID = posting.post_id ?? ""
                //API Call
                //addPostAPI()
                self.addPostFirebase()
                
                UserDefaults.standard.set(self.arrayCareerLevel, forKey: "CurrentPosting")
                UserDefaults.standard.synchronize()
                
                print(PostingID)
                break
            }else{
                continue
            }
        }
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    //MARK:- Add Posting Details API
    func getPostJSON() -> [String:Any]{
        return ["company_id" : companyID,
                "position_id" : PostingID,
                "user_id" : userId]
    }
    
    @objc func Edit(_ sender: UIButton) {
        //   editProfileDetail()
        self.chooseuploadImage()
    }
    
    @objc func editProfileDetail(sender: UIButton){
        self.isEdited = false
        
        let bISSuccess = editProfileValidate()
        if bISSuccess {
            requestEditFirebase()
        }
    }
    
    @objc func RealaseNotes(){
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "ReleaseNotesVC") as! ReleaseNotesVC
        self.navigationController?.pushViewController(nextVC, animated: true)

    }
    
    @objc func feedbackHanlder(){
        let alert = UIAlertController(title: "Choose Survey", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "NPS iOS", style: .default, handler: { _ in
            self.feedbackVC = SMFeedbackViewController.init(survey: "99Q55W6")
            self.feedbackVC?.delegate = self
            self.feedbackVC?.present(from: self, animated: true, completion: {
            })
        }))
        alert.addAction(UIAlertAction(title: "Weekly poll iOS", style: .default, handler: { _ in
            self.feedbackVC = SMFeedbackViewController.init(survey: "TWBQV6V")
            self.feedbackVC?.delegate = self
            self.feedbackVC?.present(from: self, animated: true, completion: {
            })
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func respondentDidEndSurvey(_ respondent: SMRespondent!, error: Error!) {
        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.thanks_survey)!)
    }
    
    @IBAction func adminAction(_ sender: Any) {
        let story = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "AdminVC") as! AdminVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDeleteAlert() {
        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString("Do you want to delete the project?", comment:""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            
            //Call Delete API
            //self.deleteProjectAPI()
            self.deleteProjectApiFirebase()
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    func projectListISLFirebase()
    {
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: userId)
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents {
                if snap.count > 0
                {
                    self.arrProjectList.removeAll()
                    self.profileCompletenessValue += 20
                    print("ProfileValue: \(self.profileCompletenessValue)")
                    self.chnageProfileMenuBarIcon(strength: self.profileCompletenessValue)
                    
                    self.parseIntoModel(snap: snap)
                    self.tblProfile.reloadData()
                }
                self.a = self.a + 1
                self.enableFirestoreNW()
            }
            self.tblProfile.reloadData()
        })
    }
    
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        arrProjectList.removeAll()
        for obj in snap{
            let model = ProjectModelFB()
            model.client_name = obj["client_name"] as? String ?? ""
            model.date = obj["date"] as? String ?? ""
            model.end_date = obj["end_date"] as? String ?? ""
            model.meeting_point = obj["meeting_point"] as? String ?? "0"
            model.project_id = obj.documentID
            model.project_image = obj["project_image"] as? String ?? ""
            model.project_name = obj["project_name"] as? String ?? ""
            model.start_date = obj["start_date"] as? String ?? ""
            model.user_id = obj["user_id"] as? String ?? ""
            model.workStreamData = obj["workStreamData"] as? [[String:Any]] ?? []
            
            model.goal = obj["goal"] as? String ?? ""
            model.excercise = obj["excercise"] as? String ?? ""
            model.meTime = obj["meTime"] as? String ?? ""
            model.sleep = obj["sleep"] as? String ?? ""
            
            var arrSub : [WeeklyPlannerData] = []
            for sub in obj["workStreamData"] as? [[String:Any]] ?? []{
                var submodel = WeeklyPlannerData()
                submodel.id = sub["id"]  as? String ?? ""
                submodel.WorkStreamName = sub["WorkStream"] as? String ?? ""
                submodel.Deliverable = sub["Deliverable"] as? [String] ?? []
                
                submodel.Meetings = sub["Meetings"] as? [String] ?? []
                submodel.Research = sub["Research"] as? [String] ?? []
                submodel.Travel   = sub["Travel"] as? String ?? ""
                submodel.userName = sub["userName"] as? String ?? ""
                submodel.isStatic = sub["isNotStatic"] as? Bool ?? false
                submodel.packed = sub["packed"] as? String ?? ""
                submodel.relation = sub["relation"] as? String ?? ""
                arrSub.append(submodel)
            }
            model.data = arrSub
            print(arrSub)
            
            arrProjectList.append(model)
        }
        self.tblProfile.reloadData()
    }
    func deleteProjectApiFirebase(){
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").document(strProjectID)
        ref.delete { (error) in
            if error == nil{
                self.arrProjectList.removeAll()
                self.projectListISLFirebase()
                self.deleteAllChildRelatedProject()
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Delete project failed,try again later", controller: self)
            }
        }
        
        
        // Offline
        self.arrProjectList.removeAll()
        self.projectListISLFirebase()
        self.deleteAllChildRelatedProject()
        
    }
    
    
    func deleteAllChildRelatedProject(){
        // delete add meeting related to project id
        let refAddMeeting=FirebaseManager.shared.firebaseDP!.collection("add_meeting").whereField("project_id", isEqualTo:self.strProjectID)
        refAddMeeting.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("add_meeting").document(doc.documentID).delete()
                }
            }
            
        })
        
        // delete project career related to project id
        
        let refProCareer=FirebaseManager.shared.firebaseDP!.collection("project_career").whereField("project_id", isEqualTo:self.strProjectID)
        refProCareer.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("project_career").document(doc.documentID).delete()
                }
            }
            
        })
        
        // delete value added related to project id
        
        let refValueAdded=FirebaseManager.shared.firebaseDP!.collection("value_added").whereField("project_id", isEqualTo:self.strProjectID)
        refValueAdded.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("value_added").document(doc.documentID).delete()
                }
            }
        })
        
        // delete work life balance related to project id
        
        let refWork=FirebaseManager.shared.firebaseDP!.collection("work_life_bal").whereField("project_id", isEqualTo:self.strProjectID)
        refWork.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("work_life_bal").document(doc.documentID).delete()
                }
            }
            
        })
    }
}

extension ProfileViewController: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right{
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                print("Delete")
                //self.navigateToEditProjectScreen(index: indexPath, strActionType: "delete")
                
                let projectObj = self.arrProjectList[indexPath.row - 1]
                self.strProjectID = projectObj.project_id!
                self.showDeleteAlert()
                
            }
            // customize the action appearance
            deleteAction.backgroundColor = UIColor.red
            deleteAction.textColor = UIColor.black
            return [deleteAction]
        }else{
            let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
                print("Edit")
               // self.navigateToEditProjectScreen(index: indexPath, strActionType: "edit")
                let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
                let nextVC =  story.instantiateViewController(withIdentifier: "AddProjectVC") as! AddProjectVC
                nextVC.fromVC = "edit"
                nextVC.projectModelObj = self.arrProjectList[indexPath.row - 1]
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            editAction.backgroundColor = UIColor.yellow
            editAction.textColor = UIColor.black
            return [editAction]
        }
    }
}




//MARK:- CustomPicker Methods
extension ProfileViewController :CustomPickerDelegate {
    
    func createCustomPickerInstance(){
        customPickerObj = Utilities.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    
    func listOfCompany(listData : [String]){
        
        customPickerObj.totalComponents = 1
        customPickerObj.arrayComponent = listData
        addCustomPicker()
        
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_String)
        customPickerObj.customPicker.reloadAllComponents()
    }
    
    func addCustomPicker() {
        self.view.addSubview(customPickerObj.view)
        self.customPickerObj.vwBaseView.frame.size.height = self.view.frame.size.height
        self.customPickerObj.vwBaseView.frame.size.width = self.view.frame.size.width
    }
    
    func removeCustomPicker(){
        if customPickerObj != nil{
            customPickerObj.view.removeFromSuperview()
        }
    }
    
    func itemPicked(item: AnyObject) {
        
        strPreCompanyName = strCompanyName
        if selectedPicker == "dob"{
            let pickerDateValue = item as! Date
            let dateFormatObj = DateFormatter()
            dateFormatObj.dateFormat = "dd/MM/yyyy"
            dateFormatObj.locale = Locale(identifier: "en-US")
            let strDate =  dateFormatObj.string(from: pickerDateValue)
            //  txtDOB.text = strDate
            self.strDOB = strDate
            UserDefaults.standard.setDOB(value: strDOB )
            UserDefaults.standard.synchronize()
            self.calculateProfileCompleteNess()
            self.setProfile()
           // self.tblProfile.reloadData()
            
        }else if selectedPicker == "company"{
            let pickerDateValue = item as! String
            strCompanyName = pickerDateValue
            if strCompanyName == "Other"{
                self.viewOtherCompany.isHidden = false
                self.tblProfile.reloadData()
            }else{
                getCompanyPostingList(companyName: strCompanyName)
            }
        }else{
            let pickerDateValue = item as! String
            print(pickerDateValue)
            let  strCategory = pickerDateValue
            strProjectCategory = strCategory
            if strCategory == "other"{
                self.viewOtherCompany.isHidden = false
                self.vwCategory.isHidden = false
            }
            self.updateGoal()
            self.tblProfile.reloadData()
        }
        removeCustomPicker()
    //    selectedPicker = ""
    }
    
    func pickerCancelled(){
        removeCustomPicker()
        selectedPicker = ""
    }
}

extension ProfileViewController: CommentDelegates{
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
        let story = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "Profile"
        nextVC.strUserType = "Me"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func commentAnonymous() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = "0"
        nextVC.strFromVC = "Profile"
        nextVC.strUserType = "Ananymous"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func canceled() {
        removeCustomComment()
    }
}


extension ProfileViewController: RSKImageCropViewControllerDelegate{
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        let imageData: Data! = UIImageJPEGRepresentation(croppedImage, 0.2)
        self.strBase64 = imageData.base64EncodedString()
        UserDefaults.standard.setProfileImage(value: self.strBase64)
        UserDefaults.standard.synchronize()
        self.isEdited = true
        self.setProfile()
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension ProfileViewController:  RSKImageCropViewControllerDataSource {
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        return UIBezierPath(rect: controller.maskRect)
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect{
        return CGRect(x: 0, y: 0, width: 375, height: 200)
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
}

extension ProfileViewController: ExpyTableViewDataSource,ExpyTableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrHeader.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3{
            return arrProjectList.count + 1
        }
            //else if section == 1{
            //   return arrMygoal.count
            // }
        else{
            return 2
        }
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        cell.labelPhoneName.text = arrHeader[section]
         cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {  // Profile
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
//
//            cell.btnLogOut.addTarget(self, action: #selector(changeUser), for: .touchUpInside)
//            cell.btnEdit.addTarget(self, action: #selector(editProfileDetail), for: .touchUpInside)
//            cell.btFAQ.addTarget(self, action: #selector(RealaseNotes), for: .touchUpInside)
//            cell.btFeedback.addTarget(self, action: #selector(feedbackHanlder), for: .touchUpInside)
//            cell.btnProfile.addTarget(self, action: #selector(Edit), for: .touchUpInside)
//
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Edit))
//            cell.imgProfile.addGestureRecognizer(tapGesture)
//
//            self.editMenu(cell: cell)
//            self.checkLogedIn(cell: cell)
//            cell.setCellDetails(email: strEmail, userName: strUserName, dob: strDOB, strImage: self.strBase64)
//            return cell
//        }
        
       // else
//        if indexPath.section == 0{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MyGoalCell", for: indexPath) as! MyGoalCell
//            self.getGoalName(intGoal: self.goalType)
//            cell.myGoalTopSelectionView(strMyGoal: self.currentGoalSelected, timing: self.goalTimingValue, isSelected : self.isMyGoalSelected)
//
//            let tap = UITapGestureRecognizer(target: self, action: #selector(selectMyGoal))
//            tap.delegate = self
//            cell.lblMyGoal.isUserInteractionEnabled = true
//            cell.lblMyGoal.addGestureRecognizer(tap)
//            self.myGoalHeight = Int(cell.lblMyGoal.frame.height)
//
//            cell.btnOthers.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnAccelerated.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnPersonal.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnContribute.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnLessStress.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.slider.addTarget(self, action: #selector(sliderValue), for: .valueChanged)
//            cell.twMyGoal.delegate = self
//            cell.selectionStyle = .none
//
//            cell.changeUI(typeValue:self.goalType, strGoal: self.strMyGoal, timing: self.goalTimingValue)
//
//            return cell
//        }
//        else
            if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoalDefinitionCell", for: indexPath) as! GoalDefinitionCell
            self.configGaolListUI(cell: cell)
            self.addtapgestureToselectGoal(cell: cell)
           
            cell.twGoal.delegate = self
            self.selectedGoal(cell: cell)
            cell.heightOtherContraint.constant = CGFloat(self.checkOtherOption())
            
            cell.twGoal.text = "\(self.strMyGoal)"
            self.myGoalHeight = Int(cell.lblGoal.frame.height)
            cell.myGoalTopSelectionView(arrGoal: self.arrSelectedGoalsList, duration: self.GoalDuration, isSelected : self.isMyGoalSelected)

            return cell
        }
        else if indexPath.section == 1 {  //  // Career Level
            let cell = tableView.dequeueReusableCell(withIdentifier: "CareerLevelCell", for: indexPath) as! CareerLevelCell
            cell.btnCompanyName.setTitle(strCompanyName, for: .normal)
            cell.btnCompanyName.addTarget(self, action: #selector(chooseCompanyName), for: .touchUpInside)
            
            if companyID == "14"{
                cell.careerLadderLVal.text = strPostingName
            }else{
                setLadderButton(cell: cell)
                cell.careerLadderLVal.text = ""
                cell.careerLevel(strComapny: strCompanyName)
                cell.setWidth(arrayCareerLevel: arrayCareerLevel, frameView: self.view)
                cell.selectionStyle = .none
                setLadderButton(cell:cell)
            }
            return cell
            }else if indexPath.section == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyGoalCell", for: indexPath) as! MyGoalCell
                 self.addtapgestureCompareMyself(cell: cell)
                return cell
            }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectListCell", for: indexPath) as! ProjectListCell
            let modelObj = arrProjectList[indexPath.row - 1]
            cell.lblProjectName.text = modelObj.project_name ?? ""
          //  cell.lblProjectStatus.text = modelObj.date ?? ""
            cell.contentView.backgroundColor = UIColor.red
            let index = (indexPath.row) - 1
            let model = arrProjectList[index]
            let workStream = model.data as? [WeeklyPlannerData] ?? []
            self.arrWorkStream.removeAll()
            var arrUserName = [String]()
            if workStream.count > 0{
                self.arrWorkStream = workStream.map({$0.WorkStreamName ?? ""})
                arrUserName = workStream.map({$0.userName ?? ""})
              let checkStatic = self.isStatic(workStream: workStream)
                
                if checkStatic{
                    print(self.arrWorkStream)
                }else{
                    self.arrWorkStream.removeAll()
                }
            }else{
            }
           
            cell.changeUI(arrWorkStream: self.arrWorkStream, userName: arrUserName)
            if let profileStr = modelObj.project_image, profileStr.count > 0{
                let dataDecoded : Data = Data(base64Encoded: profileStr)!
                cell.imgApplying.image = UIImage(data: dataDecoded)
            }else{
                cell.imgApplying.image = UIImage(named: "noImage")
            }
            cell.btnAddWorkStream.addTarget(self, action: #selector(addWorkStream), for: .touchUpInside)
            cell.selectionStyle = .none
            cell.delegate = self as? SwipeTableViewCellDelegate
            return cell
        }
    }
    
    
    //MARK:- My Goal Time Tiles
    func addtapgestureToselectGoal(cell: GoalDefinitionCell){
        cell.selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectMyGoal))
        tap.delegate = self
        cell.lblGoal.isUserInteractionEnabled = true
        cell.lblGoal.addGestureRecognizer(tap)
        
        cell.btnOneYear.addTarget(self, action: #selector(selectTimeForGoal), for: .touchUpInside)
        cell.btnTwoYear.addTarget(self, action: #selector(selectTimeForGoal), for: .touchUpInside)
        cell.btnThreeYear.addTarget(self, action: #selector(selectTimeForGoal), for: .touchUpInside)
        cell.btnNoPressure.addTarget(self, action: #selector(selectTimeForGoal), for: .touchUpInside)
       // cell.myGoalTopSelectionView(arrGoal: self.arrSelectedGoalsList, duration: self.GoalDuration, isSelected : self.isMyGoalSelected)
    }
    
    //Select Time Tiles
    @objc func selectTimeForGoal(_ sender: UIButton){
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblProfile)
        let cellIndexPath = self.tblProfile.indexPathForRow(at: pointInTable)
        let cell = tblProfile.cellForRow(at: cellIndexPath!) as? GoalDefinitionCell
        
        self.changeTimeGoalDetails(cell: cell!)
        
        let tagValue = sender.tag
        print(tagValue)
     
        let green = UIColor.init(red: 66.0/255.0, green: 166.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        switch tagValue {
        case 0:
            cell?.vwOneYear.backgroundColor = green
            self.changeImageandlabelTextColor(selectedView: cell!.vwOneYear, imageName: "YearW")
            self.GoalDuration = "with in 1 year"
        case 1:
            cell?.vwTwoYear.backgroundColor = green
            self.changeImageandlabelTextColor(selectedView: cell!.vwTwoYear, imageName: "YearW")
            self.GoalDuration = "2 years"
        case 2:
            cell?.vwThreeYear.backgroundColor = green
            self.changeImageandlabelTextColor(selectedView: cell!.vwThreeYear, imageName: "YearW")
            self.GoalDuration = "3 years"
        case 3:
            cell?.vwNoPressure.backgroundColor = green
            self.changeImageandlabelTextColor(selectedView: cell!.vwNoPressure, imageName: "TimeW")
            self.GoalDuration = "No time pressure"
        default:
            print("Default")
        }
        
        cell?.myGoalTopSelectionView(arrGoal: self.arrSelectedGoalsList, duration: self.GoalDuration, isSelected : self.isMyGoalSelected)
        
    }
    
    
    func changeImageandlabelTextColor(selectedView: UIView, imageName: String){
        
        // One year
        for subViews in selectedView.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: imageName)
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.white
            }
        }
    }
    
    func changeTimeGoalDetails(cell: GoalDefinitionCell){
        cell.vwOneYear.backgroundColor = UIColor.clear
        cell.vwTwoYear.backgroundColor = UIColor.clear
        cell.vwThreeYear.backgroundColor = UIColor.clear
        cell.vwNoPressure.backgroundColor = UIColor.clear
        
        // One year
        for subViews in cell.vwOneYear.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
            img.image = UIImage(named: "YearG")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
        
        // Two year
        for subViews in cell.vwTwoYear.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: "YearG")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
        
        // Three year
        for subViews in cell.vwThreeYear.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: "YearG")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
        
        //No Time
        // Three year
        for subViews in cell.vwNoPressure.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: "TimeG")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
        
    }
    
    
    //MARK:- Compare Myself Details
    func addtapgestureCompareMyself(cell: MyGoalCell){
        cell.btnOwnHistory.addTarget(self, action: #selector(selectCompareMyself), for: .touchUpInside)
        cell.btnFirmPeers.addTarget(self, action: #selector(selectCompareMyself), for: .touchUpInside)
        cell.btnCountry.addTarget(self, action: #selector(selectCompareMyself), for: .touchUpInside)
        cell.btnWorldWide.addTarget(self, action: #selector(selectCompareMyself), for: .touchUpInside)
    }
    
    //Select Time Tiles
    @objc func selectCompareMyself(_ sender: UIButton){
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblProfile)
        let cellIndexPath = self.tblProfile.indexPathForRow(at: pointInTable)
        let cell = tblProfile.cellForRow(at: cellIndexPath!) as? MyGoalCell
        
      //  self.changeTimeGoalDetails(cell: cell!)
        self.changeCompareMyselfDetails(cell: cell!)
        let tagValue = sender.tag
        
        let green = UIColor.init(red: 66.0/255.0, green: 166.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        switch tagValue {
        case 0:
            cell?.vwOwnHistory.backgroundColor = green
            self.changeImageandlabelCompareMyself(selectedView: cell!.vwOwnHistory, imageName: "HistoryW")
        case 1:
            cell?.vwFirmPeers.backgroundColor = green
            self.changeImageandlabelCompareMyself(selectedView: cell!.vwFirmPeers, imageName: "UserW")
        case 2:
            cell?.vwCountry.backgroundColor = green
            self.changeImageandlabelCompareMyself(selectedView: cell!.vwCountry, imageName: "CountryWhite")
        case 3:
            cell?.vwWorldWide.backgroundColor = green
            self.changeImageandlabelCompareMyself(selectedView: cell!.vwWorldWide, imageName: "WorldW")
        default:
            print("Default")
        }
    }
    
    
    func changeImageandlabelCompareMyself(selectedView: UIView, imageName: String){
        
        // One year
        for subViews in selectedView.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: imageName)
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.white
            }
        }
    }
    
    func changeCompareMyselfDetails(cell: MyGoalCell){
        cell.vwOwnHistory.backgroundColor = UIColor.clear
        cell.vwFirmPeers.backgroundColor = UIColor.clear
        cell.vwCountry.backgroundColor = UIColor.clear
        cell.vwWorldWide.backgroundColor = UIColor.clear
        
        // One year
        for subViews in cell.vwOwnHistory.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: "HistoryG")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
        
        // Two year
        for subViews in cell.vwFirmPeers.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: "UserG")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
        
        // Three year
        for subViews in cell.vwCountry.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: "CountryGreen")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
        
        //No Time
        // Three year
        for subViews in cell.vwWorldWide.subviews{
            if let img = subViews.viewWithTag(subViews.tag) as? UIImageView{
                img.image = UIImage(named: "WorldG")
            }
            if let lbl = subViews.viewWithTag(subViews.tag) as? UILabel{
                lbl.textColor = UIColor.black
            }
        }
    }
    
    
    
    //MARK:- Expand Goal Index
    @objc func selectMyGoal(_ gesture: UITapGestureRecognizer){
        self.isMyGoalSelected.toggle()
        self.tblProfile.reloadData()
        print("doubletapped")
    }
    
    // Select Category of projects
    @objc func selectCategory(_ gesture: UITapGestureRecognizer){
        selectedPicker = "category"
        let arrCategory = ["professional","private","entrepreneur","career","personal branding","vacation","other"]
        listOfCompany(listData: arrCategory)
    }
    
    //Change Change Goal Definition
    func setupGoalDefination(arrGoal: [String]) -> String{
        var strGoal = ""

        if arrGoal.count == 0{
            strGoal = "Select goals for consutants"
        }else{
            for index in arrGoal{
                strGoal.append("- \(index) \n")
            }
            print(strGoal)
        }
        return strGoal
    }
    
    
    func getGoalName(intGoal : Int){
        switch intGoal {
        case 0:
            self.currentGoalSelected = "Accelerated Career"
        case 1:
            self.currentGoalSelected = "Less stress more free-time"
        case 2:
            self.currentGoalSelected = "Contribute to profession"
        case 3:
            self.currentGoalSelected = "Personal"
        case 4:
            self.currentGoalSelected = self.strMyGoal
        default:
            print("Empty")
        }
    }
    
    func isStatic(workStream : [WeeklyPlannerData]) -> Bool{
        var staticValue = true
        for index in workStream ?? []{
            if index.isStatic == false{
                staticValue = false
                break
            }else{
                staticValue = true
            }
        }
        return staticValue
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
        print("Did selected")
        
        if indexPath.section == 3{
            if indexPath.row == 0{
                self.enableAddProject()
            }else{
               // navigateToEditProjectScreen(index: indexPath, strActionType: "addProject")
                let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
                let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
                let modelObj = arrProjectList[indexPath.row - 1]
                nextVC.projectName     = modelObj.project_name!
                nextVC.projectID       = modelObj.project_id!
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//
//            if indexPath.row == 0{
//                return 50
//            }else{
//                if isMyGoalSelected {
//                    return CGFloat(self.myGoalHeight)+390
//                }else{
//                    return UITableViewAutomaticDimension
//                }
//            }
//            //self.goalRowHeight
//        }
//        else
            if indexPath.section == 0{
            if indexPath.row == 0{
                return 50
            }else{
                if isMyGoalSelected {
                    return CGFloat(self.myGoalHeight)+750
                }else{
                    return UITableViewAutomaticDimension
                }
            }
        }

        else if indexPath.section == 1 {
            if companyID == "14"{
                if indexPath.row == 0{
                    return 50
                }else{
                    return 90
                }
            }else{
                let heightView = CGFloat((arrayCareerLevel.count * 20) + 40)
                if indexPath.row == 0{
                    return 50
                }else{
                    return 50 + heightView
                }
            }
        }
        else if indexPath.section == 2{
            if indexPath.row == 0{
                return 50
            }else{
                return 130
            }
        }

        else{
            let heightView = CGFloat((self.arrWorkStream.count * 35) + 5)
            if indexPath.row == 0{
                return 50
            }else{
                if self.arrWorkStream.count > 0{
                    return 60 + heightView
                }else{
                    return 60
                }
            }
        }
    }
}


extension ProfileViewController {
    func configGaolListUI(cell: GoalDefinitionCell){
        
        for case let deleteView in cell.vwGoalList.subviews {
            deleteView.removeFromSuperview()
        }
        
        let width = UIScreen.main.bounds.width
        let wid = Int(width)
        let x = 15
        var y = 10
        for val in 0..<self.arrGoalsList.count {
            let button1 = UIButton(frame: CGRect(x: x, y: y, width: wid-35, height: 35))
            button1.setImage(UIImage(named: "unCheck"), for: .normal)
            button1.setTitle(arrGoalsList[val], for: .normal)
            button1.setTitleColor(.black, for: .normal)
            button1.contentHorizontalAlignment = .left
            button1.tag = val
            button1.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
            button1.contentEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            button1.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            cell.vwGoalList.addSubview(button1)
            y += 40
        }
        cell.heightContraint.constant = CGFloat(y)
    }
    
    @objc func selectAction(sender: UIButton){
        print("Selected \(sender.tag)")
        self.getSelectedText(index: sender.tag)
        
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblProfile)
        let cellIndexPath = self.tblProfile.indexPathForRow(at: pointInTable)
        let cell = tblProfile.cellForRow(at: cellIndexPath!) as? GoalDefinitionCell
        
        self.configGaolListUI(cell: cell!)
        self.selectedGoal(cell: cell!)
        cell?.myGoalTopSelectionView(arrGoal: self.arrSelectedGoalsList, duration: self.GoalDuration, isSelected : self.isMyGoalSelected)
        cell?.heightOtherContraint.constant = CGFloat(self.checkOtherOption())
        cell?.twGoal.text = "\(self.strMyGoal)"
    }
    
    func selectedGoal(cell: GoalDefinitionCell){
        let goalView = cell.vwGoalList
        for selected in goalView!.subviews {
            if let buttonObj = selected.viewWithTag(selected.tag) as? UIButton {
                if self.arrSelectedGoalsList.count > 0{
                    for index in self.arrSelectedGoalsList{
                        if index == buttonObj.currentTitle{
                            buttonObj.setImage(UIImage(named: "check"), for: .normal)
                            break
                        }else{
                            buttonObj.setImage(UIImage(named: "unCheck"), for: .normal)
                        }
                    }
                }else{
                    buttonObj.setImage(UIImage(named: "unCheck"), for: .normal)
                }
            }
        }
    }
    
    func getSelectedText(index : Int){
        let selectedIndex = arrGoalsList[index]
        if arrSelectedGoalsList.count > 0{
            if arrSelectedGoalsList.contains(selectedIndex){
                arrSelectedGoalsList = arrSelectedGoalsList.filter{ $0 != selectedIndex }
              //  reArrangeGoals(strGoal : selectedIndex, isAdd: false)
                //remove particular Value and Text
            }else{
                if self.arrSelectedGoalsList.count >= 3{
                    Utilities.sharedInstance.showToast(message: "maximum of three goals reached")
                   // print("maximum of three goals reached")
                    return
                }
                arrSelectedGoalsList.append(selectedIndex)
               // reArrangeGoals(strGoal : selectedIndex, isAdd: true)
                //Add particular Value and Text functionality
            }
        }else{
            if self.arrSelectedGoalsList.count >= 3{
                Utilities.sharedInstance.showToast(message: "maximum of three goals reached")
               // print("maximum of three goals reached")
                return
            }
            arrSelectedGoalsList.append(selectedIndex)
           // reArrangeGoals(strGoal : selectedIndex, isAdd: true)
        }
        print("Selected Text  ------------>",arrSelectedGoalsList)
    }
    
    
    func reArrangeGoals(strGoal : String, isAdd: Bool){
        if isAdd{
            if let index = self.arrGoalsList.firstIndex(where: {$0 ==  strGoal}) {
                let quoteObj =  self.arrGoalsList[index]
                self.arrGoalsList.remove(at: index)
                self.arrGoalsList.insert(quoteObj, at: 0)
            }
        }else{
            if let index = self.arrGoalsList.firstIndex(where: {$0 ==  strGoal}) {
                let quoteObj =  self.arrGoalsList[index]
                self.arrGoalsList.remove(at: index)
                self.arrGoalsList.append(strGoal)
            }
        }
    }
    func checkOtherOption() -> Int{
        var height = 0
        if arrSelectedGoalsList.contains("Other"){
            height = 60
        }else{
            height = 0
        }
        return height
    }
    
    
}
