//
//  RoleVC.swift
//  GICM
//
//  Created by Rafi on 20/11/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import FirebaseStorage
import SDWebImage
import FirebaseFirestore

class RoleVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    let userId = UserDefaults.standard.getUserUUID()

    //MARK:- Initialization
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblRole: UITableView!
    
    //Custom Picker Instance variable
    var customPickerObj : CustomPicker!
    var selectedPicker  = ""
    var course_id = ""
    
//    UserDefaults.standard.set(self.arrayCareerLevel, forKey: "CurrentPosting")
//    UserDefaults.standard.synchronize()
    
    let allPosting = ["Job Seeker", "Analyst","Consultant","Senior Consultant","Managing Consultant","Principal","Vice President","Business Analyst","Associate","Engagement Manager","Associate Partner","Partner","Associate Consultant","Senior Associate Consultant","Case Team Leader","Manager","Junior","Senior","Senior Manager","Director","Supervisor"]
    
    var arrRole = UserDefaults.standard.array(forKey: "CurrentPosting") ?? [""]
    
  //  var arrRole = ["Job Seeker", "Analyst","Consultant","Senior Consultant","Managing Consultant","Principal","Vice President","Business Analyst","Associate","Engagement Manager","Associate Partner","Partner","Associate Consultant","Senior Associate Consultant","Case Team Leader","Manager","Junior","Senior","Senior Manager","Director","Supervisor"]
    
    
    var arrImage = ["Art&Design","Business&Management","Computer&Technology", "Education&Teaching","Nurcing&Health Care", "Education&Teaching","Nurcing&Health Care"]
    
    var refStorage = Storage.storage().reference()
    var arrayListofCourse : [CoursedataFB] = []
    var arrSearch        : [CoursedataFB] = []
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCustomPickerInstance()
        getCourseListFirebase()
        Utilities.leftGapView(self.txtSearch)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- API Integation
    func getCourseListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("courseList")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseIntoCourse(snap:snap)
                self.tblRole.reloadData()
            }
        }
    }
    
    func parseIntoCourse(snap:[QueryDocumentSnapshot]){
        self.arrayListofCourse.removeAll()
        for obj in snap{
            let model = CoursedataFB()
            model.course_description = obj["course_description"] as? String ?? ""
            model.course_short_desc = obj["course_short_desc"] as? String ?? ""
            model.course_title = obj["course_title"] as? String ?? ""
            model.thumbnail = obj["thumbnail"] as? String ?? ""
            model.comments = obj["comments"] as? String ?? ""
            model.course_id = obj.documentID
            var arrSub : [CourseListDataFB] = []
            for sub in obj["course_list"] as? [[String:String]] ?? []{
                let submodel = CourseListDataFB()
                submodel.course_name = sub["course_name"] ?? ""
                submodel.courselist_id = sub["courselist_id"] ?? ""
                submodel.sub_content = sub["sub_content"] ?? ""
                arrSub.append(submodel)
            }
            model.course_list = arrSub
            self.arrayListofCourse.append(model)
        }
        
        let role = UserDefaults.standard.string(forKey: "Role") ?? ""
        print("Role \(role)")
        
        if (role.count) > 0 {
            self.roleBasedCourseList(strPosting: role)
        }else{
            self.arrSearch = self.arrayListofCourse
            self.tblRole.reloadData()
        }
        
       // self.arrSearch = self.arrayListofCourse.filter({$0.course_short_desc?.range(of: role, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
    }
    
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Search
    func roleBasedCourseList(strPosting: String){
        self.arrSearch = self.arrayListofCourse.filter({$0.course_short_desc?.range(of: strPosting, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
        self.tblRole.reloadData()
    }
    
    //MARK:- Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoleCell", for: indexPath) as! RoleCell
        cell.selectionStyle = .none
        cell.lblCourse.text = arrSearch[indexPath.row].course_title ?? ""
        // cell.imgCourse.image = UIImage(named: arrImage[indexPath.row]) //arrImage[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        course_id = arrSearch[indexPath.row].course_id ?? ""
        self.showBuyAlert()
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtSearch{
            listOfCompany(listData: arrRole as! [String])
            return false
        }else{
            return true
        }
    }
    
    func showBuyAlert() {
        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString("Do you want to Add?", comment:""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            self.addCourse()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    func addCourse(){
    //check already added
        let refEx = FirebaseManager.shared.firebaseDP!.collection("course_user").whereField("user_id", isEqualTo: userId).whereField("course_id", isEqualTo: course_id)
        refEx.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                Utilities.sharedInstance.showToast(message: "Already added")
            }
            else
            {
                // if new add
                let ref = FirebaseManager.shared.firebaseDP!.collection("course_user")
                ref.addDocument(data: self.getCourseJson()) { (error) in
                    if error == nil{
                        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.course_add)!)
                    }
                }
            }
        }
    }
    
    func getCourseJson() -> [String:Any]{
        return ["user_id" : userId,
                "course_id" : course_id,
                "buy" : "0"
        ]
    }
}

//MARK:- CustomPicker Methods
extension RoleVC :CustomPickerDelegate {
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
        removeCustomPicker()
        let pickerDateValue = item as! String
        // strCompanyName = pickerDateValue
        self.txtSearch.text = pickerDateValue
        self.roleBasedCourseList(strPosting: pickerDateValue)
        //  getCompanyPostingList(companyName: strCompanyName)
    }
    
    func pickerCancelled(){
        removeCustomPicker()
        selectedPicker = ""
    }
}

