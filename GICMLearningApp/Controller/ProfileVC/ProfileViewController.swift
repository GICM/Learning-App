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

class ProfileViewController: UIViewController,SMFeedbackDelegate,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tblProfile: LUExpandableTableView!
    var arrayCareerLevel :[String] = []
    var arrProjectList : [ProjectModelFB] = []
    var strProjectID = ""
    var arrComapnyList = [CompanyListFB]()
    var arrPostingList = [PostingListFB]()
    var jsonCompany : Any?
    var arrayCompanies : [[String:AnyObject]] = []
    var feedbackVC : SMFeedbackViewController?
    var arrCompanyName = [String]()
    var strCompanyName = "Capgimini"
    var strPreCompanyName = ""
    var companyID = ""
    var strPostingName = ""
    var PostingID = ""
    
    
    var strUserName = UserDefaults.standard.getUserName()
    var strEmail    = UserDefaults.standard.getEmail()
    var strDOB      = UserDefaults.standard.getDOB()
    var strBase64   = UserDefaults.standard.getProfileImage()
    let ImagePicker = UIImagePickerController()
    
    var arrHeader = ["Personal details","My Goal","Employer","Projects"]
    //Custom Picker Instance variable
    var customPickerObj : CustomPicker!
    var selectedPicker  = ""
    var strMyGoal = ""
    var goalTimingValue = 1
    var goalType    = 0
    var goalId = ""
    var isEdited = false
    
    var arrMygoal: [String] = [String]()
    var goalRowHeight:CGFloat = 0
    var isExpand = false
    var a = 0
    //Comment
    var customCommentObj     : CustomCommentVC!
    @IBOutlet var viewOtherCompany: UIView!
    @IBOutlet var txtOtherComp: UITextField!
    @IBOutlet var txtOtherPost: UITextField!
    
    
    @IBOutlet var viewEmail: UIView!
    @IBOutlet var txtEmail: UITextField!
    var strEmailSwitch = ""
    // id:2;
    
    let userId = UserDefaults.standard.getUserUUID()
    typealias isCompleted = (URL) -> ()
    
    var arrayHeaderImageState:[Bool] = [true,false,true,false]
    var arraySectionCellCount = [1,1,1,0]
    let sectionHeaderReuseIdentifier =  "MySectionHeader"
    
    //MARK:- VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewOtherCompany.frame = self.view.frame
        self.viewOtherCompany.isHidden = true
        self.viewEmail.frame = self.view.frame
        self.viewEmail.isHidden = true
        //  self.wind.addSubview(self.viewOtherCompany)
        self.tabBarController?.view.addSubview(self.viewOtherCompany)
        self.tabBarController?.view.addSubview(self.viewEmail)
        
        //        tblProfile.delegate = self
        //        tblProfile.dataSource = self
        createCustomCommentInstance()
        createCustomPickerInstance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginFirebase), name: Notification.Name("NotifyLoginVerify"), object: nil)

        
        Firestore.firestore().disableNetwork { (error) in
            self.getGoalDetails()
            self.getCompanyList()
            self.getPostingDetailsFB()
            self.projectListISLFirebase()
        }
        
        tblProfile.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        // tblProfile.register(UINib(nibName: "ReminderHeaderCell", bundle: nil), forCellReuseIdentifier: "ReminderHeaderCell")
        
        tblProfile.register(UINib(nibName: "ProjectListCell", bundle: nil), forCellReuseIdentifier: "ProjectListCell")
        
        tblProfile.register(UINib(nibName: "CareerLevelCell", bundle: nil), forCellReuseIdentifier: "CareerLevelCell")
        tblProfile.register(UINib(nibName: "MyGoalCell", bundle: nil), forCellReuseIdentifier: "MyGoalCell")
        
        tblProfile.register(UINib(nibName: "MyExpandableTableViewSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        tblProfile.expandableTableViewDelegate = self
        tblProfile.expandableTableViewDataSource = self
        //       Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.updateQuotes), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.btnImageEdit.isUserInteractionEnabled = false
        
        let loginValue = UserDefaults.standard.string(forKey: "Login")
        if loginValue == "0"{
            cell.btnEdit.setTitle("LOGIN", for: .normal)
            cell.btnEdit.isHidden = true
            cell.btnEdit.backgroundColor = UIColor.init(red: 26/255, green: 103/255, blue: 171/255, alpha: 0.4)
            cell.btnEdit.setTitleColor(UIColor.white, for: .normal)
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
            cell.btnImageEdit.isUserInteractionEnabled = true
        }
    }
    
    func uncheckAllImages(cell: MyGoalCell){
        cell.imgAccelerated.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        cell.imgLessStress.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        cell.imgContribute.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        cell.imgPersonal.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        cell.imgOthers.image = #imageLiteral(resourceName: "radio-btn-uncheck")
    }
    
    @objc func myGoalSelection(sender: UIButton){
        
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblProfile)
        let cellIndexPath = self.tblProfile.indexPathForRow(at: pointInTable)
        let cell = tblProfile.cellForRow(at: cellIndexPath!) as? MyGoalCell
        // cell?.slider.value = Float(value)
        uncheckAllImages(cell: cell!)
        cell?.twHeight.constant = 0.0
        let tagValue = Int(sender.tag)
        self.goalType = tagValue
        switch tagValue{
        case 0:
            print("0")
            cell?.imgAccelerated.image = #imageLiteral(resourceName: "radio-btn-check")
        case 1:
            print("1")
            cell?.imgLessStress.image = #imageLiteral(resourceName: "radio-btn-check")
        case 2:
            print("2")
            cell?.imgContribute.image = #imageLiteral(resourceName: "radio-btn-check")
        case 3:
            print("3")
            cell?.imgPersonal.image = #imageLiteral(resourceName: "radio-btn-check")
        case 4:
            print("4")
            cell?.twHeight.constant = 60.0
            cell?.imgOthers.image = #imageLiteral(resourceName: "radio-btn-check")
        default:
            print("Default")
        }
        self.updateGoal()
    }
    
    @objc func sliderValue(sender: UISlider){
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblProfile)
        let cellIndexPath = self.tblProfile.indexPathForRow(at: pointInTable)
        let value = Int(sender.value)
        let cell = tblProfile.cellForRow(at: cellIndexPath!) as? MyGoalCell
        // cell?.slider.value = Float(value)
        self.goalTimingValue = value
        if value > 1{
            cell?.lblTime.text = "\(value) Months"
        }else{
            cell?.lblTime.text = "\(value) Month"
        }
        self.updateGoal()
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
    
    @IBAction func AddProject(_ sender: Any) {
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "AddProjectVC") as! AddProjectVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.projectListISLFirebase()
        for index in 0..<self.arrHeader.count {
            if index == 1{
                
            }else{
                if let header = self.tblProfile.tableView(self.tblProfile, viewForHeaderInSection: index) as? MyExpandableTableViewSectionHeader{
                    self.tblProfile.expandableSectionHeader(header, shouldExpandOrCollapseAtSection: index)
                }
            }
        }
    }
    
    //MARK:- LogOut
    @objc func logOut(){
        showLogoutAlert()
    }
    
    //MARK:- GOAL Firebase handler
    func getGoalDetails(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("myGoal").whereField("userId", isEqualTo: userId)
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let myGoal = snap[0]
                self.strMyGoal = myGoal["goalText"] as? String ?? ""
                self.goalTimingValue = myGoal["GoalTime"] as? Int ?? 1
                self.goalType = myGoal["goalType"] as? Int ?? 0
                self.goalId = myGoal["goalId"] as? String ?? ""
                self.tblProfile.reloadData()
            }
            self.a = self.a + 1
            self.enableFirestoreNW()
        })
    }
    
    func getGOALJson() -> [String:Any]{
        return ["goalText" : self.strMyGoal,
                "GoalTime"  : self.goalTimingValue,
                "goalType" : self.goalType,
                "userId" : userId]
    }
    
    func enableFirestoreNW(){
        print(a)
        if a >= 4 {
            a = 0
            Firestore.firestore().enableNetwork(completion: nil)
        }
    }
    //MARK:- Add Goal API
    
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
                
                self.PostingID = snap[0].get("position_id") as? String ?? "0"
                self.strPostingName = snap[0].get("posting_name") as? String ?? ""
                self.strCompanyName = snap[0].get("company_name") as? String ?? "Select Company"
                self.companyID = snap[0].get("company_id") as? String ?? ""
                UserDefaults.standard.set(self.strCompanyName, forKey: "CurrentCompany")
                UserDefaults.standard.synchronize()
            }
            else{
                self.PostingID = "0"
                self.companyID = ""
                self.strPostingName = ""
                self.strCompanyName = "Select Company"
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
    @IBAction func cacelOtherCompany(sender: UIButton){
        viewOtherCompany.isHidden = true
        strCompanyName = strPreCompanyName
        self.tblProfile.reloadData()
    }
    
    @IBAction func saveOtherCompany(sender: UIButton){
        
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
    @IBAction func cacelViewEmail(sender: UIButton){
        viewEmail.isHidden = true
        self.tblProfile.reloadData()
    }
    
    @IBAction func saveEamilHandler(sender: UIButton){
        
        if (txtEmail.text?.count)! > 0 {
            strEmailSwitch = txtEmail.text!
            //self.switchUserFB();
             self.checkExistUser()
            
        }else{
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.emailid)!)
        }
    }
    
    func switchUserFB()
    {
        self.sendSignInLink()
        self.loginFirebase()
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
        var x = 20
        var y = 30 + (25 * (arrayCareerLevel.count - 1 ))
        for i in 0..<arrayCareerLevel.count {
            
            let button1 = UIButton(frame: CGRect(x: x, y: y, width: 77, height: 30))
            button1.setTitle(arrayCareerLevel[i].capitalized, for: .normal)
            button1.backgroundColor = UIColor.white
            button1.titleLabel?.textColor = UIColor.red
            button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button1.setTitleColor(UIColor.darkGray, for:.normal)
            //button1.setTitleColor(UIColor.black, for:.selected)
            button1.contentHorizontalAlignment = .left
            button1.contentVerticalAlignment = .top
            button1.titleLabel?.numberOfLines = 2
            button1.titleLabel?.lineBreakMode  = .byWordWrapping
            button1.tag = i
            let extraView = UIView(frame: CGRect(x: x-3, y: y-3, width: 80, height: 28))
            //Current Position
            if strPostingName == arrayCareerLevel[i]{
                extraView.backgroundColor = Constants.getCustomBlueColor()
            }
            else{
                extraView.backgroundColor = UIColor.darkGray
            }
            
            button1.addTarget(self, action: #selector(selectedButton), for: .touchUpInside)
            // extraView.backgroundColor = UIColor.darkGray
            extraView.tag = i
            
            cell.vwContent.addSubview(extraView)
            cell.vwContent.addSubview(button1)
            cell.vwContent.bringSubview(toFront: button1)
            
            x += 77
            y = y - 25
        }
    }
    
    @objc func selectedButton(sender:UIButton) {
        if let superView = sender.superview {
            for case let selectedView as UIView in superView.subviews {
                if sender.tag == selectedView.tag {
                    selectedView.backgroundColor = Constants.getCustomBlueColor()
                    sender.backgroundColor = UIColor.white
                    sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                    sender.setTitleColor(UIColor.black, for:.normal)
                } else {
                    if !selectedView.isKind(of: UIButton.self) {
                        selectedView.backgroundColor = UIColor.darkGray
                    } else {
                        for case let remainingButton as UIButton in superView.subviews  {
                            if !(remainingButton.tag == sender.tag) {
                                remainingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
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
    
    @objc func FAQ(){
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "CreateVC") as! CreateVC      //  let vc =
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
                    self.parseIntoModel(snap: snap)
                    self.tblProfile.reloadData()
                    for index in 0..<self.arrHeader.count {
                        if index == 1{
                            
                        }else{
                            if let header = self.tblProfile.tableView(self.tblProfile, viewForHeaderInSection: index) as? MyExpandableTableViewSectionHeader{
                                self.tblProfile.expandableSectionHeader(header, shouldExpandOrCollapseAtSection: index)
                            }
                        }
                    }
                }
                self.a = self.a + 1
                self.enableFirestoreNW()
            }
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
            arrProjectList.append(model)
        }
    }
    func deleteProjectApiFirebase(){
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").document(strProjectID)
        ref.delete { (error) in
            if error == nil{
                self.deleteAllChildRelatedProject()
                self.projectListISLFirebase()
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Delete project failed,try again later", controller: self)
            }
        }
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
                let projectObj = self.arrProjectList[indexPath.row]
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
                let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
                let nextVC =  story.instantiateViewController(withIdentifier: "AddProjectVC") as! AddProjectVC
                nextVC.fromVC = "edit"
                nextVC.projectModelObj = self.arrProjectList[indexPath.row]
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            editAction.backgroundColor = UIColor.yellow
            editAction.textColor = UIColor.black
            return [editAction]
        }
    }
}


//MARK: UITableViewDataSource,UITableViewDelegate Methods
//extension ProfileViewController : UITableViewDataSource,UITableViewDelegate{
//
//    @objc func myGoalExpand(){
//        if isExpand{
//            goalRowHeight = 0
//            arrMygoal.removeAll()
//            isExpand = !isExpand
//        }else{
//            goalRowHeight = 385
//            arrMygoal = ["one"]
//            isExpand = true
//        }
//        self.tblProfile.reloadData()
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 4
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 3{
//            return arrProjectList.count
//        }else if section == 1{
//            return arrMygoal.count
//        }
//        else{
//            return 1
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.section == 0 {  // Profile
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
//
//            cell.btnLogOut.addTarget(self, action: #selector(logOut), for: .touchUpInside)
//            cell.btnEdit.addTarget(self, action: #selector(editProfileDetail), for: .touchUpInside)
//            cell.btFAQ.addTarget(self, action: #selector(FAQ), for: .touchUpInside)
//            cell.btFeedback.addTarget(self, action: #selector(feedbackHanlder), for: .touchUpInside)
//            cell.btnImageEdit.addTarget(self, action: #selector(Edit), for: .touchUpInside)
//
//            self.editMenu(cell: cell)
//            self.checkLogedIn(cell: cell)
//            cell.setCellDetails(email: strEmail, userName: strUserName, dob: strDOB, strImage: self.strBase64)
//            return cell
//        }
//
//        else if indexPath.section == 1{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MyGoalCell", for: indexPath) as! MyGoalCell
//            cell.btnOthers.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnAccelerated.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnPersonal.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnContribute.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//            cell.btnLessStress.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
//
//            cell.slider.addTarget(self, action: #selector(sliderValue), for: .valueChanged)
//            cell.twMyGoal.delegate = self
//            cell.selectionStyle = .none
//
//            cell.changeUI(typeValue:self.goalType, strGoal: self.strMyGoal, timing: goalTimingValue)
//
//            return cell
//        }
//        else if indexPath.section == 2 {  //  // Career Level
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CareerLevelCell", for: indexPath) as! CareerLevelCell
//
//            cell.btnCompanyName.setTitle(strCompanyName, for: .normal)
//            cell.btnCompanyName.addTarget(self, action: #selector(chooseCompanyName), for: .touchUpInside)
//
//            if companyID == "14"{
//                cell.careerLadderLVal.text = strPostingName
//
//            }else{
//                setLadderButton(cell: cell)
//                cell.careerLadderLVal.text = ""
//                cell.careerLevel(strComapny: strCompanyName)
//                cell.setWidth(arrayCareerLevel: arrayCareerLevel, frameView: self.view)
//                cell.selectionStyle = .none
//                setLadderButton(cell:cell)
//            }
//
//            return cell
//        }
//        else{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectListCell", for: indexPath) as! ProjectListCell
//            let modelObj = arrProjectList[indexPath.row]
//            cell.lblProjectName.text = modelObj.project_name ?? ""
//            cell.lblProjectStatus.text = modelObj.date ?? ""
//
//            if let profileStr = modelObj.project_image, profileStr.count > 0{
//                let dataDecoded : Data = Data(base64Encoded: profileStr)!
//                cell.imgApplying.image = UIImage(data: dataDecoded)
//            }else{
//                cell.imgApplying.image = UIImage(named: "noImage")
//            }
//
//            cell.selectionStyle = .none
//            cell.delegate = self as? SwipeTableViewCellDelegate
//            return cell
//        }
//        //    else{   // Remainder
//        //        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ReminderHeaderCell") as! ReminderHeaderCell
//        //        return headerCell
//        //    }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Did selected")
//        if indexPath.section == 3{
//            let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
//            let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
//
//            let modelObj = arrProjectList[indexPath.row]
//            nextVC.projectName     = modelObj.project_name!
//            nextVC.projectID       = modelObj.project_id!
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 365
//        }else if indexPath.section == 1 {
//            return self.goalRowHeight
//        }
//        else if indexPath.section == 2 {
//            if companyID == "14"{
//                return 90
//            }else{
//                let heightView = CGFloat((arrayCareerLevel.count * 25) + 40)
//                return 50 + heightView
//            }
//        }
//        else{
//            return 50
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let headerView = UIView()
//
//        if section == 1{
//            headerView.frame = tableView.frame
//            let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 38))
//
//            //Button
//            let expandButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 38))
//            expandButton.addTarget(self, action: #selector(myGoalExpand), for: .touchUpInside)
//
//            label.backgroundColor = UIColor.clear
//            label.textColor = UIColor.black
//            label.text = arrHeader[section]//"Projects"
//            label.textAlignment = .center
//            label.font = UIFont.boldSystemFont(ofSize: 17)
//            headerView.addSubview(expandButton)
//
//            headerView.addSubview(label)
//            headerView.backgroundColor = UIColor.lightGray
//
//            return headerView
//        }else{
//            headerView.frame = tableView.frame
//            let label = UILabel.init(frame: CGRect(x: 0, y: 1, width: headerView.frame.size.width, height: 38))
//            label.backgroundColor = UIColor.clear
//            label.textColor = UIColor.black
//            label.text = arrHeader[section]//"Projects"
//            label.textAlignment = .center
//            label.font = UIFont.boldSystemFont(ofSize: 17)
//            headerView.addSubview(label)
//            headerView.backgroundColor = UIColor.lightGray
//            return headerView
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 38
//    }
//}

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
            self.tblProfile.reloadData()
            
        }else{
            let pickerDateValue = item as! String
            strCompanyName = pickerDateValue
            if strCompanyName == "Other"{
                self.viewOtherCompany.isHidden = false
                self.tblProfile.reloadData()
            }else{
                getCompanyPostingList(companyName: strCompanyName)
            }
        }
        removeCustomPicker()
        selectedPicker = ""
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


extension ProfileViewController: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate{
    
    // MARK: - Validation Methods
    func editProfileValidate() -> Bool {
        
        var bIsSuccess     = false
        var errorMessage   = ""
        let strUserName    = self.strUserName
        let strEmail       = self.strEmail
        
        if strUserName == ""{
            errorMessage = Constants.ErrorMessage.usermame
        }
        else if strEmail == "" {
            errorMessage = Constants.ErrorMessage.email
            
        }else if !Utilities.sharedInstance.validateEmail(with:strEmail){
            errorMessage = Constants.ErrorMessage.vaildemail
            
        }else{
            bIsSuccess = true
        }
        
        if !bIsSuccess {
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
        }
        return bIsSuccess
    }
    
    func requestEditFirebase(){
        if self.strBase64 == ""{
            self.strBase64 = UserDefaults.standard.getProfileImage()
        }
        
        let editData = ["user_name" : strUserName,"e_mail"  : strEmail,"dob" : strDOB,"prof_pic" : self.strBase64] as [String:Any]
        let ref = FirebaseManager.shared.firebaseDP!.collection("users").document(UserDefaults.standard.getUserID())
        ref.updateData(editData, completion: { (error) in
            print("Edit Detail Error: \(String(describing: error))")
            if error == nil{
                
                self.storeUserData()
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
            }
        })
    }
    
    func sendSignInLink()
    {
        let actionCodeSettings = ActionCodeSettings()
        
        
        //        guard let link = URL(string: "gicm://a") else { return }
        //        let dynamicLinksDomain = "gicm.page.link"
        //        let linkBuilder = DynamicLinkComponents(link: link, domain: dynamicLinksDomain)
        //        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
        //
        //        guard let longDynamicLink = linkBuilder.url else { return }
        //        print("The long URL is: \(longDynamicLink)")
        
        actionCodeSettings.url =  URL(string: "https://gicm-mobile-app.firebaseapp.com/")
        actionCodeSettings.handleCodeInApp = true
        print(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        Auth.auth().sendSignInLink(toEmail:strEmailSwitch,
                                   actionCodeSettings: actionCodeSettings) { error in
                                    // ...
                                    if let error = error {
                                        Utilities.sharedInstance.showToast(message: error.localizedDescription)
                                        return
                                    }
                                    // The link was successfully sent. Inform the user.
                                    // Save the email locally so you don't need to ask the user for it again
                                    // if they open the link on the same device.
                                    UserDefaults.standard.set(self.strEmailSwitch, forKey: "EmailSwitch")
                                    Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.switch_user)!)
                                    
        }
    }
    
    func sendEmail(email:NSString) {
        self.generateLink { (url) in
            let subject = "Verify your email for GICM!"
            let invitationLink = url.absoluteString
            let msg = "<p>Hey,</br>Follow this link to verify your email address. If you didn’t ask to verify this address, you can ignore this email!</br></br> <a href=\"\(invitationLink)\">\(subject)</a></p>"
            if !MFMailComposeViewController.canSendMail() {
                // Device can't send email
                return
            }
            let mailer = MFMailComposeViewController()
            mailer.mailComposeDelegate = self
            mailer.setSubject(subject)
            mailer.setMessageBody(msg, isHTML: true)
            mailer.setToRecipients([email as String])
            self.present(mailer, animated: true, completion: nil)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if result == .sent{
            
        }
    }
    
    func generateLink(isComplete:@escaping isCompleted){
        strEmailSwitch = "colantest@gmail.com"
        let link = URL(string: "gicm://\(Utility.sharedInstance.randomString(length: 5))/")
        print(link ?? "")
        let referralLink = DynamicLinkComponents(link: link!, domain: "gicm.page.link")
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.demo.app2018")
        referralLink.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else{
                print(shortURL!)
                isComplete(shortURL!)
            }
        }
    }
    
    func configureMail(){
        
        let link =  "gicm://\(Utility.sharedInstance.randomString(length: 5))"
        print("The long URL is: \(link)")
        UserDefaults.standard.set(link, forKey: "SwitchLink")
        UserDefaults.standard.set("0", forKey: "SwitchLinkVerify")
        UserDefaults.standard.synchronize()
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = MAIL_HOST_NAME
        smtpSession.username = MAIL_USERNAME
        smtpSession.password = MAIL_PASSWORD
        smtpSession.port = 587
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.startTLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = String(data: data!, encoding: .utf8){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: self.strEmailSwitch, mailbox: self.strEmailSwitch)]
        builder.header.from = MCOAddress(displayName: "noreply@gicm-app.com", mailbox: MAIL_USERNAME)
        let subject = "Verify your email for GICM!"
        builder.header.subject = subject
        let invitationLink = link
        let msg = "<p>Hey,</br>Follow this link to verify your email address. </br></br> <a href=\"\(invitationLink)\">\(subject)</a> </br></br> If you didn’t ask to verify this address, you can ignore this email!</p>"
        builder.htmlBody = msg
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error.debugDescription)")
            } else {
                NSLog("Successfully sent email!")
                Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.switch_user)!)
                
            }
        }
        
    }
    
    func requestRegisterFirebase(){
        
        let editData = ["e_mail"  : self.strEmailSwitch,"user_uuid" : UserDefaults.standard.getUserUUID()] as [String:Any]
        _ = FirebaseManager.shared.firebaseDP!.collection("users").addDocument(data: editData, completion: { (err) in
            if err  != nil{
                Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.register_failed)!)
            }
            else
            {
              //  self.loginFirebase()
                 self.configureMail()
            }
        })
    }
    //Store in Locally
    func storeUserData(){
        UserDefaults.standard.setEmail(value: strEmail )
        UserDefaults.standard.setUserName(value: strUserName)
        UserDefaults.standard.setDOB(value: strDOB )
        UserDefaults.standard.setProfileImage(value: self.strBase64)
        UserDefaults.standard.set("1", forKey: "Login")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name("changeTabBarImage"), object: nil, userInfo: nil)
        self.tblProfile.reloadData()
    }
    
    
    func chooseuploadImage(){
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        ImagePicker.delegate = self
    }
    
    //MARK: -UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //  picker.dismiss(animated: true, completion: nil)
        
        let orinalImage : UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        picker.dismiss(animated: false, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: orinalImage, cropMode: .circle)
            imageCropVC.setZoomScale(50.0)
            imageCropVC.delegate = self
            imageCropVC.dataSource = self
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
        })
        //You will get cropped image here..
        //        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
        //            self.imgProfilePhoto.image = image
        //            imgProfilePhoto.layer.cornerRadius = 70
        //            imgProfilePhoto.clipsToBounds      = true
        //
        //            let imageData: Data! = UIImageJPEGRepresentation(imgProfilePhoto.image!, 0.2)
        //            strBase64 = imageData.base64EncodedString()
        //
        //        }else{
        //            print("Something went wrong")
        //        }
        //        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - OpenCamera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            
            ImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            ImagePicker.allowsEditing = true
            self.present(ImagePicker, animated: true, completion: nil)
            
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - OpenGallary
    func openGallary(){
        ImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        ImagePicker.allowsEditing = true
        self.present(ImagePicker, animated: true, completion: nil)
    }
    
    
    func dateOfBirthAction(){
        dismissKeyboard()
        selectedPicker = "dob"
        addCustomPicker()
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_Date)
        customPickerObj.customDatePicker.datePickerMode = .date
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.location == 0 && string == " ") {
            return false;
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag < 3 {
            isEdited = true
        }
        if textField.tag == 2 {
            self.dateOfBirthAction()
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.strUserName = textField.text!
        }else if textField.tag == 1{
            self.strEmail = textField.text!
        }
        self.tblProfile.reloadData()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.strMyGoal = textView.text ?? ""
        self.updateGoal()
        self.tblProfile.reloadData()
    }
    
}


extension ProfileViewController: RSKImageCropViewControllerDelegate{
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        let imageData: Data! = UIImageJPEGRepresentation(croppedImage, 0.2)
        self.strBase64 = imageData.base64EncodedString()
        self.isEdited = true
        self.tblProfile.reloadData()
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


// MARK: - LUExpandableTableViewDataSource

extension ProfileViewController: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return 4
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3{
            return arrProjectList.count
        }
            //else if section == 1{
            //   return arrMygoal.count
            // }
        else{
            return 1
        }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {  // Profile
            let cell = expandableTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            
            cell.btnLogOut.addTarget(self, action: #selector(logOut), for: .touchUpInside)
            cell.btnEdit.addTarget(self, action: #selector(editProfileDetail), for: .touchUpInside)
            cell.btFAQ.addTarget(self, action: #selector(FAQ), for: .touchUpInside)
            cell.btFeedback.addTarget(self, action: #selector(feedbackHanlder), for: .touchUpInside)
            cell.btnImageEdit.addTarget(self, action: #selector(Edit), for: .touchUpInside)
            
            self.editMenu(cell: cell)
            self.checkLogedIn(cell: cell)
            cell.setCellDetails(email: strEmail, userName: strUserName, dob: strDOB, strImage: self.strBase64)
            return cell
        }
            
        else if indexPath.section == 1{
            let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MyGoalCell", for: indexPath) as! MyGoalCell
            cell.btnOthers.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
            cell.btnAccelerated.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
            cell.btnPersonal.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
            cell.btnContribute.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
            cell.btnLessStress.addTarget(self, action: #selector(myGoalSelection), for: .touchUpInside)
            
            cell.slider.addTarget(self, action: #selector(sliderValue), for: .valueChanged)
            cell.twMyGoal.delegate = self
            cell.selectionStyle = .none
            
            cell.changeUI(typeValue:self.goalType, strGoal: self.strMyGoal, timing: goalTimingValue)
            
            return cell
        }
        else if indexPath.section == 2 {  //  // Career Level
            let cell = expandableTableView.dequeueReusableCell(withIdentifier: "CareerLevelCell", for: indexPath) as! CareerLevelCell
            
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
        }
        else{
            let cell = expandableTableView.dequeueReusableCell(withIdentifier: "ProjectListCell", for: indexPath) as! ProjectListCell
            let modelObj = arrProjectList[indexPath.row]
            cell.lblProjectName.text = modelObj.project_name ?? ""
            cell.lblProjectStatus.text = modelObj.date ?? ""
            
            if let profileStr = modelObj.project_image, profileStr.count > 0{
                let dataDecoded : Data = Data(base64Encoded: profileStr)!
                cell.imgApplying.image = UIImage(data: dataDecoded)
            }else{
                cell.imgApplying.image = UIImage(named: "noImage")
            }
            
            cell.selectionStyle = .none
            cell.delegate = self as? SwipeTableViewCellDelegate
            return cell
        }
        //    else{   // Remainder
        //        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ReminderHeaderCell") as! ReminderHeaderCell
        //        return headerCell
        //    }
        //        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? ResourceDescriptionCell else {
        //            assertionFailure("Cell shouldn't be nil")
        //            return UITableViewCell()
        //        }
        //
        //        let section  = indexPath.section
        //
        //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTappedRightSideTop(tapGestureRecognizer:)))
        //        cell.imgRightSideTop.isUserInteractionEnabled = true
        //        cell.imgRightSideTop.addGestureRecognizer(tapGestureRecognizer)
        //
        //        let tapGestureRecognizerBottom = UITapGestureRecognizer(target: self, action: #selector(imageTappedRightSideDown(tapGestureRecognizer:)))
        //        cell.imgRightSideBottom.isUserInteractionEnabled = true
        //        cell.imgRightSideBottom.addGestureRecognizer(tapGestureRecognizerBottom)
        //
        //        switch section {
        //        case 0:
        //            cell.lblSubtitle.text = arraySubTitle[indexPath.row]
        //            cell.lblsubSubtitle.text = arraySubItalic[indexPath.row]
        //            //  cell.imgLeftSide.image = UIImage(data: arrayLeftSide[indexPath.row])
        //            cell.imgLeftSide.sd_setImage(with: URL(string: arrayResult[indexPath.row].get("icon_url") as? String ?? ""), placeholderImage: UIImage(named: "noImage"))
        //
        //            cell.imgRightSideTop.image = arrayRightSideTop[indexPath.row]
        //            cell.imgRightSideBottom.image = arrayRightSideBottom[indexPath.row]
        //            cell.txtvwDescription.text = arrayDescription[indexPath.row]
        //
        //            if indexPath.row == 0 {
        //                cell.imgRightSideTop.tag = 1
        //                cell.imgRightSideBottom.tag = 1
        //            } else {
        //                cell.imgRightSideTop.tag = 2
        //                cell.imgRightSideBottom.tag = 2
        //            }
        //
        //        case 1:
        //            cell.lblSubtitle.text = arraySubTitle[2]
        //            cell.lblsubSubtitle.text = arraySubItalic[2]
        //            cell.imgLeftSide.sd_setImage(with: URL(string: arrayResult[2].get("icon_url") as? String ?? ""), placeholderImage: UIImage(named: "noImage"))
        //            cell.imgRightSideTop.image = arrayRightSideTop[2]
        //            cell.imgRightSideBottom.image = arrayRightSideBottom[2]
        //            cell.txtvwDescription.text = arrayDescription[2]
        //            cell.imgRightSideTop.tag = 3
        //            cell.imgRightSideBottom.tag = 3
        //
        //        case 2:
        //            cell.lblSubtitle.text = arraySubTitle[3]
        //            cell.lblsubSubtitle.text = arraySubItalic[3]
        //            cell.imgLeftSide.sd_setImage(with: URL(string: arrayResult[3].get("icon_url") as? String ?? ""), placeholderImage: UIImage(named: "noImage"))
        //            cell.imgRightSideTop.image = arrayRightSideTop[3]
        //            cell.imgRightSideBottom.image = arrayRightSideBottom[3]
        //            cell.txtvwDescription.text = arrayDescription[3]
        //            cell.imgRightSideTop.tag = 4
        //            cell.imgRightSideBottom.tag = 4
        //        default:
        //            return cell
        //        }
        //
        //        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderReuseIdentifier) as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        if arrHeader.count > 0{
            sectionHeader.label.text = arrHeader[section]
        }
        return sectionHeader
    }
    
}

// MARK: - LUExpandableTableViewDelegate

extension ProfileViewController: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        
        if indexPath.section == 0 {
            return 365
        }else if indexPath.section == 1 {
            return 385//self.goalRowHeight
        }
        else if indexPath.section == 2 {
            if companyID == "14"{
                return 90
            }else{
                let heightView = CGFloat((arrayCareerLevel.count * 25) + 40)
                return 50 + heightView
            }
        }
        else{
            return 50
        }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        
        return 38
    }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
        
        print("Did selected")
        if indexPath.section == 3{
            let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
            let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
            
            let modelObj = arrProjectList[indexPath.row]
            nextVC.projectName     = modelObj.project_name!
            nextVC.projectID       = modelObj.project_id!
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select cection header at section \(section)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
    
}



